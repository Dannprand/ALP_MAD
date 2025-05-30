import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    var id: String
    let fullname: String
    let email: String
    var preferences: [SportCategory]
    var tokens: Int
    var joinedEvents: [String]
    var hostedEvents: [String]
    var profileImageUrl: String?
    var notificationEnabled: Bool = true

    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return fullname.components(separatedBy: " ").compactMap { $0.first?.uppercased() }.joined()
    }

    // Manual initializer
    init(
        id: String,
        fullname: String,
        email: String,
        preferences: [SportCategory] = [],
        tokens: Int = 0,
        joinedEvents: [String] = [],
        hostedEvents: [String] = [],
        profileImageUrl: String? = nil,
        notificationEnabled: Bool = true
    ) {
        self.id = id
        self.fullname = fullname
        self.email = email
        self.preferences = preferences
        self.tokens = tokens
        self.joinedEvents = joinedEvents
        self.hostedEvents = hostedEvents
        self.profileImageUrl = profileImageUrl
        self.notificationEnabled = notificationEnabled
    }

    // Init from Firestore document
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let fullname = data["fullname"] as? String,
              let email = data["email"] as? String else {
            return nil
        }

        self.id = document.documentID
        self.fullname = fullname
        self.email = email
        self.preferences = (data["preferences"] as? [String])?.compactMap { SportCategory(rawValue: $0) } ?? []
        self.tokens = data["tokens"] as? Int ?? 0
        self.joinedEvents = data["joinedEvents"] as? [String] ?? []
        self.hostedEvents = data["hostedEvents"] as? [String] ?? []
        self.profileImageUrl = data["profileImageUrl"] as? String
        self.notificationEnabled = data["notificationEnabled"] as? Bool ?? true
    }

    // Convert to Firestore dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "fullname": fullname,
            "email": email,
            "preferences": preferences.map { $0.rawValue },
            "tokens": tokens,
            "joinedEvents": joinedEvents,
            "hostedEvents": hostedEvents,
            "notificationEnabled": notificationEnabled
        ]

        if let profileImageUrl = profileImageUrl {
            dict["profileImageUrl"] = profileImageUrl
        }

        return dict
    }
}
