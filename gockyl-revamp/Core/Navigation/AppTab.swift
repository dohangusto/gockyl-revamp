//
//  AppTab.swift
//  gockyl-revamp
//
//  The top-level tabs shown once onboarding is complete. Modelling them as an
//  enum keeps tab selection type-safe and centralised.
//

import Foundation

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
