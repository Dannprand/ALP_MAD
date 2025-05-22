//
//  User.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let fullname: String
    let email: String
    var preferences: [SportCategory]
    var tokens: Int
    var joinedEvents: [String] // Event IDs
    var hostedEvents: [String] // Event IDs
    var profileImageUrl: String?
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return fullname.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first?.uppercased() ?? "")") + "\($1.first?.uppercased() ?? "")" }
    }
}
