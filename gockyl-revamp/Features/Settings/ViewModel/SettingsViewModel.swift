//
//  SettingsViewModel.swift
//  gockyl-revamp
//
//  Exposes editable profile settings — the frog's name plus how Gockyl watches
//  over the user (mode, enforcement, and the various time limits) — and app
//  metadata. All mutations are persisted immediately through the repository.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class SettingsViewModel {
    var frogName: String = ""

    // Backing storage loaded in `refresh()`; the computed properties below
    // persist any change straight away so the view can bind to them via
    // `@Bindable` and read naturally.
    private var mode: MonitoringMode = .monitoring
    private var enforcementLevel: Enforcement = .soft
    private var dailyLimitSeconds: TimeInterval = 600
    private var lockedInSeconds: TimeInterval = 1500

    private let profileRepository: ProfileRepositoryProtocol
    let screenTime: ScreenTimeService

    init(profileRepository: ProfileRepositoryProtocol, screenTime: ScreenTimeService) {
        self.profileRepository = profileRepository
        self.screenTime = screenTime
    }

    // MARK: - Screen Time

    /// Asks the system for Family Controls authorization.
    func requestScreenTimeAccess() async {
        await screenTime.requestAuthorization()
    }

    /// Persists the picker's selection onto the profile.
    func commitAppSelection() {
        persist { $0.selectedAppsToken = screenTime.encodedSelection() }
    }

    // MARK: - Monitoring configuration

    var monitoringMode: MonitoringMode {
        get { mode }
        set { mode = newValue; persist { $0.monitoringMode = newValue } }
    }

    var enforcement: Enforcement {
        get { enforcementLevel }
        set { enforcementLevel = newValue; persist { $0.enforcement = newValue } }
    }

    /// Monitoring scroll-time limit, exposed in whole minutes for the stepper.
    var dailyLimitMinutes: Int {
        get { Int(dailyLimitSeconds / 60) }
        set {
            let clamped = max(1, min(newValue, 240))
            dailyLimitSeconds = TimeInterval(clamped * 60)
            persist { $0.dailyLimit = self.dailyLimitSeconds }
        }
    }

    /// Locked-in duration, exposed in whole minutes for the stepper.
    var lockedInMinutes: Int {
        get { Int(lockedInSeconds / 60) }
        set {
            let clamped = max(5, min(newValue, 480))
            lockedInSeconds = TimeInterval(clamped * 60)
            persist { $0.lockedInDuration = self.lockedInSeconds }
        }
    }

    /// Whether enforcement applies — only Monitoring mode uses soft/strong.
    var isMonitoring: Bool { mode == .monitoring }

    // MARK: - App metadata

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Lifecycle

    func refresh() {
        do {
            let profile = try profileRepository.currentProfile()
            frogName = profile.name
            mode = profile.monitoringMode
            enforcementLevel = profile.enforcement
            dailyLimitSeconds = profile.dailyLimit
            lockedInSeconds = profile.lockedInDuration
            screenTime.restoreSelection(from: profile.selectedAppsToken)
        } catch {
            AppLogger.persistence.error("Settings refresh failed: \(error)")
        }
    }

    func commitName() {
        let trimmed = frogName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        persist { $0.name = trimmed }
    }

    // MARK: - Private

    /// Applies a mutation to the single profile and saves it.
    private func persist(_ mutate: (FrogProfile) -> Void) {
        do {
            let profile = try profileRepository.currentProfile()
            mutate(profile)
            try profileRepository.save()
        } catch {
            AppLogger.persistence.error("Settings update failed: \(error)")
        }
    }
}
