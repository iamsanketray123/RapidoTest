//
//  DriverSimulationViewModel.swift
//  RapidoMapsTest
//
//  Created by Sanket  Ray on 31/03/25.
//

import Foundation
import MapKit
import CoreLocation

/// Default implementation of TimerProviding using system Timer
final class DefaultTimerProvider: TimerProviding {
    func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
    }
}

/// Delegate protocol for handling driver simulation updates
protocol DriverSimulationViewModelDelegate: AnyObject {
    /// Called when the driver's location is updated
    /// - Parameter location: The new coordinate of the driver
    func didUpdateCurrentLocation(_ location: CLLocationCoordinate2D)
    
    /// Called when the map region should be updated
    /// - Parameter region: The new map region to display
    func didUpdateMapRegion(_ region: MKCoordinateRegion)
    
    /// Called when the simulation status changes
    /// - Parameter isRunning: Boolean indicating if simulation is running
    func didUpdateSimulationStatus(_ isRunning: Bool)
}

/// ViewModel responsible for managing the driver simulation state and logic
final class DriverSimulationViewModel: NSObject {
    // MARK: - Dependencies
    
    private let routeModel: RouteModelProtocol
    private let timerProvider: TimerProviding
    private var timer: Timer?
    private var currentIndex = 0
    
    weak var delegate: DriverSimulationViewModelDelegate?
    
    private let locationManager: CLLocationManager
    
    // MARK: - Properties
    
    /// Array of route points representing the path
    var route: [RoutePoint] = []
    
    /// Current location of the simulated driver
    var currentLocation: CLLocationCoordinate2D?
    
    /// Flag indicating if simulation is in progress
    var isSimulationRunning = false
    
    /// Current map region being displayed
    var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7812, longitude: -73.9665),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    init(routeModel: RouteModelProtocol = RouteModel(),
         timerProvider: TimerProviding = DefaultTimerProvider(),
         locationManager: CLLocationManager = CLLocationManager()) {
        self.routeModel = routeModel
        self.timerProvider = timerProvider
        self.locationManager = locationManager
        super.init()
        setupLocationManager()
    }
    
    func loadRoute(to destination: CLLocationCoordinate2D) {
        routeModel.generateRoute(to: destination) { [weak self] routePoints in
            guard let self = self else { return }
            
            self.route = routePoints
            if let firstPoint = routePoints.first {
                self.currentLocation = firstPoint.coordinate
                self.centerMapOnLocation(coordinate: firstPoint.coordinate)
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startSimulation() {
        guard !route.isEmpty, !isSimulationRunning else { return }
        
        isSimulationRunning = true
        currentIndex = 0
        currentLocation = route[currentIndex].coordinate
        
        delegate?.didUpdateCurrentLocation(route[currentIndex].coordinate)
        delegate?.didUpdateSimulationStatus(isSimulationRunning)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentIndex += 1
            
            if self.currentIndex < self.route.count {
                self.currentLocation = self.route[self.currentIndex].coordinate
                self.delegate?.didUpdateCurrentLocation(self.route[self.currentIndex].coordinate)
                self.centerMapOnLocation(coordinate: self.route[self.currentIndex].coordinate)
            } else {
                self.stopSimulation()
            }
        }
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
        isSimulationRunning = false
        delegate?.didUpdateSimulationStatus(isSimulationRunning)
    }
    
    private func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        // Only center map if simulation is not running
        if !isSimulationRunning {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
            delegate?.didUpdateMapRegion(region)
        }
    }
    
    deinit {
        stopSimulation()
    }
}

// MARK: - CLLocationManagerDelegate
extension DriverSimulationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        centerMapOnLocation(coordinate: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}
