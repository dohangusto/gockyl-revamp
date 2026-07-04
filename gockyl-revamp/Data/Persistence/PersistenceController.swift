//
//  PersistenceController.swift
//  gockyl-revamp
//
//  Owns the SwiftData stack. Centralising container creation keeps the app
//  entry point thin and gives tests / previews an in-memory variant.
//

import Foundation
import SwiftData

enum PersistenceController {
    /// Every `@Model` type that participates in the store.
    static let schema = Schema([
        FocusSession.self,
        FrogProfile.self,
    ])

    /// The on-disk container used by the running app.
    static func makeContainer() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    /// An ephemeral container for SwiftUI previews and unit tests.
    static func makePreviewContainer() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let profile = FrogProfile(bugBalance: 500, hasCompletedOnboarding: true)
            container.mainContext.insert(profile)
            return container
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }
}
