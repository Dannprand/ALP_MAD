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

    static let sampleUser = DummyUser(
        username: "Yosafat Ryan Hendriko",
        email: "yosafathendriko26@example.com",
        bio: "Hi, my name is Yosafat and I love outdoor sports. It's my biggest passion in life!",
        sports: ["Jogging", "Badminton", "Marathon", "Padel", "Swimming"]
    )
}
