//  RunSessionView.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-07.
//

import SwiftUI

struct RunSessionView: View {
    @StateObject var viewModel: RunSessionViewModel

    init(viewModel: RunSessionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(formatTime(viewModel.elapsedTime))
                .font(.largeTitle.monospacedDigit())

            HStack {
                statBlock(title: "Distans",
                          value: String(format: "%.2f km", viewModel.distance / 1000))
                statBlock(title: "Hastighet",
                          value: String(format: "%.1f km/h",
                                        viewModel.currentSpeed * 3.6))
            }
            Text("Debug dist: \(viewModel.distance)")
                .font(.caption)


            HStack {
                statBlock(title: "Cadence",
                          value: String(format: "%.0f spm", viewModel.currentCadence))

                
            }

            HStack(spacing: 16) {
                // Start / Pause / Resume i EN knapp
                Button {
                    switch viewModel.state {
                    case .idle:
                        viewModel.startRun()
                    case .running:
                        viewModel.pauseRun()
                    case .paused:
                        viewModel.resumeRun()
                    }
                } label: {
                    Text(buttonTitle)
                }
                .buttonStyle(.borderedProminent)

                Button("Stop") {
                    viewModel.stopRun()
                }
                .tint(.red)
                .disabled(viewModel.state == .idle)
                
                

            }
        }
        .padding()
    }

    private var buttonTitle: String {
        switch viewModel.state {
        case .idle:
            return "Start"
        case .running:
            return "Paus"
        case .paused:
            return "Start"
        }
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let sec = Int(t) % 60
        let min = Int(t) / 60
        return String(format: "%02d:%02d", min, sec)
    }
}

