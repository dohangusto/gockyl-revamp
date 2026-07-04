//
//  MainTabView.swift
//  gockyl-revamp
//
//  The root tab shell shown after onboarding. Each tab constructs its feature
//  view with a view model wired to the shared repositories.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            HomeView(viewModel: HomeViewModel(profileRepository: environment.profileRepository))
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.systemImage) }
                .tag(AppTab.home)

            StatisticsView(viewModel: StatisticsViewModel(sessionRepository: environment.focusSessionRepository))
                .tabItem { Label(AppTab.statistics.title, systemImage: AppTab.statistics.systemImage) }
                .tag(AppTab.statistics)

            StoreView(viewModel: StoreViewModel(profileRepository: environment.profileRepository))
                .tabItem { Label(AppTab.store.title, systemImage: AppTab.store.systemImage) }
                .tag(AppTab.store)

            SettingsView(viewModel: SettingsViewModel(profileRepository: environment.profileRepository))
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
                .tag(AppTab.settings)
        }
        .tint(AppColor.accent)
    }
}
