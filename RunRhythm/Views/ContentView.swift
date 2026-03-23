//
//  ContentView.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-01.
//


import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.managedObjectContext) private var context

    private let motionService: MotionService
    private let locationService: LocationService
    private let healthKitService: HealthKitService

    @StateObject private var runSessionViewModel: RunSessionViewModel

    init(
        motionService: MotionService,
        locationService: LocationService,
        healthKitService: HealthKitService
    ) {
        self.motionService = motionService
        self.locationService = locationService
        self.healthKitService = healthKitService

        // ⚠️ TEMP context (fix för init)
        let tempContext = PersistenceController.shared.container.viewContext

        _runSessionViewModel = StateObject(
            wrappedValue: RunSessionViewModel(
                motionService: motionService,
                locationService: locationService,
                healthKitService: healthKitService,
                context: tempContext
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
        .tint(.green)
        .onAppear {
            healthKitService.requestAuthorization()
            locationService.requestAuthorization()
        }
    }
}
