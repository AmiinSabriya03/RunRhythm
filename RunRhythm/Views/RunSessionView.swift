//  RunSessionView.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-07.
//

import SwiftUI

struct RunSessionView: View {
    
    @ObservedObject var viewModel: RunSessionViewModel
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // Tid
                Text(formatTime(viewModel.elapsedTime))
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                
                VStack(spacing: 16) {
                    
                    Text("Tempo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Pace
                    Text(formatPace(viewModel.pace))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    HStack {
                        statBlock(
                            title: "Distans",
                            value: String(format: "%.2f km", viewModel.distance / 1000)
                        )
                        statBlock(
                            title: "Hastighet",
                            value: String(format: "%.1f km/h", viewModel.currentSpeed * 3.6)
                        )
                    }
                    
                    HStack {
                        statBlock(
                            title: "Cadence",
                            value: String(format: "%.0f spm", viewModel.cadence)
                        )
                        
                        if viewModel.elapsedTime > 10 {
                            statBlock(
                                title: "Snittfart",
                                value: String(format: "%.1f km/h", viewModel.avgSpeed * 3.6)
                            )
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .padding(.horizontal)
                
                Spacer()
                
                // Kontroller
                HStack(spacing: 24) {
                    
                    Button(role: .destructive) {
                        viewModel.stopRun()
                    } label: {
                        Image(systemName: "square.fill")
                            .font(.system(size: 22, weight: .bold))
                            .padding()
                            .background(viewModel.state == .idle ? Color.red.opacity(0.2) : Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.state == .idle)
                    
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
                        Image(systemName: viewModel.state == .running ? "pause.fill" : "play.fill")
                            .font(.system(size: 26, weight: .bold))
                            .padding(24)
                            .background(viewModel.state == .running ? Color.orange : Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }
        
    private func statBlock(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formatTime(_ t: TimeInterval) -> String {
        let sec = Int(t) % 60
        let min = (Int(t) / 60) % 60
        let hrs = Int(t) / 3600
        
        return hrs > 0
        ? String(format: "%02d:%02d:%02d", hrs, min, sec)
        : String(format: "%02d:%02d", min, sec)
    }
    
    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 else { return "--:-- /km" }
        
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}
