//  MotionService.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-07.
//

import Combine
import Foundation
import CoreMotion

final class MotionService: ObservableObject {

    private let pedometer = CMPedometer()

    @Published private(set) var currentCadence: Double = 0       // steps/min
    @Published private(set) var avgCadence: Double = 0
    @Published private(set) var maxCadence: Double = 0
    @Published private(set) var isCadenceInTargetRange: Bool = true

    private var cadenceSamples: [CadenceSample] = []
    private let targetRange: ClosedRange<Double> = 170...180

    // MARK: - Public API

    func start() {
        startPedometer()
    }

    func stop() {
        pedometer.stopUpdates()
    }

    func resetForNewRun() {
        cadenceSamples.removeAll()
        currentCadence = 0
        avgCadence = 0
        maxCadence = 0
        isCadenceInTargetRange = true
    }

    func exportSamples() -> [CadenceSample] {
        cadenceSamples
    }

    // MARK: - CMPedometer (systemets egen cadence)

    private func startPedometer() {
        guard CMPedometer.isCadenceAvailable() else { return }

        pedometer.startUpdates(from: Date()) { [weak self] data, _ in
            guard let self,
                  let data = data,
                  let cadence = data.currentCadence?.doubleValue else { return }

            let spm = cadence * 60

            DispatchQueue.main.async {
                self.currentCadence = spm
                let sample = CadenceSample(timestamp: Date(), stepsPerMinute: spm)
                self.cadenceSamples.append(sample)
                self.updateStats()
            }
        }
    }

    // MARK: - Statistik

    private func updateStats() {
        let values = cadenceSamples.map { $0.stepsPerMinute }
        guard !values.isEmpty else { return }

        avgCadence = values.average
        maxCadence = max(maxCadence, currentCadence)
        isCadenceInTargetRange = targetRange.contains(currentCadence)
    }
}

