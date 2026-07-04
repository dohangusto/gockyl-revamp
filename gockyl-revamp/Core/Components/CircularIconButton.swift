//
//  CircularIconButton.swift
//  gockyl-revamp
//
//  Toolbar controls built from native iOS 26 Liquid Glass components rather than
//  hand-rolled materials: an icon `Button` using `.buttonStyle(.glass)`, and a
//  read-only badge using the `.glassEffect` modifier. Both use semantic fonts so
//  they scale with Dynamic Type.
//

import SwiftUI

struct CircularIconButton: View {
    let systemImage: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(AppColor.text)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }
}

/// A read-only status pill (e.g. the bug balance) on native Liquid Glass.
struct MaterialBadge: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.callout.weight(.semibold))
            .foregroundStyle(AppColor.text)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .glassEffect(.regular, in: .capsule)
    }
}

#Preview {
    HStack(spacing: AppSpacing.sm) {
        CircularIconButton(systemImage: "gearshape")
        MaterialBadge(systemImage: "ladybug.fill", text: "1240")
    }
    .padding()
}
