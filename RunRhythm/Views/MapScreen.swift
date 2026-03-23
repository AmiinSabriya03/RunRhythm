//
//  MapScreen.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-08.
//

import SwiftUI
import MapKit

struct MapScreen: View {

    @ObservedObject var locationService: LocationService

    var body: some View {
        NavigationStack {
            ZStack {
                
                RouteMapView(coordinates: locationService.pathCoordinates)
                    .ignoresSafeArea()

                VStack {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Aktuell rutt")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Visar vägen för ditt senaste pass")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(18)
                    .padding(.top, 12)
                    .padding(.horizontal)

                    Spacer()

                    // Info chips
                    HStack(spacing: 12) {
                        infoChip(
                            icon: "figure.run",
                            text: String(format: "%.2f km", locationService.totalDistance / 1000)
                        )
                        
                        infoChip(
                            icon: "speedometer",
                            text: String(format: "%.1f km/h", locationService.currentSpeed * 3.6)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Karta")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - UI Component
    private func infoChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(text)
                .font(.footnote)
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground).opacity(0.95))
        )
        .foregroundColor(.primary)
    }
}
