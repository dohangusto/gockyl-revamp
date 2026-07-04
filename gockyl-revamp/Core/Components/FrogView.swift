//
//  FrogView.swift
//  gockyl-revamp
//
//  Just the animated frog character (transparent background) for the current
//  `FrogState`. Sleeping cycles the sleep frames with a dream bubble tucked next
//  to its head; on-duty shows the idle frog. Cycling is driven by `TimelineView`
//  so there's no timer state to manage.
//
//  The sleep frames hard-swap (they read fine that way); only the dream bubble
//  cross-fades, with a fade shorter than the frame interval so each frame settles
//  before the next — smooth, without the flicker a same-length fade causes.
//

import SwiftUI

struct FrogView: View {
    let state: FrogState

    private let sleepFrames = ["gockyl_frog_sleep_01", "gockyl_frog_sleep_02", "gockyl_frog_sleep_03"]
    private let dreamFrames = (1...6).map { String(format: "gockyl_dream_bubble_%02d", $0) }

    var body: some View {
        Group {
            switch state {
            case .sleeping: sleepingFrog
            case .onDuty:   onDutyFrog
            }
        }
        .accessibilityElement()
        .accessibilityLabel(state == .sleeping ? "Gockyl is sleeping" : "Gockyl is on duty")
    }

    // MARK: - States

    private var sleepingFrog: some View {
        Sprite(frames: sleepFrames, interval: 0.5)
            .overlay(alignment: .top) {
                Sprite(frames: dreamFrames, interval: 0.5, fade: 0.3)
                    .frame(width: 84)
                    .offset(x: 46, y: 18)
            }
    }

    private var onDutyFrog: some View {
        Image("gockyl_frog_idle")
            .resizable()
            .scaledToFit()
    }
}

/// A looping frame animation. By default frames hard-swap; give it a `fade`
/// (shorter than `interval`) to cross-fade between frames instead.
private struct Sprite: View {
    let frames: [String]
    let interval: TimeInterval
    var fade: TimeInterval = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: interval)) { context in
            let current = Int(context.date.timeIntervalSinceReferenceDate / interval) % frames.count

            if fade > 0 {
                ZStack {
                    ForEach(frames.indices, id: \.self) { index in
                        Image(frames[index])
                            .resizable()
                            .scaledToFit()
                            .opacity(index == current ? 1 : 0)
                    }
                }
                .animation(.easeInOut(duration: fade), value: current)
            } else {
                Image(frames[current])
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
