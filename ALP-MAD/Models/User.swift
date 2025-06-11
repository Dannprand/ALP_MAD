import FirebaseFirestore
import Foundation

enum SportCategory: String,CaseIterable, Codable {
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

enum SkillLevel: String,CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case professional = "Professional"
}

struct User: Identifiable, Codable {
    var id: String
    let fullname: String
    let email: String
    var preferences: [SportCategory]
    var skillLevel: [SkillLevel]
    var joinedEvents: [String]
    var hostedEvents: [String]
    var profileImageUrl: String?
    var following: [String]?
    var followers: [String]?
    var notificationEnabled: Bool = true

    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return fullname.components(separatedBy: " ").reduce("") {
            ($0 == "" ? "" : "\($0.first?.uppercased() ?? "")")
                + "\($1.first?.uppercased() ?? "")"
        }
    }

    init(
        id: String,
        fullname: String,
        email: String,
        preferences: [SportCategory] = [],
        skillLevel: [SkillLevel] = [],
        joinedEvents: [String] = [],
        hostedEvents: [String] = [],
        profileImageUrl: String? = nil,
        following: [String]? = nil,
        followers: [String]? = nil,
        notificationEnabled: Bool = true
    ) {
        self.id = id
        self.fullname = fullname
        self.email = email
        self.preferences = preferences
        self.skillLevel = skillLevel
        self.joinedEvents = joinedEvents
        self.hostedEvents = hostedEvents
        self.profileImageUrl = profileImageUrl
        self.following = following
        self.followers = followers
        self.notificationEnabled = notificationEnabled
    }

    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let fullname = data["fullname"] as? String,
              let email = data["email"] as? String else {
            return nil
        }

        self.id = document.documentID
        self.fullname = fullname
        self.email = email
        self.preferences = (data["preferences"] as? [String])?.compactMap {
            SportCategory(rawValue: $0)
        } ?? []
        self.skillLevel = (data["skillLevel"] as? [String])?.compactMap {
            SkillLevel(rawValue: $0)
        } ?? []
        self.joinedEvents = data["joinedEvents"] as? [String] ?? []
        self.hostedEvents = data["hostedEvents"] as? [String] ?? []
        self.profileImageUrl = data["profileImageUrl"] as? String
        self.notificationEnabled = data["notificationEnabled"] as? Bool ?? true
        self.following = data["following"] as? [String]
        self.followers = data["followers"] as? [String]
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "fullname": fullname,
            "email": email,
            "preferences": preferences.map { $0.rawValue },
            "skillLevel": skillLevel.map { $0.rawValue },
            "joinedEvents": joinedEvents,
            "hostedEvents": hostedEvents,
            "notificationEnabled": notificationEnabled,
            "following": following as Any,
            "followers": followers as Any
        ]

        if let profileImageUrl = profileImageUrl {
            dict["profileImageUrl"] = profileImageUrl
        }

        return dict
    }
}
