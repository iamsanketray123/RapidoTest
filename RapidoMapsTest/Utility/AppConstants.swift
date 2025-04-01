//
//  AppConstants.swift
//  RapidoMapsTest
//
//  Created by Sanket  Ray on 01/04/25.
//

import Foundation

import UIKit

enum AppConstants {
    enum Strings {
        static let enterDestination = "Enter destination"
        static let search = "Search"
        static let startSimulation = "Start Simulation"
        static let stopSimulation = "Stop Simulation"
        static let error = "Error"
        static let ok = "OK"
        static let locationError = "Unable to get your current location. Please check location permissions."
        static let locationNotFound = "Location not found. Please try a different destination."
        static let noRouteFound = "No route found to this destination."
    }
    
    enum Layout {
        static let cornerRadius: CGFloat = 8
        static let buttonCornerRadius: CGFloat = 25
        static let borderWidth: CGFloat = 1
        static let shadowOpacity: Float = 0.2
        static let shadowRadius: CGFloat = 4
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let buttonScale: CGFloat = 0.98
        static let animationDuration: TimeInterval = 0.1
    }
    
    enum Spacing {
        static let standard: CGFloat = 20
        static let small: CGFloat = 10
        static let buttonHeight: CGFloat = 50
        static let textFieldHeight: CGFloat = 44
        static let searchButtonWidth: CGFloat = 80
    }
    
    enum Font {
        static let textFieldSize: CGFloat = 16
        static let buttonSize: CGFloat = 18
        static let buttonWeight: UIFont.Weight = .semibold
        static let searchButtonWeight: UIFont.Weight = .medium
    }
    
    enum Colors {
        static let buttonBackground = UIColor.systemBlue
        static let startButtonBackground = UIColor.systemGreen
        static let textFieldBorder = UIColor.systemGray4
        static let shadow = UIColor.black
    }
}
