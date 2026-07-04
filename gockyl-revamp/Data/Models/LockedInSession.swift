//
//  LockedInSession.swift
//  gockyl-revamp
//
//  One record of the "Locked-in" productive mode: the phone was locked for a
//  committed duration and the user tried to stay put. Persisted with SwiftData;
//  a row is created when the user starts a lock and finalised when it stops.
//
//  (Evolved from the boilerplate's `FocusSession`.)
//

import Foundation
import SwiftData

@Model
final class LockedInSession {
    /// Stable identifier, handy for diffing and analytics.
    @Attribute(.unique) var id: UUID

    /// When the user started the lock.
    var startDate: Date

    /// Length the user committed to, in seconds.
    var plannedDuration: TimeInterval

    /// How long the user actually stayed locked in, in seconds.
    var actualDuration: TimeInterval

    /// `true` when the lock ran to completion instead of being cancelled early.
    var isCompleted: Bool

    /// Soft currency ("flies") awarded for this session.
    var fliesEarned: Int

    init(
        id: UUID = UUID(),
        startDate: Date = .now,
        plannedDuration: TimeInterval,
        actualDuration: TimeInterval = 0,
        isCompleted: Bool = false,
        fliesEarned: Int = 0
    ) {
        self.id = id
        self.startDate = startDate
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.isCompleted = isCompleted
        self.fliesEarned = fliesEarned
    }
}

extension LockedInSession {
    /// Fraction of the planned time actually spent locked in, clamped to 0...1.
    var completionRatio: Double {
        guard plannedDuration > 0 else { return 0 }
        return min(actualDuration / plannedDuration, 1)
    }
}
