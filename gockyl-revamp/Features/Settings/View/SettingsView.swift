//
//  SettingsView.swift
//  gockyl-revamp
//
//  Profile settings plus how Gockyl watches over the user: the monitoring mode,
//  its enforcement, and the time limits. The section shown adapts to the mode,
//  and Monitoring previews the interruption ladder derived from the domain.
//

import SwiftUI
import FamilyControls

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var isAppPickerPresented = false

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AppScreen("Settings") {
            Form {
                Section("Frog") {
                    TextField("Name", text: $viewModel.frogName)
                        .onSubmit { viewModel.commitName() }
                }

                Section {
                    Picker("Mode", selection: $viewModel.monitoringMode) {
                        ForEach(MonitoringMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Mode")
                } footer: {
                    Text(viewModel.monitoringMode == .lockedIn
                         ? "Locks the phone for a set time. No monitoring, just the time left."
                         : "Watches the apps you choose and nudges you as you near your limit.")
                }

                if viewModel.isMonitoring {
                    monitoringSection(viewModel)
                } else {
                    lockedInSection(viewModel)
                }

                Section("About") {
                    LabeledContent("Version", value: viewModel.appVersion)
                }
            }
        }
        .onAppear { viewModel.refresh() }
    }

    // MARK: - Sections

    @ViewBuilder
    private func monitoringSection(_ viewModel: SettingsViewModel) -> some View {
        @Bindable var viewModel = viewModel

        Section {
            if viewModel.screenTime.isAuthorized {
                Button {
                    isAppPickerPresented = true
                } label: {
                    LabeledContent(
                        "Monitored apps",
                        value: viewModel.screenTime.selectionCount > 0
                            ? "\(viewModel.screenTime.selectionCount) selected"
                            : "None"
                    )
                }
                .familyActivityPicker(
                    isPresented: $isAppPickerPresented,
                    selection: Bindable(viewModel.screenTime).selection
                )
                .onChange(of: isAppPickerPresented) { _, presented in
                    if !presented { viewModel.commitAppSelection() }
                }
            } else {
                Button("Allow Screen Time access") {
                    Task { await viewModel.requestScreenTimeAccess() }
                }
            }
        } header: {
            Text("Apps")
        } footer: {
            Text(viewModel.screenTime.isAuthorized
                 ? "Gockyl only sees usage of the apps you pick here."
                 : "Gockyl needs Screen Time permission to watch the apps you choose.")
        }

        Section {
            Picker("Enforcement", selection: $viewModel.enforcement) {
                ForEach(Enforcement.allCases) { level in
                    Text(level.title).tag(level)
                }
            }
            .pickerStyle(.segmented)

            Stepper(
                "Limit: \(viewModel.dailyLimitMinutes) min",
                value: $viewModel.dailyLimitMinutes,
                in: 1...240
            )
        } header: {
            Text("Monitoring")
        } footer: {
            Text(viewModel.enforcement == .strong
                 ? "Strong blocks the app the moment you hit 100%. Unlock only from Gockyl."
                 : "Soft only interrupts — the app is never blocked.")
        }

        Section("What happens") {
            ForEach(stagePreview(for: viewModel), id: \.label) { stage in
                LabeledContent(stage.label, value: stage.timing)
            }
        }
    }

    @ViewBuilder
    private func lockedInSection(_ viewModel: SettingsViewModel) -> some View {
        @Bindable var viewModel = viewModel

        Section("Locked-in") {
            Stepper(
                "Duration: \(viewModel.lockedInMinutes) min",
                value: $viewModel.lockedInMinutes,
                in: 5...480,
                step: 5
            )
        }
    }

    // MARK: - Interruption ladder preview

    private struct StagePreview {
        let label: String
        let timing: String
    }

    /// Turns the domain's interruption ladder into human-readable rows, so the
    /// user can see exactly when each nudge fires for their current settings.
    private func stagePreview(for viewModel: SettingsViewModel) -> [StagePreview] {
        let limit = TimeInterval(viewModel.dailyLimitMinutes * 60)
        let snooze: TimeInterval = 120  // matches FrogProfile default

        return InterruptionStage.ladder(for: viewModel.enforcement).map { stage in
            let timing: String
            if let threshold = stage.threshold(dailyLimit: limit, snoozeStep: snooze), threshold > 0 {
                timing = threshold.compactString
            } else {
                timing = "On open"
            }
            return StagePreview(label: stage.title, timing: timing)
        }
    }
}
