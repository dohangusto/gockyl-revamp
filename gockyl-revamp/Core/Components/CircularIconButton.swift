//
//  CircularIconButton.swift
//  gockyl-revamp
//
//  A compact circular toolbar control on a soft translucent material, with a
//  monochrome icon. Used for primary actions on the right of a large header so
//  they stay available without dominating the hierarchy.
//

import SwiftUI

struct CircularIconButton: View {
    let systemImage: String
    var action: () -> Void = {}

    /// Fixed diameter keeps every toolbar control consistently sized.
    private let diameter: CGFloat = 38

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.text)
                .frame(width: diameter, height: diameter)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

/// A pill-shaped counter on the same material as `CircularIconButton`, for
/// read-only status such as the bug balance.
struct MaterialBadge: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(AppFont.caption.weight(.semibold))
            .foregroundStyle(AppColor.text)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 38)
            .background(.ultraThinMaterial, in: Capsule())
    }
}

#Preview {
    HStack(spacing: AppSpacing.sm) {
        CircularIconButton(systemImage: "gearshape")
        MaterialBadge(systemImage: "ladybug.fill", text: "1240")
    }
    .padding()
}
