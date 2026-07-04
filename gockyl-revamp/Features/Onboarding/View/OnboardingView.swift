//
//  OnboardingView.swift
//  gockyl-revamp
//
//  Paged first-run introduction.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            TabView(selection: $viewModel.currentIndex) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                    pageView(page).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            PrimaryButton(title: viewModel.isLastPage ? "Get Started" : "Next") {
                withAnimation { viewModel.advance() }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
        }
    }

    private func pageView(_ page: OnboardingViewModel.Page) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 240)
            Text(page.title)
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColor.text)
            Text(page.subtitle)
                .font(AppFont.body)
                .foregroundStyle(AppColor.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            Spacer()
        }
    }
}
