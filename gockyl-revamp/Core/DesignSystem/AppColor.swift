//
//  AppColor.swift
//  gockyl-revamp
//
//  Semantic color tokens. Views reference these instead of raw asset names or
//  literal colors, so re-theming happens in exactly one place.
//

import SwiftUI

enum AppColor {
    static let accent = Color("AccentColor")
    static let text = Color("TextColor")
    static let secondaryText = Color("SecondaryTextColor")

    /// Backgrounds fall back to system materials until dedicated assets exist.
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
}
