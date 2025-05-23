//
//  DummyUser.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation

struct DummyUser {
    let username: String
    let email: String
    let bio: String
    let sports: [String]

    // Satu user contoh
    static let sampleUser = DummyUser(
        username: "Yosafat Ryan Hendriko",
        email: "yosafathendriko26@example.com",
        bio: "Hi, my name is Yosafat and I love outdoor sports. It's my biggest passion in life!",
        sports: ["Jogging", "Badminton", "Marathon", "Padel", "Swimming"]
    )

    // Beberapa user contoh lainnya
    static let sampleUsers: [DummyUser] = [
        DummyUser(username: "Alice Johnson", email: "alice@example.com", bio: "Love running & volleyball", sports: ["Running", "Volleyball"]),
        DummyUser(username: "Bob Smith", email: "bob@example.com", bio: "Basketball and coding are my life.", sports: ["Basketball", "Coding"]),
        DummyUser(username: "Charlie Adams", email: "charlie@example.com", bio: "Cycling enthusiast and coffee lover", sports: ["Cycling", "Coffee"]),
        DummyUser(username: "Diana Rose", email: "diana@example.com", bio: "Exploring nature one trail at a time", sports: ["Hiking", "Nature"])
    ]
}
