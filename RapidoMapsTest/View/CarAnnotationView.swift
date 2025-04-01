//
//  CarAnnotationView.swift
//  RapidoMapsTest
//
//  Created by Sanket  Ray on 31/03/25.
//

import UIKit
import MapKit

/// Represents a car annotation on the map with dynamic coordinate updates
final class CarAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

/// Custom annotation view that displays a car icon on the map
final class CarAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
}

private extension CarAnnotationView {
    func setupView() {
        image = UIImage(systemName: "car.fill")
        frame.size = CGSize(width: 30, height: 30)
        tintColor = .blue
    }
}
