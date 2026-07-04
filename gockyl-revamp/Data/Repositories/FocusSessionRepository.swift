//
//  FocusSessionRepository.swift
//  gockyl-revamp
//
//  Abstracts persistence of focus sessions behind a protocol so view models
//  depend on an interface, not on SwiftData directly. This is what makes the
//  view models unit-testable with an in-memory or mock repository.
//

import Foundation
import SwiftData

@MainActor
protocol FocusSessionRepositoryProtocol {
    func save(_ session: FocusSession) throws
    func allSessions() throws -> [FocusSession]
    func sessions(since date: Date) throws -> [FocusSession]
}

@MainActor
final class FocusSessionRepository: FocusSessionRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ session: FocusSession) throws {
        context.insert(session)
        try context.save()
    }

    func allSessions() throws -> [FocusSession] {
        let descriptor = FetchDescriptor<FocusSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func sessions(since date: Date) throws -> [FocusSession] {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.startDate >= date },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
