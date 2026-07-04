//
//  SettingsView.swift
//  gockyl-revamp
//
//  Profile and app-info settings.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Frog") {
                    TextField("Name", text: $viewModel.frogName)
                        .onSubmit { viewModel.commitName() }
                }

                Section("About") {
                    LabeledContent("Version", value: viewModel.appVersion)
                }
            }
            .navigationTitle("Settings")
            .onAppear { viewModel.refresh() }
        }
    }
}
