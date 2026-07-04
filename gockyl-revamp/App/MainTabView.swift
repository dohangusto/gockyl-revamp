//
//  MainTabView.swift
//  gockyl-revamp
//
//  The root tab shell shown after onboarding. It keeps a native `TabView` so
//  each tab preserves its own navigation state, but hides the default tab bar
//  and overlays a floating capsule navigation instead.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            HomeView(viewModel: HomeViewModel(profileRepository: environment.profileRepository))
                .tag(AppTab.home)

            StatisticsView(viewModel: StatisticsViewModel(sessionRepository: environment.focusSessionRepository))
                .tag(AppTab.statistics)

            StoreView(viewModel: StoreViewModel(profileRepository: environment.profileRepository))
                .tag(AppTab.store)

            SettingsView(viewModel: SettingsViewModel(profileRepository: environment.profileRepository))
                .tag(AppTab.settings)
        }
        .toolbar(.hidden, for: .tabBar)
        .overlay(alignment: .bottom) {
            if showsFloatingBar {
                FloatingTabBar(selection: $router.selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.25), value: showsFloatingBar)
        .tint(AppColor.accent)
    }

    /// Hidden while a Home detail (e.g. a focus session) is pushed, so those
    /// screens stay immersive.
    private var showsFloatingBar: Bool {
        !(router.selectedTab == .home && !router.homePath.isEmpty)
    }
}
