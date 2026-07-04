//
//  widgetsLiveActivity.swift
//  widgets
//
//  Gockyl's Live Activity: the frog keeps watch from the Lock Screen and the
//  Dynamic Island while a session runs. Clocks render natively from the
//  attribute dates (no updates needed); only the interruption stage changes,
//  escalating the frog art and the caption.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Stage presentation
// Presentation for the shared `InterruptionStage` (Shared/MonitoringDomain.swift).

private struct StageInfo {
    let caption: String
    /// Which `frog_dynamicisland0x` frame to show — escalates with severity.
    let frame: Int
    let tint: Color

    init(raw: Int) {
        switch InterruptionStage(rawValue: raw) ?? .idle {
        case .idle:         self = .init(caption: "On watch", frame: 1, tint: .green)
        case .reminder:     self = .init(caption: "Just opened", frame: 2, tint: .green)
        case .warmWarning:  self = .init(caption: "80% used", frame: 3, tint: .yellow)
        case .interruption: self = .init(caption: "Limit reached", frame: 4, tint: .orange)
        case .snoozeFirst:  self = .init(caption: "Over the limit", frame: 5, tint: .red)
        case .snoozeSecond: self = .init(caption: "Way over. Stop.", frame: 5, tint: .red)
        }
    }

    private init(caption: String, frame: Int, tint: Color) {
        self.caption = caption
        self.frame = frame
        self.tint = tint
    }

    var imageName: String { "frog_dynamicisland0\(frame)" }
}

private extension GockylActivityAttributes {
    var isLockedIn: Bool { modeRaw == "lockedIn" }
    var title: String { isLockedIn ? "Locked-in" : "Monitoring" }
}

// MARK: - Shared pieces

/// The session clock: counts down to `endDate` for Locked-in, or up from
/// `startDate` for Monitoring. Rendered natively — no activity updates needed.
private struct SessionClock: View {
    let attributes: GockylActivityAttributes

    var body: some View {
        if let end = attributes.endDate {
            Text(timerInterval: attributes.startDate...end, countsDown: true)
        } else {
            Text(attributes.startDate, style: .timer)
        }
    }
}

private struct FrogBadge: View {
    let stage: StageInfo

    var body: some View {
        Image(stage.imageName)
            .resizable()
            .scaledToFit()
    }
}

// MARK: - Widget

struct widgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GockylActivityAttributes.self) { context in
            lockScreen(context)
        } dynamicIsland: { context in
            let stage = StageInfo(raw: context.state.stageRaw)

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    FrogBadge(stage: stage)
                        .frame(maxHeight: 56)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.title)
                            .font(.headline)
                        Text(context.attributes.isLockedIn ? "Stay focused" : stage.caption)
                            .font(.caption)
                            .foregroundStyle(stage.tint)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    SessionClock(attributes: context.attributes)
                        .font(.title3.monospacedDigit())
                        .frame(maxWidth: 64)
                        .multilineTextAlignment(.trailing)
                }
            } compactLeading: {
                FrogBadge(stage: stage)
            } compactTrailing: {
                SessionClock(attributes: context.attributes)
                    .font(.caption2.monospacedDigit())
                    .frame(maxWidth: 44)
                    .foregroundStyle(stage.tint)
            } minimal: {
                FrogBadge(stage: stage)
            }
            .keylineTint(stage.tint)
        }
    }

    // MARK: Lock Screen / banner

    @ViewBuilder
    private func lockScreen(_ context: ActivityViewContext<GockylActivityAttributes>) -> some View {
        let stage = StageInfo(raw: context.state.stageRaw)

        HStack(spacing: 12) {
            FrogBadge(stage: stage)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.title)
                    .font(.headline)
                Text(context.attributes.isLockedIn ? "Gockyl locked you in" : stage.caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                SessionClock(attributes: context.attributes)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .frame(maxWidth: 80)
                    .multilineTextAlignment(.trailing)
                Text(context.attributes.isLockedIn ? "left" : "used")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.6))
        .activitySystemActionForegroundColor(.white)
    }
}
