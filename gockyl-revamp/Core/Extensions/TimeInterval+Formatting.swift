//
//  TimeInterval+Formatting.swift
//  gockyl-revamp
//
//  Shared formatting helpers for durations shown on the timer and stats screens.
//

import Foundation

extension TimeInterval {
    /// "25:00" style clock string.
    var clockString: String {
        let total = Int(rounded())
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// "1h 25m" style compact string used in statistics.
    var compactString: String {
        let total = Int(rounded())
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}
