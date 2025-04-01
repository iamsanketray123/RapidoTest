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

class RouteModel {
    // Sample route from Central Park to Times Square in NYC
    func generateRoute() -> [RoutePoint] {
        let startCoordinate = CLLocationCoordinate2D(latitude: 40.7812, longitude: -73.9665) // Central Park
        let endCoordinate = CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855) // Times Square
        
        // Generating intermediate points along the route
        // In a real app, you would use MapKit's directions service or Google Maps API
        let totalPoints = 30 // 1 point per second for 30 seconds
        var route: [RoutePoint] = []
        
        for i in 0...totalPoints {
            let progress = Double(i) / Double(totalPoints)
            let lat = startCoordinate.latitude + (endCoordinate.latitude - startCoordinate.latitude) * progress
            let lng = startCoordinate.longitude + (endCoordinate.longitude - startCoordinate.longitude) * progress
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let timestamp = Double(i) // 1 second per point
            
            route.append(RoutePoint(coordinate: coordinate, timestamp: timestamp))
        }
        
        return route
    }
}
