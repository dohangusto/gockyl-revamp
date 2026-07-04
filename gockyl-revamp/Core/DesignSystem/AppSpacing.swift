//
//  AppSpacing.swift
//  gockyl-revamp
//
//  A single scale for spacing and corner radii. Using tokens keeps padding
//  consistent across every screen.
//

import CoreGraphics

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let pill: CGFloat = 999
}
