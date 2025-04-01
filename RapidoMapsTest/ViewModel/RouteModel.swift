//
//  RouteModel.swift
//  RapidoMapsTest
//
//  Created by Sanket  Ray on 31/03/25.
//

import Foundation
import CoreLocation
import MapKit

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
    
    func generateRoute(to destination: CLLocationCoordinate2D, completion: @escaping ([RoutePoint]) -> Void) {
        guard let currentLocation = locationManager.location?.coordinate else {
            completion([])
            return
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: currentLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self,
                  let route = response?.routes.first else {
                completion([])
                return
            }
            
            let points = self.generateRoutePoints(from: route)
            completion(points)
        }
    }
}

private extension RouteModel {
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func generateRoutePoints(from route: MKRoute) -> [RoutePoint] {
        let coordinates = route.polyline.coordinates()
        let totalPoints = coordinates.count
        var routePoints: [RoutePoint] = []
        
        for (index, coordinate) in coordinates.enumerated() {
            let timestamp = Double(index)
            routePoints.append(RoutePoint(coordinate: coordinate, timestamp: timestamp))
        }
        
        return routePoints
    }
}

extension MKPolyline {
    func coordinates() -> [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
