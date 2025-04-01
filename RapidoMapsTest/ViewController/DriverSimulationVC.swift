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
        textField.text = "HSR Sector 1"
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
        view.backgroundColor = .white
        
        // Configure Auto Layout for all views
        mapView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        destinationTextField.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Map View
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        view.addSubview(mapView)
        
        // Start Button
        startButton.setTitle("Start Simulation", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
        
        // Add destination text field and search button
        view.addSubview(destinationTextField)
        view.addSubview(searchButton)
        
        // Layout
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            destinationTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            destinationTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            destinationTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10),
            destinationTextField.heightAnchor.constraint(equalToConstant: 40),
            
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
        mapView.showsUserLocation = true  // Show blue dot for current location
        mapView.userTrackingMode = .follow  // Follow user location
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
                // Handle error
                print("Location not found ❗️❗️❗️")
                return
            }
            
            self.viewModel.loadRoute(to: location)
            self.drawRoute()
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
        // Animate car to new position
        if let carAnnotation = carAnnotation {
            UIView.animate(withDuration: 1.0) {
                carAnnotation.coordinate = location
            }
        }
    }
    
    func didUpdateMapRegion(_ region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
    
    func didUpdateSimulationStatus(_ isRunning: Bool) {
        startButton.setTitle(isRunning ? "Stop Simulation" : "Start Simulation", for: .normal)
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
