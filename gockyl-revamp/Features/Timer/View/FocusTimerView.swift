//
//  FocusTimerView.swift
//  gockyl-revamp
//
//  Renders the countdown ring and the frog sleeping while a session runs.
//  Owns its view model via @State; all logic is delegated to it.
//

import SwiftUI

struct FocusTimerView: View {
    @State private var viewModel: FocusTimerViewModel
    @Environment(AppRouter.self) private var router

    /// Scales the timer readout with Dynamic Type while keeping it large.
    @ScaledMetric(relativeTo: .largeTitle) private var counterSize: CGFloat = 56

    init(viewModel: FocusTimerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AppScreen("Focus") {
            VStack(spacing: AppSpacing.xl) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(AppColor.surface, lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(AppColor.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: viewModel.progress)

                    Text(viewModel.remaining.clockString)
                        .font(AppFont.counter(size: counterSize))
                        .foregroundStyle(AppColor.text)
                }
                .frame(width: 240, height: 240)

                statusLabel

                Spacer()

                actionButton
            }
            .padding(.horizontal, AppSpacing.lg)
            .frame(maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(viewModel.phase == .running)
        .onAppear { viewModel.start() }
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch viewModel.phase {
        case .idle, .running:
            Label("Gockyl is sleeping…", systemImage: "moon.zzz.fill")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.secondaryText)
        case .finished:
            Text("Nice! You earned \(viewModel.bugsEarned) 🐛")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.text)
        case .cancelled:
            Text("Session cancelled — no bugs this time.")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.secondaryText)
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        switch viewModel.phase {
        case .idle, .running:
            PrimaryButton(title: "Give Up") { viewModel.cancel() }
        case .finished, .cancelled:
            PrimaryButton(title: "Done") { router.popToRoot() }
        }
    }
}
