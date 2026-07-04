//
//  AppFont.swift
//  gockyl-revamp
//
//  Typography tokens. Swap the underlying fonts here (e.g. a custom game font)
//  without touching individual views.
//

import SwiftUI

enum AppFont {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
    static let counter = Font.system(size: 56, weight: .bold, design: .rounded).monospacedDigit()
}
