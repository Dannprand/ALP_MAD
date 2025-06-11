//
//  LocationServiceProtocol.swift
//  ALP-MAD
//
//  Created by Kevin Christian on 12/06/25.
//

import CoreLocation

protocol LocationServiceProtocol {
    var lastLocation: CLLocation? { get }
    
    func requestLocation()
    func calculateDistance(from location: CLLocation) -> CLLocationDistance?
}
