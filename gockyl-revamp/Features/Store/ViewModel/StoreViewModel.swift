//
//  StoreViewModel.swift
//  gockyl-revamp
//
//  Presents the cosmetics catalog and handles purchase / equip rules against
//  the player's profile and bug balance.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class StoreViewModel {
    enum PurchaseResult {
        case purchased
        case insufficientFunds
        case alreadyOwned
    }

    private(set) var bugBalance: Int = 0
    private(set) var ownedItemIDs: Set<String> = []
    private(set) var equippedItemIDs: [String: String] = [:]

    let categories = StoreItem.Category.allCases

    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func refresh() {
        do {
            let profile = try profileRepository.currentProfile()
            bugBalance = profile.bugBalance
            ownedItemIDs = Set(profile.ownedItemIDs)
            equippedItemIDs = profile.equippedItemIDs
        } catch {
            AppLogger.store.error("Store refresh failed: \(error)")
        }
    }

    func items(in category: StoreItem.Category) -> [StoreItem] {
        StoreItem.items(in: category)
    }

    func isOwned(_ item: StoreItem) -> Bool { ownedItemIDs.contains(item.id) }
    func isEquipped(_ item: StoreItem) -> Bool { equippedItemIDs[item.category.rawValue] == item.id }

    @discardableResult
    func purchase(_ item: StoreItem) -> PurchaseResult {
        guard !isOwned(item) else { return .alreadyOwned }
        guard bugBalance >= item.price else { return .insufficientFunds }

        do {
            let profile = try profileRepository.currentProfile()
            profile.bugBalance -= item.price
            profile.ownedItemIDs.append(item.id)
            try profileRepository.save()
            refresh()
            return .purchased
        } catch {
            AppLogger.store.error("Purchase failed: \(error)")
            return .insufficientFunds
        }
    }

    func equip(_ item: StoreItem) {
        guard isOwned(item) else { return }
        do {
            let profile = try profileRepository.currentProfile()
            profile.equippedItemIDs[item.category.rawValue] = item.id
            try profileRepository.save()
            refresh()
        } catch {
            AppLogger.store.error("Equip failed: \(error)")
        }
    }
}
