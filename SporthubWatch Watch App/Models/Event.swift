//
//  Event.swift
//  SporthubWatch Watch App
//
//  Created by Kevin Christian on 12/06/25.
//
//
//  Event.swift
//  SporthubWatch Watch App
//
//  Created by Kevin Christian on 12/06/25.
//

import Foundation
import CoreLocation

struct Event: Identifiable, Codable, Hashable {
    var id: String?
    let title: String
    let description: String
    let hostId: String
    let sport: SportCategory
    let date: Date
    let location: EventLocation
    let maxParticipants: Int
    var participants: [String]
    let isFeatured: Bool
    let isTournament: Bool
    let prizePool: String?
    let rules: String?
    let requirements: String?
    let chatId: String
    let createdAt: Date
    var isEnded: Bool

    var shouldBeEnded: Bool {
        return date < Date()
    }

    var isFull: Bool {
        participants.count >= maxParticipants
    }

    var timeRemaining: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // Memberwise initializer
    init(
        id: String,
        title: String,
        description: String,
        hostId: String,
        sport: SportCategory,
        date: Date,
        location: EventLocation,
        maxParticipants: Int,
        participants: [String],
        isFeatured: Bool,
        isTournament: Bool,
        prizePool: String? = nil,
        rules: String? = nil,
        requirements: String? = nil,
        chatId: String,
        createdAt: Date,
        isEnded: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.hostId = hostId
        self.sport = sport
        self.date = date
        self.location = location
        self.maxParticipants = maxParticipants
        self.participants = participants
        self.isFeatured = isFeatured
        self.isTournament = isTournament
        self.prizePool = prizePool
        self.rules = rules
        self.requirements = requirements
        self.chatId = chatId
        self.createdAt = createdAt
        self.isEnded = isEnded
    }

    static func placeholder(id: String = "") -> Event {
        return Event(
            id: id,
            title: "Unknown",
            description: "",
            hostId: "",
            sport: .other,
            date: Date(),
            location: EventLocation(name: "", address: "", latitude: 0.0, longitude: 0.0),
            maxParticipants: 1,
            participants: [],
            isFeatured: false,
            isTournament: false,
            prizePool: nil,
            rules: nil,
            requirements: nil,
            chatId: "",
            createdAt: Date(),
            isEnded: false
        )
    }
}

struct EventLocation: Codable, Hashable, Identifiable {
    var id: String { "\(latitude)-\(longitude)" }
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(name: String, address: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}

// Basic sport enum for compatibility
enum SportCategory: String, Codable, CaseIterable, Hashable {
    case football, basketball, tennis, running, swimming, other
}
