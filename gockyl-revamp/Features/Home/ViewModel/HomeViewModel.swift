//
//  HomeViewModel.swift
//  gockyl-revamp
//
//  Backs the room screen: the frog's fly balance, the active mode, and a running
//  session's clock. While a session runs the frog is on duty and a time readout
//  is shown — counting *down* the remaining lock in Locked-in mode, or *up*
//  toward the limit (with the current interruption stage) in Monitoring mode.
//  When it stops, the session is persisted and flies are awarded.
//
//  The clock here is a plain local timer; the FamilyControls / ActivityKit
//  wiring that will really drive it lands later.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class HomeViewModel {
    private(set) var flyBalance: Int = 0

    /// The mode the user configured in Settings.
    private(set) var mode: MonitoringMode = .monitoring

    /// Whether a session is currently running. Drives the frog's art.
    private(set) var hasActiveSession: Bool = false

    /// Seconds elapsed since the current session started.
    private(set) var elapsed: TimeInterval = 0

    // Session config, snapshotted from the profile when a session starts.
    private var lockedInDuration: TimeInterval = 1500
    private var dailyLimit: TimeInterval = 600
    private var snoozeStep: TimeInterval = 120
    private var enforcement: Enforcement = .soft
    private var sessionStart: Date = .now

    /// One fly per full minute of a completed Locked-in session.
    private static let fliesPerMinute = 1

    private let profileRepository: ProfileRepositoryProtocol
    private let lockedInRepository: LockedInSessionRepositoryProtocol
    private let monitoringRepository: MonitoringSessionRepositoryProtocol
    private let screenTime: ScreenTimeService
    private let liveActivity: LiveActivityService
    private var tickTask: Task<Void, Never>?

    /// The last stage pushed to the Live Activity, to update only on change.
    private var lastPushedStage: InterruptionStage = .idle

    init(
        profileRepository: ProfileRepositoryProtocol,
        lockedInRepository: LockedInSessionRepositoryProtocol,
        monitoringRepository: MonitoringSessionRepositoryProtocol,
        screenTime: ScreenTimeService,
        liveActivity: LiveActivityService
    ) {
        self.profileRepository = profileRepository
        self.lockedInRepository = lockedInRepository
        self.monitoringRepository = monitoringRepository
        self.screenTime = screenTime
        self.liveActivity = liveActivity
    }

    // MARK: - Derived UI state

    /// Which frog art the room should show — derived, never persisted.
    var frogState: FrogState { hasActiveSession ? .onDuty : .sleeping }

    /// Title for the start/stop control, reflecting the current mode.
    var actionTitle: String {
        if hasActiveSession { return "Stop" }
        switch mode {
        case .lockedIn:   return "Start Locked-in"
        case .monitoring: return "Start Monitoring"
        }
    }

    /// The big clock string shown while a session runs: remaining for Locked-in,
    /// elapsed for Monitoring.
    var timeText: String {
        switch mode {
        case .lockedIn:   return max(0, lockedInDuration - elapsed).clockString
        case .monitoring: return elapsed.clockString
        }
    }

    /// The caption under the clock: what the number means / where we are.
    var timeCaption: String {
        switch mode {
        case .lockedIn:   return "remaining"
        case .monitoring: return currentStage.title
        }
    }

    /// In Monitoring, the highest interruption stage reached for the elapsed
    /// time under the current enforcement.
    var currentStage: InterruptionStage {
        var reached: InterruptionStage = .idle
        for stage in InterruptionStage.ladder(for: enforcement) {
            if let threshold = stage.threshold(dailyLimit: dailyLimit, snoozeStep: snoozeStep),
               elapsed >= threshold {
                reached = stage
            }
        }
        return reached
    }

    // MARK: - Lifecycle

    func refresh() {
        do {
            let profile = try profileRepository.currentProfile()
            flyBalance = profile.bugBalance
            mode = profile.monitoringMode
        } catch {
            AppLogger.persistence.error("Home refresh failed: \(error)")
        }
    }

    /// Starts or stops the current session.
    func toggleSession() {
        hasActiveSession ? stop(completed: false) : start()
    }

    // MARK: - Private

    private func start() {
        // Snapshot the latest config so mid-session Settings changes don't apply.
        do {
            let profile = try profileRepository.currentProfile()
            mode = profile.monitoringMode
            lockedInDuration = profile.lockedInDuration
            dailyLimit = profile.dailyLimit
            snoozeStep = profile.snoozeStep
            enforcement = profile.enforcement
            screenTime.restoreSelection(from: profile.selectedAppsToken)
        } catch {
            AppLogger.persistence.error("Home start failed to load config: \(error)")
        }

        elapsed = 0
        sessionStart = .now
        hasActiveSession = true

        // Register the real usage thresholds with DeviceActivity (no-ops until
        // authorization + app selection exist; the local clock keeps the UI alive).
        if mode == .monitoring {
            screenTime.startMonitoring(
                dailyLimit: dailyLimit,
                snoozeStep: snoozeStep,
                enforcement: enforcement
            )
        }

        // Put the session on the Lock Screen / Dynamic Island.
        lastPushedStage = .idle
        liveActivity.start(
            mode: mode,
            startDate: sessionStart,
            duration: mode == .lockedIn ? lockedInDuration : dailyLimit,
            stage: .idle
        )

        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                self.elapsed += 1

                // Push stage changes (not seconds) to the Live Activity.
                if self.mode == .monitoring, self.currentStage != self.lastPushedStage {
                    self.lastPushedStage = self.currentStage
                    self.liveActivity.update(stage: self.currentStage)
                }

                // Locked-in ends itself once the committed time is up.
                if self.mode == .lockedIn, self.elapsed >= self.lockedInDuration {
                    self.stop(completed: true)
                    return
                }
            }
        }
    }

    /// Stops the session, persists a record, and awards flies.
    /// - Parameter completed: `true` when a Locked-in session ran its full time.
    private func stop(completed: Bool) {
        tickTask?.cancel()
        tickTask = nil
        hasActiveSession = false

        if mode == .monitoring {
            screenTime.stopMonitoring()
            // Ending the session from Gockyl is the sanctioned unlock path.
            screenTime.liftShield()
        }

        liveActivity.end()
        persistSession(completed: completed)
        elapsed = 0
    }

    private func persistSession(completed: Bool) {
        do {
            switch mode {
            case .lockedIn:
                let flies = completed ? Int(elapsed / 60) * Self.fliesPerMinute : 0
                let session = LockedInSession(
                    startDate: sessionStart,
                    plannedDuration: lockedInDuration,
                    actualDuration: elapsed,
                    isCompleted: completed,
                    fliesEarned: flies
                )
                try lockedInRepository.save(session)
                try award(flies)

            case .monitoring:
                let stage = currentStage
                // Reward mechanic (flies for restraint) is still TBD — record 0
                // for now so the history is complete; see achievements work.
                let session = MonitoringSession(
                    startDate: sessionStart,
                    enforcement: enforcement,
                    dailyLimit: dailyLimit,
                    highestStageReached: stage.rawValue,
                    wasShielded: stage.shields(under: enforcement),
                    fliesEarned: 0
                )
                try monitoringRepository.save(session)
            }
        } catch {
            AppLogger.session.error("Failed to persist session: \(error)")
        }
    }

    private func award(_ flies: Int) throws {
        guard flies > 0 else { return }
        let profile = try profileRepository.currentProfile()
        profile.bugBalance += flies
        try profileRepository.save()
        flyBalance = profile.bugBalance
    }
}
