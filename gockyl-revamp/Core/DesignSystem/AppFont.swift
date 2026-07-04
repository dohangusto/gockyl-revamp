//
//  AppFont.swift
//  gockyl-revamp
//
//  Typography tokens. Swap the underlying fonts here (e.g. a custom game font)
//  without touching individual views.
//

import SwiftUI

enum AppFont {
    // Semantic text styles — these scale automatically with Dynamic Type.
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)

    /// A large numeric readout (e.g. a countdown). Built from a `@ScaledMetric`
    /// size in the view so it also honours Dynamic Type.
    static func counter(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded).monospacedDigit()
    }
}
