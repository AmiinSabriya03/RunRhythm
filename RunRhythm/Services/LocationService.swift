//
//  LocationService.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-04.
//

import Combine
import Foundation
import CoreLocation

final class LocationService: NSObject, ObservableObject {

    private let manager = CLLocationManager()

    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var pathCoordinates: [CLLocationCoordinate2D] = []
    @Published private(set) var totalDistance: Double = 0        // meter
    @Published private(set) var currentSpeed: Double = 0         // m/s
    @Published private(set) var maxSpeed: Double = 0             // m/s

    private var speedSamples: [SpeedSample] = []

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
    }

    // Be användaren om GPS-tillstånd
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    // Starta positionsuppdateringar
    func start() {
        manager.startUpdatingLocation()
    }

    // Stoppa positionsuppdateringar
    func stop() {
        manager.stopUpdatingLocation()
    }

    // Nollställ inför nytt pass
    func resetForNewRun() {
        currentLocation = nil
        pathCoordinates.removeAll()
        totalDistance = 0
        currentSpeed = 0
        maxSpeed = 0
        speedSamples.removeAll()
    }

    // Exportera samples till RunAnalyzer
    func exportSamples() -> [SpeedSample] {
        speedSamples
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        case .denied, .restricted:
            // Här kan ni lägga logg eller UI-varning senare
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
              newLocation.horizontalAccuracy >= 0 else { return }

        DispatchQueue.main.async {
            if let last = self.currentLocation {
                let delta = newLocation.distance(from: last)
                self.totalDistance += delta
            }

            self.currentLocation = newLocation
            self.pathCoordinates.append(newLocation.coordinate)

            let speed = max(newLocation.speed, 0)
            self.currentSpeed = speed
            self.maxSpeed = max(self.maxSpeed, speed)

            let sample = SpeedSample(timestamp: Date(), speed: speed)
            self.speedSamples.append(sample)
            
            print("LOCATION UPDATE", newLocation.coordinate,
                  "dist:", self.totalDistance,
                  "speed:", self.currentSpeed)

        }
    }


    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
