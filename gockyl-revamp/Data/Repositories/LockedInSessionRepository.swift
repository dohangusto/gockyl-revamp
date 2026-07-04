//
//  LockedInSessionRepository.swift
//  gockyl-revamp
//
//  Abstracts persistence of Locked-in sessions behind a protocol so view models
//  depend on an interface, not on SwiftData directly — which is what makes them
//  unit-testable with an in-memory or mock repository.
//

import Foundation
import SwiftData

@MainActor
protocol LockedInSessionRepositoryProtocol {
    func save(_ session: LockedInSession) throws
    func allSessions() throws -> [LockedInSession]
    func sessions(since date: Date) throws -> [LockedInSession]
}

@MainActor
final class LockedInSessionRepository: LockedInSessionRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ session: LockedInSession) throws {
        context.insert(session)
        try context.save()
    }

    func allSessions() throws -> [LockedInSession] {
        let descriptor = FetchDescriptor<LockedInSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func sessions(since date: Date) throws -> [LockedInSession] {
        let descriptor = FetchDescriptor<LockedInSession>(
            predicate: #Predicate { $0.startDate >= date },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
