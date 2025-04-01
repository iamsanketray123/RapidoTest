//
//  DriverSimulationVC.swift
//  RapidoMapsTest
//
//  Created by Sanket  Ray on 31/03/25.
//

import UIKit
import MapKit
import CoreLocation

/// Main view controller responsible for displaying the driver simulation interface
final class DriverSimulationViewController: UIViewController {
    // MARK: - Properties
    
    /// MapView instance for displaying the route and car location
    private let mapView: MKMapView
    
    /// Button to control the simulation state
    private let startButton: UIButton
    
    /// ViewModel that handles the simulation logic
    private let viewModel: DriverSimulationViewModel
    
    /// Annotation representing the car on the map
    private var carAnnotation: CarAnnotation?
    
    /// Overlay showing the route path
    private var routeOverlay: MKPolyline?
    
    private let destinationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter destination"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Initialization
    
    /// Dependency injection initializer
    init(mapView: MKMapView = MKMapView(),
         startButton: UIButton = UIButton(type: .system),
         viewModel: DriverSimulationViewModel = DriverSimulationViewModel()) {
        self.mapView = mapView
        self.startButton = startButton
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
        setupSearchHandling()
        setupMapView()
    }
}

private extension DriverSimulationViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure Auto Layout for all views
        mapView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        destinationTextField.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Map View
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.isUserInteractionEnabled = true
        
        // Destination Text Field
        destinationTextField.placeholder = "Enter destination"
        destinationTextField.borderStyle = .roundedRect
        destinationTextField.backgroundColor = .secondarySystemBackground
        destinationTextField.textColor = .label
        destinationTextField.font = .systemFont(ofSize: 16)
        destinationTextField.layer.cornerRadius = 8
        destinationTextField.layer.borderWidth = 1
        destinationTextField.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Search Button
        searchButton.setTitle("Search", for: .normal)
        searchButton.backgroundColor = .systemBlue
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = 8
        searchButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Start Button
        startButton.setTitle("Start Simulation", for: .normal)
        startButton.backgroundColor = .systemGreen
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 25
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        // Add views to hierarchy
        view.addSubview(mapView)
        view.addSubview(startButton)
        view.addSubview(destinationTextField)
        view.addSubview(searchButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Map View
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
            
            // Start Button
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Search Container
            destinationTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            destinationTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            destinationTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10),
            destinationTextField.heightAnchor.constraint(equalToConstant: 44),
            
            searchButton.topAnchor.constraint(equalTo: destinationTextField.topAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchButton.widthAnchor.constraint(equalToConstant: 80),
            searchButton.heightAnchor.constraint(equalTo: destinationTextField.heightAnchor)
        ])
    }
    
    func setupSearchHandling() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        destinationTextField.delegate = self
        
        // Add tap gesture to dismiss keyboard when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func drawRoute() {
        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)
        
        // Create polyline points from route
        let points = viewModel.route.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: points, count: points.count)
        
        // Add to map
        mapView.addOverlay(polyline)
        
        // Set initial region to show entire route
        if let firstPoint = viewModel.route.first?.coordinate,
           let lastPoint = viewModel.route.last?.coordinate {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (firstPoint.latitude + lastPoint.latitude) / 2,
                    longitude: (firstPoint.longitude + lastPoint.longitude) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: abs(firstPoint.latitude - lastPoint.latitude) * 1.5,
                    longitudeDelta: abs(firstPoint.longitude - lastPoint.longitude) * 1.5
                )
            )
            mapView.setRegion(region, animated: true)
            
            // Add or update car annotation
            if let carAnnotation = carAnnotation {
                carAnnotation.coordinate = firstPoint
            } else {
                carAnnotation = CarAnnotation(coordinate: firstPoint)
                mapView.addAnnotation(carAnnotation!)
            }
        }
    }
    
    @objc func searchButtonTapped() {
        // Dismiss keyboard
        view.endEditing(true)
        
        guard let destinationText = destinationTextField.text, !destinationText.isEmpty else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(destinationText) { [weak self] placemarks, error in
            guard let self = self,
                  let location = placemarks?.first?.location?.coordinate else {
                print("Location not found ❗️❗️❗️")
                return
            }
            
            // Create source and destination placemarks
            let sourcePlacemark = MKPlacemark(coordinate: self.mapView.userLocation.coordinate)
            let destinationPlacemark = MKPlacemark(coordinate: location)
            
            // Create map items
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            // Create directions request
            let request = MKDirections.Request()
            request.source = sourceMapItem
            request.destination = destinationMapItem
            request.transportType = .automobile
            
            // Calculate directions
            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                guard let self = self,
                      let route = response?.routes.first else {
                    print("Could not calculate route ❗️❗️❗️")
                    return
                }
                
                // Remove existing overlays
                self.mapView.removeOverlays(self.mapView.overlays)
                
                // Add the new route
                self.mapView.addOverlay(route.polyline)
                
                // Update view model
                self.viewModel.loadRoute(to: location)
                
                // Set region to show entire route
                let region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: (self.mapView.userLocation.coordinate.latitude + location.latitude) / 2,
                        longitude: (self.mapView.userLocation.coordinate.longitude + location.longitude) / 2
                    ),
                    span: MKCoordinateSpan(
                        latitudeDelta: abs(self.mapView.userLocation.coordinate.latitude - location.latitude) * 1.5,
                        longitudeDelta: abs(self.mapView.userLocation.coordinate.longitude - location.longitude) * 1.5
                    )
                )
                self.mapView.setRegion(region, animated: true)
                
                // Add or update car annotation
                if let carAnnotation = self.carAnnotation {
                    carAnnotation.coordinate = self.mapView.userLocation.coordinate
                } else {
                    self.carAnnotation = CarAnnotation(coordinate: self.mapView.userLocation.coordinate)
                    self.mapView.addAnnotation(self.carAnnotation!)
                }
            }
        }
    }
    
    @objc func startButtonTapped() {
        if viewModel.isSimulationRunning {
            viewModel.stopSimulation()
            startButton.setTitle("Start Simulation", for: .normal)
        } else {
            viewModel.startSimulation()
            startButton.setTitle("Stop Simulation", for: .normal)
        }
    }
}

// MARK: - Map View Delegate
extension DriverSimulationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location blue dot
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CarAnnotation"
        
        guard annotation is CarAnnotation else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CarAnnotationView
        
        if annotationView == nil {
            annotationView = CarAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
}

// MARK: - ViewModel Delegate
extension DriverSimulationViewController: DriverSimulationViewModelDelegate {
    func didUpdateCurrentLocation(_ location: CLLocationCoordinate2D) {
        // Only update car position, not map region
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let carAnnotation = self.carAnnotation {
                UIView.animate(withDuration: 1.0) {
                    carAnnotation.coordinate = location
                }
            }
        }
    }
    
    func didUpdateMapRegion(_ region: MKCoordinateRegion) {
        // Only update region when initially setting up the route
        if !viewModel.isSimulationRunning {
            DispatchQueue.main.async { [weak self] in
                self?.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func didUpdateSimulationStatus(_ isRunning: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.startButton.setTitle(isRunning ? "Stop Simulation" : "Start Simulation", for: .normal)
        }
    }
}

// MARK: - UITextFieldDelegate
extension DriverSimulationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchButtonTapped()
        return true
    }
}
