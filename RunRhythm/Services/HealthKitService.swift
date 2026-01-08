//
//  HealthKitService.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-04.
//

import Combine
import Foundation
import HealthKit

final class HealthKitService: ObservableObject {

    private let healthStore = HKHealthStore()

    // Be om åtkomst till HealthKit
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let typesToShare: Set = [
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: []) { success, error in
            if let error = error {
                print("HealthKit auth error: \(error.localizedDescription)")
            } else {
                print("HealthKit auth success: \(success)")
            }
        }
    }

    // Spara ett löppass som HKWorkout
    func saveWorkout(from summary: RunSummary,
                     completion: @escaping (UUID?) -> Void) {
        let start = Date().addingTimeInterval(-summary.duration)
        let end = Date()

        let workout = HKWorkout(
            activityType: .running,
            start: start,
            end: end,
            workoutEvents: nil,
            totalEnergyBurned: nil,
            totalDistance: HKQuantity(unit: .meter(),
                                      doubleValue: summary.distance),
            metadata: nil
        )

        healthStore.save(workout) { success, error in
            if let error = error {
                print("Save workout error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(success ? workout.uuid : nil)
            }
        }
    }
}
