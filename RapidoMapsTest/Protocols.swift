import Foundation
import CoreLocation
import MapKit

protocol RouteModelProtocol {
    func generateRoute(to destination: CLLocationCoordinate2D) -> [RoutePoint]
}

protocol TimerProviding {
    func scheduledTimer(withTimeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer
}
