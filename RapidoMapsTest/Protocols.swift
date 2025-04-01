import Foundation
import CoreLocation
import MapKit

protocol RouteModelProtocol {
    func generateRoute(to destination: CLLocationCoordinate2D, completion: @escaping ([RoutePoint]) -> Void)
}

protocol TimerProviding {
    func scheduledTimer(withTimeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer
}
