//
//  GockylApp.swift
//  gockyl-revamp
//
//  Application entry point. Its only jobs are to own the SwiftData container
//  and hand control to `RootView`; everything else is composed further down.
//

import SwiftUI
import SwiftData

@main
struct GockylApp: App {
    private let modelContainer = PersistenceController.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
