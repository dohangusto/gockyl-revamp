//
//  StoreItem.swift
//  gockyl-revamp
//
//  Static catalog of purchasable cosmetics. This is content, not user state, so
//  it is modelled as a plain value type rather than a SwiftData entity — the
//  player's *ownership* of these lives on `FrogProfile`.
//

import Foundation

struct StoreItem: Identifiable, Hashable {
    enum Category: String, CaseIterable, Hashable {
        case headwear
        case outfit

        var title: String {
            switch self {
            case .headwear: "Headwear"
            case .outfit: "Outfit"
            }
        }
    }

    let id: String          // matches the asset name in Assets.xcassets
    let displayName: String
    let category: Category
    let price: Int
}

extension StoreItem {
    /// The catalog shipped with the app. Kept in one place so the store, the
    /// room renderer, and previews all agree on what exists.
    static let catalog: [StoreItem] = [
        StoreItem(id: "black_beanie", displayName: "Black Beanie", category: .headwear, price: 120),
        StoreItem(id: "blue_hat", displayName: "Blue Hat", category: .headwear, price: 150),
        StoreItem(id: "black_jacket", displayName: "Black Jacket", category: .outfit, price: 200),
        StoreItem(id: "green_shirt", displayName: "Green Shirt", category: .outfit, price: 90),
    ]

    static func items(in category: Category) -> [StoreItem] {
        catalog.filter { $0.category == category }
    }
}
