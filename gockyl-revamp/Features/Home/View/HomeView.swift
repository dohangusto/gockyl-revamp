//
//  HomeView.swift
//  gockyl-revamp
//
//  The frog's room and the entry point into a focus session. Hosts the Home
//  navigation stack and resolves pushed routes into their screens.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Environment(AppRouter.self) private var router
    @Environment(AppEnvironment.self) private var environment

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.homePath) {
            VStack(spacing: AppSpacing.xl) {
                bugCounter

                Image("gockyl_frog_idle")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .accessibilityLabel("Gockyl the frog")

                durationPicker

                PrimaryButton(title: "Start Focus") {
                    router.push(.focusTimer(minutes: viewModel.selectedMinutes))
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding()
            .frame(maxHeight: .infinity)
            .navigationTitle("Gockyl")
            .navigationDestination(for: AppRoute.self, destination: destination)
            .onAppear { viewModel.refresh() }
        }
    }

    private var bugCounter: some View {
        Label("\(viewModel.bugBalance)", systemImage: "ladybug.fill")
            .font(AppFont.title)
            .foregroundStyle(AppColor.text)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var durationPicker: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Focus for")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.secondaryText)

            Picker("Duration", selection: $viewModel.selectedMinutes) {
                ForEach(viewModel.durationOptions, id: \.self) { minutes in
                    Text("\(minutes)m").tag(minutes)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case let .focusTimer(minutes):
            FocusTimerView(
                viewModel: FocusTimerViewModel(
                    minutes: minutes,
                    sessionRepository: environment.focusSessionRepository,
                    profileRepository: environment.profileRepository
                )
            )
        case .sessionSummary:
            EmptyView()
        }
    }
}
