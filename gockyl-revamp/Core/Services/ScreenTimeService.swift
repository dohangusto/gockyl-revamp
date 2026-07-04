//
//  ScreenTimeService.swift
//  gockyl-revamp
//
//  The single place that talks to Apple's Screen Time stack, translating our
//  domain (InterruptionStage ladder, Enforcement) into platform calls:
//
//  - FamilyControls: user authorization + which apps to watch
//    (`FamilyActivitySelection`, persisted opaquely on the profile).
//  - DeviceActivity: registers one usage-threshold event per interruption
//    stage. The *reactions* to those events run in a separate
//    DeviceActivityMonitor extension (later phase) — this side only schedules.
//  - ManagedSettings: applies/lifts the shield for Strong enforcement. The
//    unlock-from-Gockyl path is `liftShield()`.
//
//  Everything degrades gracefully when authorization is missing, so the app
//  stays fully usable (with the local clock) before the entitlement is granted.
//

import Foundation
import Observation
import OSLog
import FamilyControls
import DeviceActivity
import ManagedSettings
import UserNotifications

@Observable
@MainActor
final class ScreenTimeService {
    /// Names shared with the DeviceActivityMonitor extension. Keep in sync with
    /// `activity-monitor/DeviceActivityMonitorExtension.swift`.
    enum Names {
        static let activity = DeviceActivityName("gockyl.monitoring")
        static func event(for stage: InterruptionStage) -> DeviceActivityEvent.Name {
            DeviceActivityEvent.Name("gockyl.stage.\(stage.rawValue)")
        }

        static let appGroup = "group.com.apple-challenge.gockyl-revamp"
        static let enforcementKey = "monitoring.enforcement"
        static let selectionKey = "monitoring.selection"
    }

    /// Whether the user has granted Family Controls authorization.
    private(set) var isAuthorized: Bool

    /// The apps the user chose to monitor. Bound to the system picker.
    var selection = FamilyActivitySelection()

    private let center = DeviceActivityCenter()
    private let store = ManagedSettingsStore()

    init() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
        } catch {
            isAuthorized = false
            AppLogger.session.error("Family Controls authorization failed: \(error)")
        }

        // The extension delivers the interruptions as notifications; permission
        // must be requested here in the app, so piggyback on this flow.
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    // MARK: - App selection persistence

    /// Serialises the current selection for storage on `FrogProfile`.
    func encodedSelection() -> Data? {
        try? JSONEncoder().encode(selection)
    }

    /// Restores a previously saved selection.
    func restoreSelection(from data: Data?) {
        guard let data,
              let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }
        selection = saved
    }

    /// How many apps/categories the user picked, for display.
    var selectionCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }

    // MARK: - Monitoring

    /// Schedules a daily monitoring interval with one usage-threshold event per
    /// stage of the ladder. DeviceActivity fires each event (in the extension)
    /// once the selected apps' combined usage crosses that stage's threshold.
    func startMonitoring(dailyLimit: TimeInterval, snoozeStep: TimeInterval, enforcement: Enforcement) {
        guard isAuthorized, selectionCount > 0 else {
            AppLogger.session.info("Monitoring not scheduled: authorized=\(self.isAuthorized), apps=\(self.selectionCount)")
            return
        }

        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        for stage in InterruptionStage.ladder(for: enforcement) {
            guard let threshold = stage.threshold(dailyLimit: dailyLimit, snoozeStep: snoozeStep) else { continue }
            // DeviceActivity thresholds have minute granularity; the "on open"
            // reminder is approximated by the smallest possible threshold.
            let minutes = max(1, Int(threshold / 60))
            events[Names.event(for: stage)] = DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: selection.webDomainTokens,
                threshold: DateComponents(minute: minutes)
            )
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        // Hand the extension what it needs to react: the enforcement level and
        // the selection to shield. It runs in its own process and can only see
        // this through the shared App Group container.
        let shared = UserDefaults(suiteName: Names.appGroup)
        shared?.set(enforcement.rawValue, forKey: Names.enforcementKey)
        shared?.set(encodedSelection(), forKey: Names.selectionKey)

        do {
            try center.startMonitoring(Names.activity, during: schedule, events: events)
        } catch {
            AppLogger.session.error("startMonitoring failed: \(error)")
        }
    }

    func stopMonitoring() {
        center.stopMonitoring([Names.activity])

        let shared = UserDefaults(suiteName: Names.appGroup)
        shared?.removeObject(forKey: Names.enforcementKey)
        shared?.removeObject(forKey: Names.selectionKey)
    }

    // MARK: - Shield (Strong enforcement)

    /// Blocks the selected apps immediately. In the final design this is
    /// triggered by the extension when the 100% event fires under Strong.
    func applyShield() {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
    }

    /// The unlock-from-Gockyl path: removes the shield.
    func liftShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
}
