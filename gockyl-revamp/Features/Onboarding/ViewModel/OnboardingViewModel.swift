//
//  OnboardingViewModel.swift
//  gockyl-revamp
//
//  Drives the multi-page first-run flow and flips the profile flag when done.
//

import Foundation
import Observation
import OSLog

@Observable
@MainActor
final class OnboardingViewModel {
    struct Page: Identifiable {
        let id = UUID()
        let imageName: String
        let title: String
        let subtitle: String
    }

    let pages: [Page] = [
        Page(
            imageName: "gockyl_frog_idle",
            title: "Meet Gockyl",
            subtitle: "A little frog that naps while you stay focused."
        ),
        Page(
            imageName: "gockyl_frog_sleep_01",
            title: "Focus to earn bugs",
            subtitle: "Every minute of focus feeds your frog with bugs."
        ),
        Page(
            imageName: "black_beanie",
            title: "Dress up your frog",
            subtitle: "Spend bugs in the store on hats and outfits."
        ),
    ]

    var currentIndex: Int = 0

    /// Invoked when onboarding completes, letting the root view swap screens.
    var onFinished: (() -> Void)?

    private let profileRepository: ProfileRepositoryProtocol

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }

    var isLastPage: Bool { currentIndex == pages.count - 1 }

    func advance() {
        if isLastPage {
            finish()
        } else {
            currentIndex += 1
        }
    }

    func finish() {
        do {
            let profile = try profileRepository.currentProfile()
            profile.hasCompletedOnboarding = true
            try profileRepository.save()
        } catch {
            AppLogger.persistence.error("Onboarding completion failed: \(error)")
        }
        onFinished?()
    }
}
