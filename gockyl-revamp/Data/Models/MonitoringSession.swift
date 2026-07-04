//
//  MonitoringSession.swift
//  gockyl-revamp
//
//  One record of the "Monitoring" mode: Gockyl watched the user's chosen apps
//  against a daily limit and interrupted in escalating stages. Persisted with
//  SwiftData; finalised when monitoring stops (or the day rolls over).
//

import Foundation
import SwiftData

@Model
final class MonitoringSession {
    /// Stable identifier, handy for diffing and analytics.
    @Attribute(.unique) var id: UUID

    /// When monitoring started.
    var startDate: Date

    /// Backing store for `enforcement`; SwiftData persists the raw value.
    var enforcementRaw: String

    /// The scroll-time limit the user set for this session, in seconds.
    var dailyLimit: TimeInterval

    /// Highest `InterruptionStage.rawValue` reached during the session.
    var highestStageReached: Int

    /// `true` only when Strong enforcement shielded the app (limit hit at 100%).
    var wasShielded: Bool

    /// Soft currency ("flies") awarded for staying within limits.
    var fliesEarned: Int

    init(
        id: UUID = UUID(),
        startDate: Date = .now,
        enforcement: Enforcement = .soft,
        dailyLimit: TimeInterval,
        highestStageReached: Int = InterruptionStage.idle.rawValue,
        wasShielded: Bool = false,
        fliesEarned: Int = 0
    ) {
        self.id = id
        self.startDate = startDate
        self.enforcementRaw = enforcement.rawValue
        self.dailyLimit = dailyLimit
        self.highestStageReached = highestStageReached
        self.wasShielded = wasShielded
        self.fliesEarned = fliesEarned
    }
}

extension MonitoringSession {
    var enforcement: Enforcement {
        get { Enforcement(rawValue: enforcementRaw) ?? .soft }
        set { enforcementRaw = newValue.rawValue }
    }

    /// The highest stage reached, as a typed value.
    var highestStage: InterruptionStage {
        InterruptionStage(rawValue: highestStageReached) ?? .idle
    }

    /// `true` when the user was interrupted at least once (reached the limit).
    var didReachLimit: Bool {
        highestStage >= .interruption
    }
}
