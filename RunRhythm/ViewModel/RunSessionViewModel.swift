//  RunSessionViewModel.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-07.
//

import Combine
import Foundation
import CoreLocation
import CoreData

enum RunState {
    case idle
    case running
    case paused
}

final class RunSessionViewModel: ObservableObject {

    // Publika värden som UI visar
    @Published private(set) var elapsedTime: TimeInterval = 0

    @Published private(set) var distance: Double = 0          // meter
    @Published private(set) var currentSpeed: Double = 0      // m/s
    @Published private(set) var avgSpeed: Double = 0          // m/s
    @Published private(set) var maxSpeed: Double = 0          // m/s

    @Published private(set) var currentCadence: Double = 0    // steps/min
    @Published private(set) var avgCadence: Double = 0
    @Published private(set) var maxCadence: Double = 0
    @Published private(set) var isCadenceInTargetRange: Bool = true

    @Published private(set) var state: RunState = .idle

    private let motionService: MotionService
    private let locationService: LocationService
    private let healthKitService: HealthKitService
    private let persistence: PersistenceController
    private let analyzer = RunAnalyzer()
    private let speechService: SpeechService
    
    private let cadenceFeedbackInterval: TimeInterval = 60
    private var lastCadenceFeedbackTime: Date?


    private var timer: Timer?
    private var startDate: Date?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(motionService: MotionService,
         locationService: LocationService,
         healthKitService: HealthKitService,
         persistence: PersistenceController = .shared,
         speechService: SpeechService = SpeechService()) {

        self.motionService = motionService
        self.locationService = locationService
        self.healthKitService = healthKitService
        self.persistence = persistence
        self.speechService = speechService

        // Koppla @Published från services till vår egen state
        motionService.$currentCadence.assign(to: &$currentCadence)
        motionService.$avgCadence.assign(to: &$avgCadence)
        motionService.$maxCadence.assign(to: &$maxCadence)
        motionService.$isCadenceInTargetRange.assign(to: &$isCadenceInTargetRange)

        locationService.$totalDistance.assign(to: &$distance)
        locationService.$currentSpeed.assign(to: &$currentSpeed)
        locationService.$maxSpeed.assign(to: &$maxSpeed)

        observeCadenceChanges()
    }

    // Reagera på ändringar i cadence‑status (ersätter färgfeedback)
    private func observeCadenceChanges() {
        $isCadenceInTargetRange
            .removeDuplicates()
            .sink { [weak self] inRange in
                guard let self else { return }

                // Bara prata när passet är igång
                guard self.state == .running else { return }

                let now = Date()
                if let last = self.lastCadenceFeedbackTime,
                   now.timeIntervalSince(last) < self.cadenceFeedbackInterval {
                    return
                }
                self.lastCadenceFeedbackTime = now

                if inRange {
                    self.speechService.speak("cadence is good")
                } else {
                    self.speechService.speak("cadence is bad")
                }
            }
            .store(in: &cancellables)
    }



    // MARK: - Kontroll av pass

    func startRun() {
        guard state == .idle else { return }

        elapsedTime = 0
        distance = 0
        avgSpeed = 0
        maxSpeed = 0

        motionService.resetForNewRun()
        locationService.resetForNewRun()

        startDate = Date()
        state = .running

        motionService.start()
        locationService.start()
        startTimer()
    }

    func pauseRun() {
        guard state == .running else { return }
        state = .paused
        timer?.invalidate()
        motionService.stop()
        locationService.stop()
    }

    func resumeRun() {
        guard state == .paused else { return }
        // fortsätt från där timern var
        startDate = Date().addingTimeInterval(-elapsedTime)
        state = .running

        motionService.start()
        locationService.start()
        startTimer()
    }
    
    


    func stopRun() {
        guard state == .running || state == .paused else { return }

        timer?.invalidate()
        motionService.stop()
        locationService.stop()

        guard let start = startDate else { return }
        let duration = Date().timeIntervalSince(start)

        state = .idle

        // resten av din befintliga stopRun-kod:
        let distanceSnapshot = distance
        let cadenceSamples = motionService.exportSamples()
        let speedSamples = locationService.exportSamples()
        let coords = locationService.pathCoordinates


        DispatchQueue.global(qos: .userInitiated).async {
            let summary = self.analyzer.analyze(
                duration: duration,
                distance: distanceSnapshot,
                cadenceSamples: cadenceSamples,
                speedSamples: speedSamples,
                targetCadenceRange: 160...180
            )

            self.healthKitService.saveWorkout(from: summary) { uuid in
                let context = self.persistence.container.viewContext
                context.perform {
                    let run = Run(context: context)
                    run.id = UUID()
                    run.startDate = Date().addingTimeInterval(-summary.duration)
                    run.endDate = Date()
                    run.duration = summary.duration
                    run.distance = summary.distance
                    run.avgSpeed = summary.avgSpeed
                    run.maxSpeed = summary.maxSpeed
                    run.avgCadence = summary.avgCadence
                    run.maxCadence = summary.maxCadence
                    run.longestSteadyPaceDuration = summary.longestSteadyPaceDuration
                    run.isCadenceGood = summary.isCadenceGood
                    run.hkWorkoutUUID = uuid ?? UUID()

                    let route = Route(context: context)
                    route.id = UUID()
                    route.coordinatesData = self.encodeCoordinates(coords)
                    run.route = route
                    route.parentRun = run

                    do {
                        try context.save()
                    } catch {
                        print("Save run error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func updateAvgSpeed() {
        guard elapsedTime > 0 else {
            avgSpeed = 0
            return
        }
        avgSpeed = distance / elapsedTime
    }

    private func encodeCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> Data? {
        let simple = coordinates.map { ["lat": $0.latitude, "lon": $0.longitude] }
        return try? JSONEncoder().encode(simple)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            Task { @MainActor in
                self.elapsedTime = Date().timeIntervalSince(start)
                self.updateAvgSpeed()
            }
        }
    }
}

