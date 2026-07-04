//
//  AppRoute.swift
//  gockyl-revamp
//
//  The set of destinations the app can navigate to. Modelling routes as an
//  enum keeps navigation type-safe and centralised.
//

import Foundation

/// The top-level tabs shown once onboarding is complete.
enum AppTab: String, CaseIterable, Identifiable {
    case home
    case statistics
    case store
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .statistics: "Stats"
        case .store: "Store"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .statistics: "chart.bar.fill"
        case .store: "bag.fill"
        case .settings: "gearshape.fill"
        }
    }
}

/// Pushed destinations within a navigation stack.
enum AppRoute: Hashable {
    case focusTimer(minutes: Int)
    case sessionSummary(sessionID: UUID)
}
