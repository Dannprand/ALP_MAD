//
//  EventWatch.swift
//  SporthubWatchExtension
//
//  Created by student on 12/06/25.
//

import Foundation

struct Event: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let hostId: String
    let sport: SportCategory
    let date: Timestamp
    let location: EventLocation
    let maxParticipants: Int
    var participants: [String]
    let isFeatured: Bool
    let isTournament: Bool
    let prizePool: String?
    let rules: String?
    let requirements: String?
    let chatId: String
    let createdAt: Timestamp
    var isEnded: Bool
}

enum SportCategory: String, Codable, Hashable {
    case football, basketball, tennis, badminton, volleyball, running
}

struct EventLocation: Codable, Hashable {
    let name: String
    let latitude: Double
    let longitude: Double
}

struct Timestamp: Codable, Hashable {
    let seconds: Int
    let nanoseconds: Int
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(seconds))
    }
}

