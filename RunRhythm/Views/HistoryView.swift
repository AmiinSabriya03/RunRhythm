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
            List {
                ForEach(runs) { run in
                    NavigationLink {
                        RunDetailView(run: run)   // stub, fix i steg 2
                    } label: {
                        row(for: run)
                    }
                }
            }
            .navigationTitle("Historik")
        }
    }

    private func row(for run: Run) -> some View {
        VStack(alignment: .leading) {
            Text(dateString(run.startDate))
                .font(.headline)

            HStack {
                Text(String(format: "%.2f km", run.distance / 1000))
                Spacer()
                Text(formatDuration(run.duration))
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
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

