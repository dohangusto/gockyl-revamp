//
//  HomeView.swift
//  gockyl-revamp
//
//  The frog's room. The room art is a pure decorative background; the content
//  (title, fly balance, the frog, and the start/stop control) is laid out in a
//  normal safe-area-respecting stack on top of it.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if viewModel.hasActiveSession {
                timeReadout
                    .padding(.top, AppSpacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer(minLength: AppSpacing.lg)

            FrogView(state: viewModel.frogState)
                .frame(maxWidth: 260)
                .offset(y: 120)

            Spacer(minLength: AppSpacing.lg)

            PrimaryButton(title: viewModel.actionTitle) {
                viewModel.toggleSession()
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(roomBackground)
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasActiveSession)
        .onAppear { viewModel.refresh() }
    }

    /// The session clock: counts down (Locked-in) or up toward the limit
    /// (Monitoring), with a caption for what the number means / the stage.
    private var timeReadout: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(viewModel.timeText)
                .font(AppFont.counter(size: 44))
                .foregroundStyle(AppColor.text)
            Text(viewModel.timeCaption)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.secondaryText)
                .textCase(.uppercase)
        }
        .padding(.vertical, AppSpacing.md)
        .padding(.horizontal, AppSpacing.xl)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    // MARK: - Layers

    /// Purely decorative room art behind everything. Switches with the frog's
    /// state and bleeds to every edge without affecting the layout above it.
    private var roomBackground: some View {
        ZStack {
            if viewModel.frogState == .sleeping {
                Image("gockyl_room_bg_sleep").resizable().scaledToFill()
            } else {
                Image("gockyl_room_bg_base").resizable().scaledToFill()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.4), value: viewModel.frogState)
        .overlay(alignment: .top) { headerScrim }
        .ignoresSafeArea()
    }

    /// A soft top scrim so the title and fly balance stay legible over the art.
    /// Uses the adaptive background colour, so it reads in light and dark.
    private var headerScrim: some View {
        LinearGradient(
            colors: [AppColor.background.opacity(0.65), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 160)
        .allowsHitTesting(false)
    }

    private var header: some View {
        HStack {
            Text("Gockyl")
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.text)
            Spacer()
            MaterialBadge(systemImage: "ladybug.fill", text: "\(viewModel.flyBalance)")
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}
