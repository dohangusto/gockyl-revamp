//
//  FrogProfile.swift
//  gockyl-revamp
//
//  The player's single persistent profile: currency balance and which store
//  items they own / have equipped on the frog. There is exactly one of these.
//

import Foundation
import SwiftData

@Model
final class FrogProfile {
    /// Display name shown around the app.
    var name: String

    /// Soft-currency balance ("bugs") the frog has collected.
    var bugBalance: Int

    /// Catalog identifiers of every item the player has purchased.
    var ownedItemIDs: [String]

    /// Catalog identifier of the currently equipped item per category raw value.
    /// e.g. ["headwear": "black_beanie", "outfit": "black_jacket"]
    var equippedItemIDs: [String: String]

    /// Whether the first-run onboarding has been finished.
    var hasCompletedOnboarding: Bool

    init(
        name: String = "Gockyl",
        bugBalance: Int = 0,
        ownedItemIDs: [String] = [],
        equippedItemIDs: [String: String] = [:],
        hasCompletedOnboarding: Bool = false
    ) {
        self.name = name
        self.bugBalance = bugBalance
        self.ownedItemIDs = ownedItemIDs
        self.equippedItemIDs = equippedItemIDs
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}

extension FrogProfile {
    func owns(_ item: StoreItem) -> Bool {
        ownedItemIDs.contains(item.id)
    }

    func isEquipped(_ item: StoreItem) -> Bool {
        equippedItemIDs[item.category.rawValue] == item.id
    }
}
