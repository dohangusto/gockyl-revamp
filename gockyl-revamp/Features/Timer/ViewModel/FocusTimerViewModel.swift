//
//  FocusTimerViewModel.swift
//  gockyl-revamp
//
//  Drives the countdown, persists the finished session, and awards "bugs".
//  All business rules for a focus session live here; the view is purely visual.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class FocusTimerViewModel {
    enum Phase {
        case idle
        case running
        case finished
        case cancelled
    }

    // MARK: - Published state
    private(set) var phase: Phase = .idle
    private(set) var remaining: TimeInterval
    private(set) var bugsEarned: Int = 0

    // MARK: - Config
    let plannedDuration: TimeInterval

    /// One bug is earned per full minute of focus.
    private static let bugsPerMinute = 1

    // MARK: - Dependencies
    private let sessionRepository: FocusSessionRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol

    private var startDate: Date?
    private var timerTask: Task<Void, Never>?

    init(
        minutes: Int,
        sessionRepository: FocusSessionRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.plannedDuration = TimeInterval(minutes * 60)
        self.remaining = TimeInterval(minutes * 60)
        self.sessionRepository = sessionRepository
        self.profileRepository = profileRepository
    }

    var progress: Double {
        guard plannedDuration > 0 else { return 0 }
        return 1 - (remaining / plannedDuration)
    }

    // MARK: - Intents

    func start() {
        guard phase == .idle else { return }
        phase = .running
        startDate = .now
        timerTask = Task { [weak self] in
            await self?.runCountdown()
        }
    }

    /// User-initiated stop before the timer completes.
    func cancel() {
        guard phase == .running else { return }
        timerTask?.cancel()
        phase = .cancelled
        finalize(completed: false)
    }

    // MARK: - Private

    private func runCountdown() async {
        while remaining > 0 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            remaining = max(remaining - 1, 0)
        }
        phase = .finished
        finalize(completed: true)
    }

    private func finalize(completed: Bool) {
        let focused = plannedDuration - remaining
        let earned = completed ? Int(focused / 60) * Self.bugsPerMinute : 0
        bugsEarned = earned

        let session = FocusSession(
            startDate: startDate ?? .now,
            plannedDuration: plannedDuration,
            focusedDuration: focused,
            isCompleted: completed,
            bugsEarned: earned
        )

        do {
            try sessionRepository.save(session)
            if earned > 0 {
                let profile = try profileRepository.currentProfile()
                profile.bugBalance += earned
                try profileRepository.save()
            }
        } catch {
            AppLogger.session.error("Failed to finalize session: \(error)")
        }
    }
}
