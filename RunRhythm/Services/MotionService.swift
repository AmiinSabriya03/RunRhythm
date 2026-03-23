//  MotionService.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-07.
//

import Foundation
import CoreMotion
import Combine

class MotionService: ObservableObject {
    
    private let pedometer = CMPedometer()
    
    @Published var currentCadence: Double = 0
    
    func start() {
        guard CMPedometer.isCadenceAvailable() else { return }
        
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let data = data,
                  let cadence = data.currentCadence else { return }
            
            let spm = cadence.doubleValue * 60
            
            if spm > 0 {
                DispatchQueue.main.async {
                    self?.currentCadence = spm
                }
            }
        }
    }
    
    func stop() {
        pedometer.stopUpdates()
    }
}
