//
//  GockylActivityAttributes.swift
//  Shared — compiled into the app, the activity-monitor extension, and the
//  widget extension, so every process agrees on the activity's shape.
//
//  The shape of Gockyl's Live Activity: static facts about the session in the
//  attributes, and only what actually changes (the interruption stage) in the
//  content state. Timers are rendered natively from dates so the activity does
//  not need per-second updates.
//

import Foundation
import ActivityKit

struct GockylActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// `InterruptionStage.rawValue` currently reached.
        var stageRaw: Int
    }

    /// `MonitoringMode.rawValue` for the running session.
    var modeRaw: String

    /// When the session started (drives an elapsed timer for Monitoring).
    var startDate: Date

    /// Locked-in: when the lock ends (drives a native countdown). Monitoring: nil.
    var endDate: Date?
}
