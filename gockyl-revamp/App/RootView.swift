//
//  RootView.swift
//  gockyl-revamp
//
//  Composition root at the view layer. It builds the AppEnvironment from the
//  SwiftData context, decides between onboarding and the main app, and injects
//  shared objects (environment + router) down the tree.
//

import SwiftUI
import SwiftData
import OSLog

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var environment: AppEnvironment?
    @State private var router = AppRouter()
    @State private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if let environment {
                content(environment)
                    .environment(environment)
                    .environment(router)
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: bootstrap)
    }

    @ViewBuilder
    private func content(_ environment: AppEnvironment) -> some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView(
                viewModel: makeOnboardingViewModel(environment)
            )
        }
    }

    private func makeOnboardingViewModel(_ environment: AppEnvironment) -> OnboardingViewModel {
        let viewModel = OnboardingViewModel(profileRepository: environment.profileRepository)
        viewModel.onFinished = {
            withAnimation { hasCompletedOnboarding = true }
        }
        return viewModel
    }

    /// Builds dependencies once and reads the persisted onboarding flag.
    private func bootstrap() {
        guard environment == nil else { return }
        let environment = AppEnvironment(modelContext: modelContext)
        self.environment = environment
        do {
            hasCompletedOnboarding = try environment.profileRepository
                .currentProfile()
                .hasCompletedOnboarding
        } catch {
            AppLogger.persistence.error("Bootstrap failed: \(error)")
        }
    }
}
