//
//  RouteModel.swift
//  RapidoMapsTest
//
//  Created by Sanket  Ray on 31/03/25.
//

import Foundation
import CoreLocation

struct RoutePoint {
    let coordinate: CLLocationCoordinate2D
    let timestamp: TimeInterval
}

final class RouteModel: RouteModelProtocol {
    private let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        setupLocationManager()
    }
    
    func generateRoute(to destination: CLLocationCoordinate2D) -> [RoutePoint] {
        guard let currentLocation = locationManager.location?.coordinate else {
            return []
        }
        
        return generateIntermediatePoints(from: currentLocation, to: destination)
    }
}

private extension RouteModel {
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func generateIntermediatePoints(from startCoordinate: CLLocationCoordinate2D,
                                  to endCoordinate: CLLocationCoordinate2D) -> [RoutePoint] {
        let totalPoints = 30 // 1 point per second for 30 seconds
        var route: [RoutePoint] = []
        
        for i in 0...totalPoints {
            let progress = Double(i) / Double(totalPoints)
            let lat = startCoordinate.latitude + (endCoordinate.latitude - startCoordinate.latitude) * progress
            let lng = startCoordinate.longitude + (endCoordinate.longitude - startCoordinate.longitude) * progress
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let timestamp = Double(i)
            
            route.append(RoutePoint(coordinate: coordinate, timestamp: timestamp))
        }
        
        return route
    }
}
