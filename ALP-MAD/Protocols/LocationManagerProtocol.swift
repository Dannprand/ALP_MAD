//
//  LocationManagerProtocol.swift
//  ALP-MAD
//
//  Created by student on 12/06/25.
//

// File: ALP-MAD/Protocols/LocationManagerProtocol.swift
import CoreLocation

protocol LocationManagerProtocol {
    var lastLocation: CLLocation? { get }
    func requestLocation()
}
