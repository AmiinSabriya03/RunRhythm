//
//  Models.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-01.
//

import Foundation
import CoreLocation

// Enskilt cadence-prov (steg/minut vid en viss tidpunkt)
struct CadenceSample {
    let timestamp: Date
    let stepsPerMinute: Double
}

// Enskilt speed-prov (m/s vid en viss tidpunkt)
struct SpeedSample {
    let timestamp: Date
    let speed: Double
}

// Sammanfattning av ett löppass som används mellan analys, Core Data och HealthKit
struct RunSummary {
    let duration: TimeInterval          // totaltid i sekunder
    let distance: Double                // meter
    let avgSpeed: Double                // m/s
    let maxSpeed: Double                // m/s
    let avgCadence: Double              // steps/min
    let maxCadence: Double              // steps/min
    let longestSteadyPaceDuration: TimeInterval // sekunder
    let isCadenceGood: Bool
}

extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
