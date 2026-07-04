//
//  FloatingTabBar.swift
//  gockyl-revamp
//
//  A floating, capsule-shaped bottom navigation that replaces the default
//  edge-attached tab bar. It sits separated from the screen boundary to feel
//  lighter and introduce subtle depth, per the app's design language.
//

import SwiftUI

struct FloatingTabBar: View {
    @Binding var selection: AppTab

    /// Height of the capsule; used by screens to reserve bottom clearance.
    static let height: CGFloat = 64
    /// Total vertical space a screen should leave below its content so scroll
    /// content clears the floating bar (height + its bottom padding).
    static let clearance: CGFloat = 96

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                destinationButton(tab)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .frame(height: Self.height)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
        .padding(.horizontal, AppSpacing.xxl)
    }

    private func destinationButton(_ tab: AppTab) -> some View {
        let isActive = selection == tab
        return Button {
            withAnimation(.snappy(duration: 0.25)) { selection = tab }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isActive ? AppColor.accent : AppColor.secondaryText)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct Wrapper: View {
        @State private var selection: AppTab = .home
        var body: some View { FloatingTabBar(selection: $selection) }
    }
    return Wrapper().padding(.vertical, 40)
}
