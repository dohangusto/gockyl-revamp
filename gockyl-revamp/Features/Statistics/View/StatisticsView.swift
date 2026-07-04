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
                        StatCard(title: "Locked-in", value: viewModel.lockedInTime.compactString)
                        StatCard(title: "Limit hits", value: "\(viewModel.limitHits)")
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Recent") {
                    if viewModel.recent.isEmpty {
                        Text("No sessions yet. Start one from Home!")
                            .foregroundStyle(AppColor.secondaryText)
                    } else {
                        ForEach(viewModel.recent) { item in
                            SessionRow(item: item)
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
    let item: StatisticsViewModel.RecentItem

    var body: some View {
        HStack {
            Image(systemName: item.symbol)
                .foregroundStyle(item.isPositive ? AppColor.accent : AppColor.secondaryText)
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(AppFont.body)
                Text("\(item.detail) · \(item.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.secondaryText)
            }
            Spacer()
            if item.flies > 0 {
                Text("+\(item.flies) 🪰")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.secondaryText)
            }
        }
    }
}
