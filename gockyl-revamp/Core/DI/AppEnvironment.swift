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
    let focusSessionRepository: FocusSessionRepositoryProtocol
    let profileRepository: ProfileRepositoryProtocol

    init(modelContext: ModelContext) {
        self.focusSessionRepository = FocusSessionRepository(context: modelContext)
        self.profileRepository = ProfileRepository(context: modelContext)
    }

    /// Designated initialiser for tests / previews that want to inject fakes.
    init(
        focusSessionRepository: FocusSessionRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.focusSessionRepository = focusSessionRepository
        self.profileRepository = profileRepository
    }
}
