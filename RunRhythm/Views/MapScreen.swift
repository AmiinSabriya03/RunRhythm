//
//  MapScreen.swift
//  RunRhythm
//
//  Created by Amiin Sabriya on 2026-01-08.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    @ObservedObject var locationService: LocationService

    var body: some View {
        let coords = locationService.pathCoordinates
        RouteMapView(coordinates: coords)
            .ignoresSafeArea()
    }
}
