import Foundation
import CoreLocation

final class LocationService: NSObject {
    static let shared = LocationService()

    private let manager = CLLocationManager()

    override private init() {
        super.init()
        manager.delegate = self
    }

    // Request permission and expose user location when you add the feed sort-by-distance
}

extension LocationService: CLLocationManagerDelegate {}
