//
//  ContentView.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-01.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    let motionService: MotionService
    let locationService: LocationService
    let healthKitService: HealthKitService

    @StateObject private var runSessionViewModel: RunSessionViewModel

    init(motionService: MotionService,
         locationService: LocationService,
         healthKitService: HealthKitService) {
        self.motionService = motionService
        self.locationService = locationService
        self.healthKitService = healthKitService
        _runSessionViewModel = StateObject(
            wrappedValue: RunSessionViewModel(
                motionService: motionService,
                locationService: locationService,
                healthKitService: healthKitService
            )
        )
    }

    var body: some View {
        TabView {
            RunSessionView(viewModel: runSessionViewModel)
                .tabItem {
                    Label("Pass", systemImage: "figure.run")
                }

            HistoryView()
                .tabItem {
                    Label("Historik", systemImage: "clock.arrow.circlepath")
                }

            MapScreen(locationService: locationService)
                .tabItem {
                    Label("Karta", systemImage: "map")
                }
        }
    }
}
