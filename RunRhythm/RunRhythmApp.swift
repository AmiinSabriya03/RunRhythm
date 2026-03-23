//
//  RunRhythmApp.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-01.
//


import SwiftUI
import CoreData

@main
struct RunRhythmApp: App {
    @StateObject private var motionService = MotionService()
    @StateObject private var locationService = LocationService()
    @StateObject private var healthKitService = HealthKitService()
    
    private let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(
                motionService: motionService,
                locationService: locationService,
                healthKitService: healthKitService
            )
            .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
