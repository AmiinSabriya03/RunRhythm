//
//  HealthKitService.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-04.
//

import Foundation
import HealthKit
import Combine

final class HealthKitService: ObservableObject {

    private let healthStore = HKHealthStore()

    // MARK: - Authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let typesToShare: Set = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: []) { success, error in
            if let error = error {
                print("HealthKit auth error: \(error.localizedDescription)")
            } else {
                print("HealthKit auth success: \(success)")
            }
        }
    }

    // MARK: - Save Workout (FIXED)
    func saveWorkout(
        distance: Double,
        startDate: Date,
        endDate: Date
    ) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor

        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: configuration,
            device: .local()
        )

        builder.beginCollection(withStart: startDate) { success, error in
            if let error = error {
                print("Begin collection error: \(error.localizedDescription)")
                return
            }

            // Lägg till distance
            let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: distance)
            let distanceSample = HKQuantitySample(
                type: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                quantity: distanceQuantity,
                start: startDate,
                end: endDate
            )

            builder.add([distanceSample]) { success, error in
                if let error = error {
                    print("Add sample error: \(error.localizedDescription)")
                    return
                }

                builder.endCollection(withEnd: endDate) { success, error in
                    if let error = error {
                        print("End collection error: \(error.localizedDescription)")
                        return
                    }

                    builder.finishWorkout { workout, error in
                        if let error = error {
                            print("Finish workout error: \(error.localizedDescription)")
                        } else {
                            print("Workout saved: \(workout?.uuid.uuidString ?? "unknown")")
                        }
                    }
                }
            }
        }
    }
}
