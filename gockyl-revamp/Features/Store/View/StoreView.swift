//
//  StoreView.swift
//  gockyl-revamp
//
//  Grid of cosmetics grouped by category, with buy / equip actions.
//

import SwiftUI

struct StoreView: View {
    @State private var viewModel: StoreViewModel

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: AppSpacing.md)]

    init(viewModel: StoreViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AppScreen("Store") {
            MaterialBadge(systemImage: "ladybug.fill", text: "\(viewModel.bugBalance)")
        } content: {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppSpacing.xl) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        section(for: category)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .onAppear { viewModel.refresh() }
    }

    private func section(for category: StoreItem.Category) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(category.title)
                .font(AppFont.title)
                .foregroundStyle(AppColor.text)

            LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                ForEach(viewModel.items(in: category)) { item in
                    StoreItemCard(
                        item: item,
                        isOwned: viewModel.isOwned(item),
                        isEquipped: viewModel.isEquipped(item),
                        onBuy: { viewModel.purchase(item) },
                        onEquip: { viewModel.equip(item) }
                    )
                }
            }
        }
    }
}

private struct StoreItemCard: View {
    let item: StoreItem
    let isOwned: Bool
    let isEquipped: Bool
    let onBuy: () -> Void
    let onEquip: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(item.id)
                .resizable()
                .scaledToFit()
                .frame(height: 80)

            Text(item.displayName)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.text)

            actionButton
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.md))
    }

    @ViewBuilder
    private var actionButton: some View {
        if isEquipped {
            Text("Equipped")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.secondaryText)
        } else if isOwned {
            Button("Equip", action: onEquip)
                .font(AppFont.caption)
        } else {
            Button(action: onBuy) {
                Label("\(item.price)", systemImage: "ladybug.fill")
                    .font(AppFont.caption)
            }
        }
    }
}
