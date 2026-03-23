//  RunSessionViewModel.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-07.
//

import Foundation
import Combine
import CoreData

enum RunState {
    case idle
    case running
    case paused
}

class RunSessionViewModel: ObservableObject {
    
    // MARK: - Services
    private let locationService: LocationService
    private let motionService: MotionService
    private let healthKitService: HealthKitService
    private let speechService = SpeechService()
    private let context: NSManagedObjectContext
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Data storage (NEW)
    private var cadenceSamples: [Double] = []
    
    // MARK: - Published
    @Published var distance: Double = 0
    @Published var currentSpeed: Double = 0
    @Published var avgSpeed: Double = 0
    @Published var cadence: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var state: RunState = .idle
    
    private var timer: Timer?
    private var lastSpokenMinute: Int = 0
    
    // MARK: - Init
    init(
        motionService: MotionService,
        locationService: LocationService,
        healthKitService: HealthKitService,
        context: NSManagedObjectContext
    ) {
        self.motionService = motionService
        self.locationService = locationService
        self.healthKitService = healthKitService
        self.context = context
        
        bindServices()
    }
    
    // MARK: - Start Run
    func startRun() {
        guard state != .running else { return }
        
        state = .running
        
        elapsedTime = 0
        distance = 0
        avgSpeed = 0
        cadenceSamples = [] // ✅ reset
        lastSpokenMinute = 0
        
        locationService.start()
        motionService.start()
        
        startTimer()
    }
    
    // MARK: - Pause
    func pauseRun() {
        guard state == .running else { return }
        
        state = .paused
        
        locationService.stop()
        motionService.stop()
        stopTimer()
    }
    
    // MARK: - Resume
    func resumeRun() {
        guard state == .paused else { return }
        
        state = .running
        
        locationService.start()
        motionService.start()
        startTimer()
    }
    
    // MARK: - Stop
    func stopRun() {
        guard state != .idle else { return }
        
        state = .idle
        
        locationService.stop()
        motionService.stop()
        stopTimer()
        
        saveWorkout()
    }
    
    // MARK: - Bind Services (UPDATED)
    private func bindServices() {
        
        locationService.$totalDistance
            .receive(on: DispatchQueue.main)
            .assign(to: &$distance)
        
        locationService.$currentSpeed
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentSpeed)
        
        // ✅ FIX: samla cadence samples
        motionService.$currentCadence
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.cadence = value
                self?.cadenceSamples.append(value)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            self.elapsedTime += 1
            self.updateAvgSpeed()
            
            let currentMinute = Int(self.elapsedTime) / 60
            
            if currentMinute > self.lastSpokenMinute {
                self.lastSpokenMinute = currentMinute
                self.speakCadence()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Avg Speed
    private func updateAvgSpeed() {
        if elapsedTime > 0 {
            avgSpeed = distance / elapsedTime
        }
    }
    
    // MARK: - Pace
    var pace: Double {
        guard currentSpeed > 0 else { return 0 }
        return (1000 / currentSpeed) / 60
    }
    
    // MARK: - TTS
    private func speakCadence() {
        let message: String
        
        switch cadence {
        case ..<150:
            message = "Bad Cadence!"
        case 150...180:
            message = "Good Cadence!"
        default:
            message = "Slow Cadence a little!"
        }
        
        speechService.speak(message)
    }
    
    // MARK: - Save Workout (FIXED)
    private func saveWorkout() {
        
        let startDate = Date().addingTimeInterval(-elapsedTime)
        
        // ✅ räkna riktig snitt cadence
        let avgCadence = cadenceSamples.isEmpty
            ? 0
            : cadenceSamples.reduce(0, +) / Double(cadenceSamples.count)
        
        let newRun = Run(context: context)
        newRun.id = UUID()
        newRun.startDate = startDate
        newRun.distance = distance
        newRun.duration = elapsedTime
        newRun.avgSpeed = avgSpeed
        newRun.avgCadence = avgCadence // ✅ FIX
        
        do {
            try context.save()
            print("✅ Run saved to Core Data")
        } catch {
            print("❌ Failed to save run:", error)
        }
        
        healthKitService.saveWorkout(
            distance: distance,
            startDate: startDate,
            endDate: Date()
        )
    }
}
