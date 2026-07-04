//
//  StatisticsViewModel.swift
//  gockyl-revamp
//
//  Aggregates persisted focus sessions into the numbers shown on the stats tab.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class StatisticsViewModel {
    private(set) var totalSessions: Int = 0
    private(set) var completedSessions: Int = 0
    private(set) var totalFocusedTime: TimeInterval = 0
    private(set) var recentSessions: [FocusSession] = []

    private let sessionRepository: FocusSessionRepositoryProtocol

    init(sessionRepository: FocusSessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    var completionRate: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }

    func refresh() {
        do {
            let sessions = try sessionRepository.allSessions()
            totalSessions = sessions.count
            completedSessions = sessions.filter(\.isCompleted).count
            totalFocusedTime = sessions.reduce(0) { $0 + $1.focusedDuration }
            recentSessions = Array(sessions.prefix(10))
        } catch {
            AppLogger.persistence.error("Stats refresh failed: \(error)")
        }
    }
}
