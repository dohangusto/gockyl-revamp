//
//  AppEnvironment.swift
//  gockyl-revamp
//
//  A tiny composition root. It builds the concrete repositories from a
//  `ModelContext` and hands them to view models. Injecting this (rather than
//  reaching for singletons) keeps features decoupled and testable.
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class AppEnvironment {
    let lockedInSessionRepository: LockedInSessionRepositoryProtocol
    let monitoringSessionRepository: MonitoringSessionRepositoryProtocol
    let profileRepository: ProfileRepositoryProtocol
    let screenTimeService: ScreenTimeService
    let liveActivityService: LiveActivityService

    init(modelContext: ModelContext) {
        self.lockedInSessionRepository = LockedInSessionRepository(context: modelContext)
        self.monitoringSessionRepository = MonitoringSessionRepository(context: modelContext)
        self.profileRepository = ProfileRepository(context: modelContext)
        self.screenTimeService = ScreenTimeService()
        self.liveActivityService = LiveActivityService()
    }

    /// Designated initialiser for tests / previews that want to inject fakes.
    init(
        lockedInSessionRepository: LockedInSessionRepositoryProtocol,
        monitoringSessionRepository: MonitoringSessionRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        screenTimeService: ScreenTimeService,
        liveActivityService: LiveActivityService
    ) {
        self.lockedInSessionRepository = lockedInSessionRepository
        self.monitoringSessionRepository = monitoringSessionRepository
        self.profileRepository = profileRepository
        self.screenTimeService = screenTimeService
        self.liveActivityService = liveActivityService
    }
}
