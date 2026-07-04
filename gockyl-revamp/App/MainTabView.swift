//
//  MainTabView.swift
//  gockyl-revamp
//
//  The root tab shell shown after onboarding. Uses the native `TabView`, which
//  on iOS 26 already renders as a floating Liquid Glass tab bar with the built-in
//  tab-switch effect. Each screen supplies its own large header via `AppScreen`.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab(AppTab.home.title, systemImage: AppTab.home.systemImage, value: AppTab.home) {
                HomeView(viewModel: HomeViewModel(
                    profileRepository: environment.profileRepository,
                    lockedInRepository: environment.lockedInSessionRepository,
                    monitoringRepository: environment.monitoringSessionRepository,
                    screenTime: environment.screenTimeService,
                    liveActivity: environment.liveActivityService
                ))
            }

            Tab(AppTab.statistics.title, systemImage: AppTab.statistics.systemImage, value: AppTab.statistics) {
                StatisticsView(viewModel: StatisticsViewModel(
                    lockedInRepository: environment.lockedInSessionRepository,
                    monitoringRepository: environment.monitoringSessionRepository
                ))
            }

            Tab(AppTab.store.title, systemImage: AppTab.store.systemImage, value: AppTab.store) {
                StoreView(viewModel: StoreViewModel(profileRepository: environment.profileRepository))
            }

            Tab(AppTab.settings.title, systemImage: AppTab.settings.systemImage, value: AppTab.settings) {
                SettingsView(viewModel: SettingsViewModel(
                    profileRepository: environment.profileRepository,
                    screenTime: environment.screenTimeService
                ))
            }
        }
        .tint(AppColor.accent)
    }
}
