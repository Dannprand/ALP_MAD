//
//  LocationService.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    public let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness // Adjust based on your app's needs
    }
    
    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation() // Changed to startUpdatingLocation
        case .denied, .restricted:
            locationError = "Location access denied. Please enable in Settings."
        @unknown default:
            break
        }
    }
    
    // Combined both authorization change methods into one
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = "Location access denied"
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        manager.stopUpdatingLocation() // Stop after getting the location to save battery
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown, .denied:
                locationError = "Unable to determine location"
            case .network:
                locationError = "Network unavailable for location"
            default:
                locationError = "Location error: \(error.localizedDescription)"
            }
        }
        print("Location error: \(error.localizedDescription)")
    }
    
    func searchLocation(query: String, completion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        if let location = lastLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        } else {
            // Default region if no location is available
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    completion([])
                    return
                }
                completion(response?.mapItems ?? [])
            }
        }
    }
}
