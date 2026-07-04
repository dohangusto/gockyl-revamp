//
//  MonitoringSessionRepository.swift
//  gockyl-revamp
//
//  Abstracts persistence of Monitoring sessions behind a protocol, mirroring
//  `LockedInSessionRepository`. Kept separate because the two session kinds have
//  different shapes and analytics; the Statistics layer merges them.
//

import Foundation
import SwiftData

@MainActor
protocol MonitoringSessionRepositoryProtocol {
    func save(_ session: MonitoringSession) throws
    func allSessions() throws -> [MonitoringSession]
    func sessions(since date: Date) throws -> [MonitoringSession]
}

@MainActor
final class MonitoringSessionRepository: MonitoringSessionRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ session: MonitoringSession) throws {
        context.insert(session)
        try context.save()
    }

    func allSessions() throws -> [MonitoringSession] {
        let descriptor = FetchDescriptor<MonitoringSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func sessions(since date: Date) throws -> [MonitoringSession] {
        let descriptor = FetchDescriptor<MonitoringSession>(
            predicate: #Predicate { $0.startDate >= date },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
