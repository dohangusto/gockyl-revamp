//
//  AppScreen.swift
//  gockyl-revamp
//
//  The standard screen scaffold. It renders a large header title on the LEFT
//  and trailing toolbar controls on the RIGHT of the SAME top row (native large
//  titles can't do this — they push the title onto its own row), then the
//  screen content below. Consistent horizontal margins come for free.
//

import SwiftUI

struct AppScreen<Trailing: View, Content: View>: View {
    let title: String
    @ViewBuilder var trailing: () -> Trailing
    @ViewBuilder var content: () -> Content

    init(
        _ title: String,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.trailing = trailing
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            content()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Text(title)
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.text)
            Spacer(minLength: AppSpacing.sm)
            trailing()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.lg)
    }
}
