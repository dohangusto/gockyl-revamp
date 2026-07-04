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

    /// Soft-currency balance the frog has collected. Shown in the UI as "flies"
    /// (lalat); flies and bugs are the same single currency.
    var bugBalance: Int

    /// Catalog identifiers of every item the player has purchased.
    var ownedItemIDs: [String]

    /// Catalog identifier of the currently equipped item per category raw value.
    /// e.g. ["headwear": "black_beanie", "outfit": "black_jacket"]
    var equippedItemIDs: [String: String]

    /// Whether the first-run onboarding has been finished.
    var hasCompletedOnboarding: Bool

    // MARK: - Monitoring configuration
    // Enums are stored as raw values so SwiftData can persist them; typed
    // accessors live in the extension below.

    /// Backing store for `monitoringMode`.
    var monitoringModeRaw: String

    /// Backing store for `enforcement` (used by Monitoring mode).
    var enforcementRaw: String

    /// Scroll-time limit for Monitoring mode, in seconds. Default 10 minutes.
    var dailyLimit: TimeInterval

    /// How long the phone stays locked in Locked-in mode, in seconds.
    var lockedInDuration: TimeInterval

    /// Gap between snooze stages in Monitoring mode, in seconds. Default 2 min.
    var snoozeStep: TimeInterval

    /// Opaque `FamilyActivitySelection` token for the apps the user chose to
    /// monitor. `nil` until the user picks apps via the system picker.
    var selectedAppsToken: Data?

    init(
        name: String = "Gockyl",
        bugBalance: Int = 0,
        ownedItemIDs: [String] = [],
        equippedItemIDs: [String: String] = [:],
        hasCompletedOnboarding: Bool = false,
        monitoringMode: MonitoringMode = .monitoring,
        enforcement: Enforcement = .soft,
        dailyLimit: TimeInterval = 600,
        lockedInDuration: TimeInterval = 1500,
        snoozeStep: TimeInterval = 120,
        selectedAppsToken: Data? = nil
    ) {
        self.name = name
        self.bugBalance = bugBalance
        self.ownedItemIDs = ownedItemIDs
        self.equippedItemIDs = equippedItemIDs
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.monitoringModeRaw = monitoringMode.rawValue
        self.enforcementRaw = enforcement.rawValue
        self.dailyLimit = dailyLimit
        self.lockedInDuration = lockedInDuration
        self.snoozeStep = snoozeStep
        self.selectedAppsToken = selectedAppsToken
    }
}

extension FrogProfile {
    func owns(_ item: StoreItem) -> Bool {
        ownedItemIDs.contains(item.id)
    }

    func isEquipped(_ item: StoreItem) -> Bool {
        equippedItemIDs[item.category.rawValue] == item.id
    }

    /// The active monitoring mode, as a typed value.
    var monitoringMode: MonitoringMode {
        get { MonitoringMode(rawValue: monitoringModeRaw) ?? .monitoring }
        set { monitoringModeRaw = newValue.rawValue }
    }

    /// The enforcement level used by Monitoring mode.
    var enforcement: Enforcement {
        get { Enforcement(rawValue: enforcementRaw) ?? .soft }
        set { enforcementRaw = newValue.rawValue }
    }
}
