//
//  RealLocationManager.swift
//  ALP-MAD
//
//  Created by student on 12/06/25.
//

// File: ALP-MAD/Services/LocationService/RealLocationManager.swift

// File: ALP-MAD/Services/LocationService/RealLocationManager.swift
import CoreLocation

class RealLocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Implement the required protocol method
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
//import CoreLocation
//
//class RealLocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//    var lastLocation: CLLocation?
//    
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//    
//    func requestLocation() {
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestLocation()
//    }
//    
//    // MARK: - CLLocationManagerDelegate
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        lastLocation = locations.last
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Location manager failed with error: \(error.localizedDescription)")
//    }
//}
