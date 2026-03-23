//
//  HistoryView.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-08.
//

import SwiftUI
import CoreData

struct HistoryView: View {

    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        entity: Run.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Run.startDate, ascending: false)]
    ) private var runs: FetchedResults<Run>

    var body: some View {
        NavigationStack {
            if runs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Inga pass ännu")
                        .font(.headline)
                    Text("Dina sparade löppass visas här när du har genomfört några.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(runs) { run in
                        NavigationLink {
                            RunDetailView(run: run)
                        } label: {
                            row(for: run)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.insetGrouped)
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("Historik")
    }

    private func row(for run: Run) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dateString(run.startDate))
                .font(.headline)

            HStack {
                Label(
                    String(format: "%.2f km", run.distance / 1000),
                    systemImage: "figure.run"
                )
                .font(.subheadline)

                Spacer()

                Text(formatDuration(run.duration))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                Text(String(format: "Snitt: %.1f km/h", run.avgSpeed * 3.6))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(String(format: "Cadence: %.0f spm", run.avgCadence))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private func dateString(_ date: Date?) -> String {
        guard let date else { return "-" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSec = Int(duration)
        let min = totalSec / 60
        let sec = totalSec % 60
        return String(format: "%02d:%02d", min, sec)
    }
}


