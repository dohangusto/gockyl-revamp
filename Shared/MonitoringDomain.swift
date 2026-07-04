//
//  MonitoringDomain.swift
//  gockyl-revamp
//
//  Pure domain value types that describe *how* Gockyl watches over the user.
//  These are deliberately free of any Apple framework (FamilyControls,
//  DeviceActivity, ManagedSettings, ActivityKit) so the rules can be reasoned
//  about and unit-tested in isolation; the platform integration maps onto them
//  later.
//

import Foundation

/// The top-level thing Gockyl is doing right now.
enum MonitoringMode: String, CaseIterable, Identifiable, Hashable {
    /// Productive mode: no monitoring, the phone is locked for a set duration
    /// and only the remaining time is shown. There are no interruption stages.
    case lockedIn
    /// Watches chosen apps' usage and interrupts the user in escalating stages.
    case monitoring

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lockedIn: "Locked-in"
        case .monitoring: "Monitoring"
        }
    }
}

/// How firmly the Monitoring mode reacts once the limit is reached.
enum Enforcement: String, CaseIterable, Identifiable, Hashable {
    /// Interruptions only — the app is never blocked.
    case soft
    /// Blocks (shields) the app the moment the limit is hit.
    case strong

    var id: String { rawValue }

    var title: String {
        switch self {
        case .soft: "Soft"
        case .strong: "Strong"
        }
    }
}

/// The escalating stages of a monitoring session, ordered by severity.
///
/// Because Apple exposes no real-time scroll count, each stage is realised as a
/// `DeviceActivityMonitor` usage threshold; the extension advances `stage` as
/// each threshold fires. `rawValue` order is the severity order.
enum InterruptionStage: Int, CaseIterable, Comparable, Hashable {
    case idle          // below the first threshold / not opened yet
    case reminder      // on first open of a monitored app (0% of limit)
    case warmWarning   // 80% of the limit
    case interruption  // 100% of the limit
    case snoozeFirst   // one snooze step past the limit
    case snoozeSecond  // two snooze steps past the limit

    nonisolated static func < (lhs: InterruptionStage, rhs: InterruptionStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension InterruptionStage {
    /// Human-readable name for the stage.
    var title: String {
        switch self {
        case .idle:          "Idle"
        case .reminder:      "Reminder"
        case .warmWarning:   "Warm warning"
        case .interruption:  "Interruption"
        case .snoozeFirst:   "Snooze"
        case .snoozeSecond:  "Final warning"
        }
    }

    /// Elapsed monitored-app usage (in seconds) at which this stage should fire,
    /// given the user's daily limit and snooze step. `nil` for `.idle`.
    func threshold(dailyLimit: TimeInterval, snoozeStep: TimeInterval) -> TimeInterval? {
        switch self {
        case .idle:          nil
        case .reminder:      0
        case .warmWarning:   dailyLimit * 0.8
        case .interruption:  dailyLimit
        case .snoozeFirst:   dailyLimit + snoozeStep
        case .snoozeSecond:  dailyLimit + snoozeStep * 2
        }
    }

    /// The stages that actually apply under a given enforcement, in order.
    /// Strong stops at 100% (the app is shielded there); the snooze ladder only
    /// exists in Soft.
    static func ladder(for enforcement: Enforcement) -> [InterruptionStage] {
        switch enforcement {
        case .soft:   [.reminder, .warmWarning, .interruption, .snoozeFirst, .snoozeSecond]
        case .strong: [.reminder, .warmWarning, .interruption]
        }
    }

    /// Whether reaching this stage under the given enforcement should shield the
    /// app. Only Strong shields, and it does so exactly at 100%.
    func shields(under enforcement: Enforcement) -> Bool {
        enforcement == .strong && self == .interruption
    }
}

/// Which frog art to show. Derived from whether a session is active — never
/// persisted. Sleeping = off duty; on duty = actively monitoring / locked in.
enum FrogState: Hashable {
    case sleeping
    case onDuty
}
