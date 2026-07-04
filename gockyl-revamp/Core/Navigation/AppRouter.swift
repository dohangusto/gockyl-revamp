//
//  AppRouter.swift
//  gockyl-revamp
//
//  Observable navigation state shared through the environment. Views push/pop
//  by mutating this instead of scattering NavigationLinks, which keeps deep
//  linking and programmatic navigation straightforward.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class AppRouter {
    /// The currently selected root tab.
    var selectedTab: AppTab = .home

    /// The push stack for the Home tab.
    var homePath = NavigationPath()

    func select(_ tab: AppTab) {
        selectedTab = tab
    }

    func push(_ route: AppRoute) {
        homePath.append(route)
    }

    func popToRoot() {
        homePath = NavigationPath()
    }
}
