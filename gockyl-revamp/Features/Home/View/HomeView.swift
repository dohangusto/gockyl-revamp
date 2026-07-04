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
            AppScreen("Gockyl") {
                MaterialBadge(systemImage: "ladybug.fill", text: "\(viewModel.bugBalance)")
            } content: {
                VStack(spacing: AppSpacing.xl) {
                    Spacer(minLength: AppSpacing.lg)

                    Image("gockyl_frog_idle")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .accessibilityLabel("Gockyl the frog")

                    Spacer(minLength: AppSpacing.lg)

                    durationPicker

                    PrimaryButton(title: "Start Focus") {
                        router.push(.focusTimer(minutes: viewModel.selectedMinutes))
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, FloatingTabBar.clearance)
                .frame(maxHeight: .infinity)
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .navigationDestination(for: AppRoute.self, destination: destination)
            .onAppear { viewModel.refresh() }
        }
    }

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Focus for")
                .font(AppFont.caption)
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
