//
//  RunAnalyzer.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-03.
//

import Foundation

struct RunAnalyzer {

    func analyze(duration: TimeInterval,
                 distance: Double,
                 cadenceSamples: [CadenceSample],
                 speedSamples: [SpeedSample],
                 targetCadenceRange: ClosedRange<Double>) -> RunSummary {

        let avgSpeed = distance / max(duration, 1)          // m/s
        let maxSpeed = speedSamples.map(\.speed).max() ?? 0

        let cadenceValues = cadenceSamples.map { $0.stepsPerMinute }
        let avgCadence = cadenceValues.average
        let maxCadence = cadenceValues.max() ?? 0

        let steady = longestSteadySegment(in: speedSamples, tolerance: 0.1)
        let goodCadenceFraction = fractionInTargetRange(cadenceSamples,
                                                        range: targetCadenceRange)

        return RunSummary(
            duration: duration,
            distance: distance,
            avgSpeed: avgSpeed,
            maxSpeed: maxSpeed,
            avgCadence: avgCadence,
            maxCadence: maxCadence,
            longestSteadyPaceDuration: steady,
            isCadenceGood: goodCadenceFraction > 0.6
        )
    }

    // Hitta längst "steady pace" där hastigheten varierar max 10% runt basfarten
    private func longestSteadySegment(in samples: [SpeedSample],
                                      tolerance: Double) -> TimeInterval {
        guard samples.count > 2 else { return 0 }

        var longest: TimeInterval = 0
        var startIndex = 0

        while startIndex < samples.count {
            var endIndex = startIndex
            let baseSpeed = max(samples[startIndex].speed, 0.1)

            while endIndex + 1 < samples.count {
                let next = samples[endIndex + 1]
                let diff = abs(next.speed - baseSpeed) / baseSpeed
                if diff <= tolerance {
                    endIndex += 1
                } else {
                    break
                }
            }

            let startTime = samples[startIndex].timestamp
            let endTime = samples[endIndex].timestamp
            longest = max(longest, endTime.timeIntervalSince(startTime))

            startIndex = endIndex + 1
        }

        return longest
    }

    // Hur stor del av tiden låg kadensen inom målintervallet?
    private func fractionInTargetRange(_ samples: [CadenceSample],
                                       range: ClosedRange<Double>) -> Double {
        guard !samples.isEmpty else { return 0 }
        let countInRange = samples.filter { range.contains($0.stepsPerMinute) }.count
        return Double(countInRange) / Double(samples.count)
    }
}
