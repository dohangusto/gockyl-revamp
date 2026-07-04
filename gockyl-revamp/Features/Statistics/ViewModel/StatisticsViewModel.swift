//
//  StatisticsViewModel.swift
//  gockyl-revamp
//
//  Aggregates both session kinds — Locked-in and Monitoring — into the numbers
//  and the unified recent-activity list shown on the Stats tab.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class StatisticsViewModel {
    /// A mode-agnostic row for the merged recent list.
    struct RecentItem: Identifiable {
        let id: UUID
        let date: Date
        let title: String
        let detail: String
        let flies: Int
        let symbol: String
        let isPositive: Bool
    }

    private(set) var totalSessions: Int = 0
    private(set) var lockedInTime: TimeInterval = 0
    private(set) var limitHits: Int = 0
    private(set) var recent: [RecentItem] = []

    private let lockedInRepository: LockedInSessionRepositoryProtocol
    private let monitoringRepository: MonitoringSessionRepositoryProtocol

    init(
        lockedInRepository: LockedInSessionRepositoryProtocol,
        monitoringRepository: MonitoringSessionRepositoryProtocol
    ) {
        self.lockedInRepository = lockedInRepository
        self.monitoringRepository = monitoringRepository
    }

    func refresh() {
        do {
            let locked = try lockedInRepository.allSessions()
            let monitored = try monitoringRepository.allSessions()

            totalSessions = locked.count + monitored.count
            lockedInTime = locked.reduce(0) { $0 + $1.actualDuration }
            limitHits = monitored.filter(\.didReachLimit).count

            let lockedItems = locked.map(Self.item(from:))
            let monitoredItems = monitored.map(Self.item(from:))
            recent = (lockedItems + monitoredItems)
                .sorted { $0.date > $1.date }
                .prefix(12)
                .map { $0 }
        } catch {
            AppLogger.persistence.error("Stats refresh failed: \(error)")
        }
    }

    // MARK: - Mapping

    private static func item(from session: LockedInSession) -> RecentItem {
        RecentItem(
            id: session.id,
            date: session.startDate,
            title: "Locked-in",
            detail: session.actualDuration.compactString,
            flies: session.fliesEarned,
            symbol: session.isCompleted ? "checkmark.circle.fill" : "xmark.circle",
            isPositive: session.isCompleted
        )
    }

    private static func item(from session: MonitoringSession) -> RecentItem {
        let symbol: String
        if session.wasShielded {
            symbol = "lock.fill"
        } else if session.didReachLimit {
            symbol = "exclamationmark.triangle.fill"
        } else {
            symbol = "checkmark.circle.fill"
        }
        return RecentItem(
            id: session.id,
            date: session.startDate,
            title: "Monitoring · \(session.enforcement.title)",
            detail: session.didReachLimit ? "Reached limit" : "Stayed under limit",
            flies: session.fliesEarned,
            symbol: symbol,
            isPositive: !session.didReachLimit
        )
    }
}
