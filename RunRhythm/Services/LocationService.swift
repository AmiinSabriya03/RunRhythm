//
//  LocationService.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-04.
//


import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    // MARK: - Published data
    @Published var totalDistance: Double = 0
    @Published var currentSpeed: Double = 0
    @Published var maxSpeed: Double = 0
    @Published var pathCoordinates: [CLLocationCoordinate2D] = []
    
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        
        // 🔥 Viktiga inställningar
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = kCLDistanceFilterNone
    }
    
    // MARK: - Permissions
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Start / Stop
    func start() {
        manager.startUpdatingLocation()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        print("📍 Location:", newLocation.coordinate)
        
        // ❌ Ignorera dålig GPS
        if newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 20 {
            print("⚠️ Bad accuracy:", newLocation.horizontalAccuracy)
            return
        }
        
        // Första location → sätt bara
        if lastLocation == nil {
            lastLocation = newLocation
            pathCoordinates.append(newLocation.coordinate)
            return
        }
        
        guard let last = lastLocation else { return }
        
        let delta = newLocation.distance(from: last)
        let time = newLocation.timestamp.timeIntervalSince(last.timestamp)
        
        // ❌ skydda mot konstiga timestamps
        if time <= 0 {
            lastLocation = newLocation
            return
        }
        
        let speed = delta / time
        
        print("📏 Raw delta:", delta)
        print("⏱ Time:", time)
        print("🏃 Raw speed:", speed)
        
        // ❌ FILTER 1: för små rörelser (GPS brus)
        if delta < 2 {
            print("⚠️ Ignored small movement")
            lastLocation = newLocation
            return
        }
        
        // ❌ FILTER 2: för stora hopp (GPS glitch)
        if delta > 20 {
            print("⚠️ Ignored big jump")
            lastLocation = newLocation
            return
        }
        
        // ❌ FILTER 3: orimlig hastighet
        if speed < 0.5 || speed > 6 {
            print("⚠️ Ignored unrealistic speed:", speed)
            lastLocation = newLocation
            return
        }
        
        // ✅ VALID DATA
        totalDistance += delta
        updateSpeed(speed)
        
        print("✅ Distance:", totalDistance)
        print("✅ Speed:", speed)
        
        lastLocation = newLocation
        pathCoordinates.append(newLocation.coordinate)
    }
    
    // MARK: - Speed
    private func updateSpeed(_ speed: Double) {
        currentSpeed = speed
        
        // ❗ skydda maxSpeed från spikes
        if speed < 6 {
            maxSpeed = max(maxSpeed, speed)
        }
    }
    
    // MARK: - Authorization Debug
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization:", manager.authorizationStatus.rawValue)
    }
}
