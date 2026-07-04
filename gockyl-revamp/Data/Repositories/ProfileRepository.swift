//
//  ProfileRepository.swift
//  gockyl-revamp
//
//  Loads and mutates the single `FrogProfile`. Encapsulates the "fetch-or-create"
//  rule so every feature sees exactly one profile.
//

import Foundation
import SwiftData

@MainActor
protocol ProfileRepositoryProtocol {
    /// Returns the existing profile, creating and persisting one on first launch.
    func currentProfile() throws -> FrogProfile
    func save() throws
}

@MainActor
final class ProfileRepository: ProfileRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func currentProfile() throws -> FrogProfile {
        let descriptor = FetchDescriptor<FrogProfile>()
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let profile = FrogProfile()
        context.insert(profile)
        try context.save()
        return profile
    }

    func save() throws {
        try context.save()
    }
}
