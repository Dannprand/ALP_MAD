import Foundation
import FirebaseFirestore
import CoreLocation

struct Event: Identifiable, Codable, Hashable {
    var id: String?
    let title: String
    let description: String
    let hostId: String
    let sport: SportCategory
    let date: Timestamp
    let expiryDate: Timestamp
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

    var isFull: Bool {
        participants.count >= maxParticipants
    }

    var isExpired: Bool {
        expiryDate.dateValue() < Date()
    }

    var timeRemaining: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date.dateValue(), relativeTo: Date())
    }

    var expiryStatus: String {
        if isExpired {
            return "Expired"
        } else {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return "Expires \(formatter.localizedString(for: expiryDate.dateValue(), relativeTo: Date()))"
        }
    }

    init(
        id: String? = nil,
        title: String,
        description: String,
        hostId: String,
        sport: SportCategory,
        date: Timestamp,
        expiryDate: Timestamp,
        location: EventLocation,
        maxParticipants: Int,
        participants: [String],
        isFeatured: Bool,
        isTournament: Bool,
        prizePool: String? = nil,
        rules: String? = nil,
        requirements: String? = nil,
        chatId: String,
        createdAt: Timestamp
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.hostId = hostId
        self.sport = sport
        self.date = date
        self.expiryDate = expiryDate
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
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let hostId = data["hostId"] as? String,
            let sportRaw = data["sport"] as? String,
            let sport = SportCategory(rawValue: sportRaw),
            let date = data["date"] as? Timestamp,
            let expiryDate = data["expiryDate"] as? Timestamp,
            let locationData = data["location"] as? [String: Any],
            let maxParticipants = data["maxParticipants"] as? Int,
            let participants = data["participants"] as? [String],
            let isFeatured = data["isFeatured"] as? Bool,
            let isTournament = data["isTournament"] as? Bool,
            let chatId = data["chatId"] as? String,
            let createdAt = data["createdAt"] as? Timestamp
        else {
            return nil
        }

        self.id = document.documentID
        self.title = title
        self.description = description
        self.hostId = hostId
        self.sport = sport
        self.date = date
        self.expiryDate = expiryDate
        self.location = EventLocation(dictionary: locationData)
        self.maxParticipants = maxParticipants
        self.participants = participants
        self.isFeatured = isFeatured
        self.isTournament = isTournament
        self.prizePool = data["prizePool"] as? String
        self.rules = data["rules"] as? String
        self.requirements = data["requirements"] as? String
        self.chatId = chatId
        self.createdAt = createdAt
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "description": description,
            "hostId": hostId,
            "sport": sport.rawValue,
            "date": date,
            "expiryDate": expiryDate,
            "location": location.toDictionary(),
            "maxParticipants": maxParticipants,
            "participants": participants,
            "isFeatured": isFeatured,
            "isTournament": isTournament,
            "chatId": chatId,
            "createdAt": createdAt
        ]

        if let prizePool = prizePool {
            dict["prizePool"] = prizePool
        }
        if let rules = rules {
            dict["rules"] = rules
        }
        if let requirements = requirements {
            dict["requirements"] = requirements
        }

        return dict
    }

    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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

    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? "Unknown"
        self.address = dictionary["address"] as? String ?? "Unknown"
        self.latitude = dictionary["latitude"] as? Double ?? 0.0
        self.longitude = dictionary["longitude"] as? Double ?? 0.0
    }

    func toDictionary() -> [String: Any] {
        [
            "name": name,
            "address": address,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}
