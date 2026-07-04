//
//  FocusSession.swift
//  gockyl-revamp
//
//  A single focus session persisted with SwiftData. One row is created every
//  time the user starts a focus timer and is finalised when it stops.
//

import Foundation
import SwiftData

@Model
final class FocusSession {
    /// Stable identifier, handy for diffing and analytics.
    @Attribute(.unique) var id: UUID

    /// When the user pressed "Start".
    var startDate: Date

    /// Length the user committed to, in seconds.
    var plannedDuration: TimeInterval

    /// How long the user actually stayed focused, in seconds.
    var focusedDuration: TimeInterval

    /// `true` when the session ran to completion instead of being cancelled.
    var isCompleted: Bool

    /// Soft currency awarded for this session.
    var bugsEarned: Int

    init(
        id: UUID = UUID(),
        startDate: Date = .now,
        plannedDuration: TimeInterval,
        focusedDuration: TimeInterval = 0,
        isCompleted: Bool = false,
        bugsEarned: Int = 0
    ) {
        self.id = id
        self.startDate = startDate
        self.plannedDuration = plannedDuration
        self.focusedDuration = focusedDuration
        self.isCompleted = isCompleted
        self.bugsEarned = bugsEarned
    }
}

extension FocusSession {
    /// Fraction of the planned time that was actually focused, clamped to 0...1.
    var completionRatio: Double {
        guard plannedDuration > 0 else { return 0 }
        return min(focusedDuration / plannedDuration, 1)
    }
}
