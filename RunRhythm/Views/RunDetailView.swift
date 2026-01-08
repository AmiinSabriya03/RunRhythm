//
//  RunDetailView.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-08.
//

import SwiftUI
import MapKit

struct RunDetailView: View {
    let run: Run

    var body: some View {
        let coords = coordinates(from: run)

        ScrollView {
            VStack(spacing: 16) {
                if !coords.isEmpty {
                    RouteMapView(coordinates: coords)
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding(.bottom)
                }

                Text(dateString(run.startDate))
                    .font(.title3)

                Text(formatDuration(run.duration))
                    .font(.largeTitle.monospacedDigit())

                HStack {
                    statBlock("Distans", String(format: "%.2f km", run.distance / 1000))
                    statBlock("Snittfart", String(format: "%.1f km/h", run.avgSpeed * 3.6))
                }

                HStack {
                    statBlock("Maxfart", String(format: "%.1f km/h", run.maxSpeed * 3.6))
                    statBlock("Cadence", String(format: "%.0f spm", run.avgCadence))
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Passdetaljer")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func statBlock(_ title: String, _ value: String) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
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

    private func coordinates(from run: Run) -> [CLLocationCoordinate2D] {
        guard
            let route = run.route,
            let data = route.coordinatesData,
            let decoded = try? JSONDecoder().decode([[String: Double]].self, from: data)
        else {
            return []
        }

        return decoded.compactMap { dict in
            guard let lat = dict["lat"], let lon = dict["lon"] else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
}

