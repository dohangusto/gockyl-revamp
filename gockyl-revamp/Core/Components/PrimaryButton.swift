//
//  PrimaryButton.swift
//  gockyl-revamp
//
//  The app's standard call-to-action button, built from design tokens so every
//  screen gets the same look for free.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(AppColor.accent, in: RoundedRectangle(cornerRadius: AppRadius.md))
        .opacity(isEnabled ? 1 : 0.4)
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        PrimaryButton(title: "Start Focus") {}
        PrimaryButton(title: "Disabled", isEnabled: false) {}
    }
    .padding()
}
