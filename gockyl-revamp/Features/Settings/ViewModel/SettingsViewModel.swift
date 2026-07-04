//
//  SettingsViewModel.swift
//  gockyl-revamp
//
//  Exposes editable profile settings and app metadata.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class SettingsViewModel {
    var frogName: String = ""

    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    func refresh() {
        do {
            frogName = try profileRepository.currentProfile().name
        } catch {
            AppLogger.persistence.error("Settings refresh failed: \(error)")
        }
    }

    func commitName() {
        let trimmed = frogName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            let profile = try profileRepository.currentProfile()
            profile.name = trimmed
            try profileRepository.save()
        } catch {
            AppLogger.persistence.error("Name update failed: \(error)")
        }
    }
}
