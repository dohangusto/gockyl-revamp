//
//  StatisticsView.swift
//  gockyl-revamp
//
//  Summary cards plus a list of recent focus sessions.
//

import SwiftUI

struct StatisticsView: View {
    @State private var viewModel: StatisticsViewModel

    init(viewModel: StatisticsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AppScreen("Statistics") {
            List {
                Section {
                    HStack(spacing: AppSpacing.md) {
                        StatCard(title: "Sessions", value: "\(viewModel.totalSessions)")
                        StatCard(title: "Focused", value: viewModel.totalFocusedTime.compactString)
                        StatCard(
                            title: "Completion",
                            value: viewModel.completionRate.formatted(.percent.precision(.fractionLength(0)))
                        )
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Recent") {
                    if viewModel.recentSessions.isEmpty {
                        Text("No sessions yet. Start focusing!")
                            .foregroundStyle(AppColor.secondaryText)
                    } else {
                        ForEach(viewModel.recentSessions) { session in
                            SessionRow(session: session)
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.refresh() }
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFont.title)
                .foregroundStyle(AppColor.text)
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

private struct SessionRow: View {
    let session: FocusSession

    var body: some View {
        HStack {
            Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(session.isCompleted ? AppColor.accent : AppColor.secondaryText)
            VStack(alignment: .leading) {
                Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(AppFont.body)
                Text(session.focusedDuration.compactString)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.secondaryText)
            }
            Spacer()
            Text("+\(session.bugsEarned) 🐛")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.secondaryText)
        }
    }
}
