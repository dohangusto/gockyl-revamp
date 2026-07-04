//
//  DeviceActivityMonitorExtension.swift
//  activity-monitor
//
//  Runs in a separate, memory-constrained process. The system calls it when a
//  usage threshold registered by the main app is crossed; it reacts by posting
//  the stage's interruption notification, updating the Live Activity, and —
//  under Strong enforcement at 100% — shielding the monitored apps.
//
//  Domain types (InterruptionStage, Enforcement, GockylActivityAttributes) come
//  from the Shared/ folder compiled into every target.
//
//  CONTRACT with the main app (see ScreenTimeService):
//  - Activity name:  "gockyl.monitoring"
//  - Event names:    "gockyl.stage.<InterruptionStage.rawValue>"
//  - Shared config:  App Group UserDefaults (group.com.apple-challenge.gockyl-revamp)
//      "monitoring.enforcement" : String (Enforcement.rawValue)
//      "monitoring.selection"   : Data (JSON FamilyActivitySelection)
//
//  Keep this file lean: no SwiftData, no app code — just react and exit.
//

import DeviceActivity
import FamilyControls
import ManagedSettings
import UserNotifications
import ActivityKit

// MARK: - Shared contract

private enum SharedConfig {
    static let appGroup = "group.com.apple-challenge.gockyl-revamp"
    static let enforcementKey = "monitoring.enforcement"
    static let selectionKey = "monitoring.selection"

    static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    static var enforcement: Enforcement {
        Enforcement(rawValue: defaults?.string(forKey: enforcementKey) ?? "") ?? .soft
    }

    static var selection: FamilyActivitySelection? {
        guard let data = defaults?.data(forKey: selectionKey) else { return nil }
        return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    }
}

private extension InterruptionStage {
    init?(eventName: DeviceActivityEvent.Name) {
        guard let raw = Int(eventName.rawValue.split(separator: ".").last ?? ""),
              let stage = InterruptionStage(rawValue: raw) else { return nil }
        self = stage
    }

    var notificationCopy: (title: String, body: String) {
        switch self {
        case .idle:
            ("", "")
        case .reminder:
            ("Gockyl is watching 🐸", "You just opened a monitored app. Stay mindful.")
        case .warmWarning:
            ("80% of your time is gone", "Gockyl says: maybe find a stopping point?")
        case .interruption:
            ("Time's up 🐸", "You reached your limit. Close the app and hop away.")
        case .snoozeFirst:
            ("Still scrolling?", "You're past your limit. Gockyl is disappointed.")
        case .snoozeSecond:
            ("STOP. Seriously.", "Way past the limit now. Put the phone down — Gockyl is not asking anymore.")
        }
    }
}

// MARK: - Monitor

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        guard let stage = InterruptionStage(eventName: event), stage != .idle else { return }

        notify(stage)
        updateLiveActivity(stage)

        // Strong enforcement blocks the apps exactly at 100%.
        if stage.shields(under: SharedConfig.enforcement) {
            applyShield()
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Day rolled over: lift any shield so tomorrow starts clean.
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    // MARK: - Reactions

    private func notify(_ stage: InterruptionStage) {
        let content = UNMutableNotificationContent()
        content.title = stage.notificationCopy.title
        content.body = stage.notificationCopy.body
        content.sound = .default
        content.interruptionLevel = stage >= .interruption ? .timeSensitive : .active

        let request = UNNotificationRequest(
            identifier: "gockyl.interruption.\(stage.rawValue)",
            content: content,
            trigger: nil  // deliver immediately
        )
        UNUserNotificationCenter.current().add(request)
    }

    /// Pushes the reached stage to the app's Live Activity so the island/lock
    /// screen escalate even when the app itself has been killed.
    private func updateLiveActivity(_ stage: InterruptionStage) {
        Task {
            for activity in Activity<GockylActivityAttributes>.activities {
                let content = ActivityContent(
                    state: GockylActivityAttributes.ContentState(stageRaw: stage.rawValue),
                    staleDate: nil
                )
                await activity.update(content)
            }
        }
    }

    private func applyShield() {
        guard let selection = SharedConfig.selection else { return }
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
    }
}
