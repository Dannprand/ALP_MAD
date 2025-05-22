//
//  Event.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct Event: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let hostId: String
    let sport: SportCategory
    let date: Date
    let location: EventLocation
    let maxParticipants: Int
    var participants: [String] // User IDs
    let isFeatured: Bool
    let isTournament: Bool
    let prizePool: String?
    let rules: String?
    let requirements: String?
    let chatId: String
    let createdAt: Date
    
    var isFull: Bool {
        participants.count >= maxParticipants
    }
    
    var timeRemaining: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EventLocation: Codable, Hashable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum SportCategory: String, CaseIterable, Codable {
    case football = "Football"
    case basketball = "Basketball"
    case tennis = "Tennis"
    case volleyball = "Volleyball"
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case gym = "Gym"
    case other = "Other"
}
