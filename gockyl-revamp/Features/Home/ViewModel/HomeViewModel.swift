//
//  HomeViewModel.swift
//  gockyl-revamp
//
//  Backs the room screen: exposes the frog's bug balance and the user's chosen
//  session length. Reads the profile through a repository, never SwiftData.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class HomeViewModel {
    private(set) var bugBalance: Int = 0

    /// Selectable focus lengths, in minutes.
    let durationOptions: [Int] = [15, 25, 45, 60]
    var selectedMinutes: Int = 25

    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    func refresh() {
        do {
            bugBalance = try profileRepository.currentProfile().bugBalance
        } catch {
            AppLogger.persistence.error("Home refresh failed: \(error)")
        }
    }
}
