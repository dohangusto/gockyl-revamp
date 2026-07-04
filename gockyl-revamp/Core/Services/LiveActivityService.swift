//
//  LiveActivityService.swift
//  gockyl-revamp
//
//  Owns the lifecycle of Gockyl's single Live Activity: started with the
//  session, updated only when the interruption stage changes (the clocks render
//  natively from dates), and ended with the session. Degrades to a no-op when
//  the user has Live Activities disabled.
//

import Foundation
import Observation
import OSLog
import ActivityKit

@Observable
@MainActor
final class LiveActivityService {
    private var activity: Activity<GockylActivityAttributes>?

    /// Starts the session's Live Activity (ends any stale one first).
    func start(mode: MonitoringMode, startDate: Date, duration: TimeInterval, stage: InterruptionStage) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        end()

        let attributes = GockylActivityAttributes(
            modeRaw: mode.rawValue,
            startDate: startDate,
            endDate: mode == .lockedIn ? startDate.addingTimeInterval(duration) : nil
        )
        let content = ActivityContent(
            state: GockylActivityAttributes.ContentState(stageRaw: stage.rawValue),
            staleDate: nil
        )

        do {
            activity = try Activity.request(attributes: attributes, content: content)
        } catch {
            AppLogger.session.error("Live Activity start failed: \(error)")
        }
    }

    /// Pushes a new stage to the activity. Cheap to call; only fires on change.
    func update(stage: InterruptionStage) {
        guard let activity else { return }
        let content = ActivityContent(
            state: GockylActivityAttributes.ContentState(stageRaw: stage.rawValue),
            staleDate: nil
        )
        Task { await activity.update(content) }
    }

    /// Ends and dismisses the activity immediately.
    func end() {
        guard let activity else { return }
        self.activity = nil
        Task {
            await activity.end(activity.content, dismissalPolicy: .immediate)
        }
    }
}
