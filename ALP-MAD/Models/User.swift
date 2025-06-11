//
//  User.swift
//  ALP-MAD
//

import Foundation
import FirebaseFirestore

// MARK: - Enum SportCategory

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

// MARK: - Struct User

struct User: Identifiable, Codable {
    var id: String
    let fullname: String
    let email: String
    var preferences: [SportCategory]
    var skillLevel: SkillLevel?
    var joinedEvents: [String]
    var hostedEvents: [String]
    var profileImageUrl: String?
    var following: [String]?
    var followers: [String]?
    var notificationEnabled: Bool

    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return fullname.components(separatedBy: " ").reduce("") {
            ($0 == "" ? "" : "\($0.first?.uppercased() ?? "")") + "\($1.first?.uppercased() ?? "")"
        }
    }

    // Custom initializer (untuk test/mock)
    init(
        id: String,
        fullname: String,
        email: String,
        preferences: [SportCategory] = [],
        skillLevel: SkillLevel? = nil,
        joinedEvents: [String] = [],
        hostedEvents: [String] = [],
        profileImageUrl: String? = nil,
        following: [String]? = [],
        followers: [String]? = [],
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

    // Init dari Firestore document
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
        self.skillLevel = (data["skillLevel"] as? String).flatMap { SkillLevel(rawValue: $0) }
        self.joinedEvents = data["joinedEvents"] as? [String] ?? []
        self.hostedEvents = data["hostedEvents"] as? [String] ?? []
        self.profileImageUrl = data["profileImageUrl"] as? String
        self.following = data["following"] as? [String]
        self.followers = data["followers"] as? [String]
        self.notificationEnabled = data["notificationEnabled"] as? Bool ?? true
    }

    // Convert ke dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "fullname": fullname,
            "email": email,
            "preferences": preferences.map { $0.rawValue },
            "joinedEvents": joinedEvents,
            "hostedEvents": hostedEvents,
            "notificationEnabled": notificationEnabled
        ]

        if let skillLevel = skillLevel {
            dict["skillLevel"] = skillLevel.rawValue
        }
        if let profileImageUrl = profileImageUrl {
            dict["profileImageUrl"] = profileImageUrl
        }
        if let following = following {
            dict["following"] = following
        }
        if let followers = followers {
            dict["followers"] = followers
        }

        return dict
    }
}
