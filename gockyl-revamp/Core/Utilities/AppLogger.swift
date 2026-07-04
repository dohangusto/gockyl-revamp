//
//  AppLogger.swift
//  gockyl-revamp
//
//  Thin wrapper over os.Logger with pre-made categories, so logging is
//  consistent and filterable in Console.app.
//

import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.gockyl.app"

    static let session = Logger(subsystem: subsystem, category: "focus-session")
    static let store = Logger(subsystem: subsystem, category: "store")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
}
