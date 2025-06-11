//
//  ProfileViewModel.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var hostedEvents: [Event]? = []
    @Published var joinedEvents: [Event]? = []

    func fetchUserEvents(userId: String) async {
        let db = Firestore.firestore()

        do {
            // Fetch hosted events
            let hostedSnapshot = try await db.collection("events")
                .whereField("hostId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .limit(to: 5)
                .getDocuments()

            hostedEvents = try hostedSnapshot.documents.compactMap { document in
                try document.data(as: Event.self)
            }

            // Fetch joined events
            let joinedSnapshot = try await db.collection("events")
                .whereField("participants", arrayContains: userId)
                .whereField("hostId", isNotEqualTo: userId) // exclude hosted events
                .order(by: "date", descending: true)
                .limit(to: 5)
                .getDocuments()

            joinedEvents = try joinedSnapshot.documents.compactMap { document in
                try document.data(as: Event.self)
            }
        } catch {
            print("Error fetching user events: \(error)")
            hostedEvents = []
            joinedEvents = []
        }
    }
}

