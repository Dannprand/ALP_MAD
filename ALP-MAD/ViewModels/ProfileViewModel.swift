//
//  ProfileViewModel.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

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

            let hosted = try hostedSnapshot.documents.compactMap { document in
                try document.data(as: Event.self)
            }

            // Fetch joined events
            // Fetch joined events without the inequality filter
            let joinedSnapshot = try await db.collection("events")
                .whereField("participants", arrayContains: userId)
                .order(by: "date", descending: true)
                .limit(to: 5)
                .getDocuments()

            // Then filter out hosted events in memory
            let joined = try joinedSnapshot.documents.compactMap { document in
                let event = try document.data(as: Event.self)
                return event.hostId != userId ? event : nil
            }
//            let joinedSnapshot = try await db.collection("events")
//                .whereField("participants", arrayContains: userId)
//                .whereField("hostId", isNotEqualTo: userId)
//                .order(by: "date", descending: true)
//                .limit(to: 5)
//                .getDocuments()
//
//            let joined = try joinedSnapshot.documents.compactMap { document in
//                try document.data(as: Event.self)
//            }

            // ✅ Update UI on main thread
            await MainActor.run {
                self.hostedEvents = hosted
                self.joinedEvents = joined
            }

        } catch {
            print("Error fetching user events: \(error)")
            await MainActor.run {
                self.hostedEvents = []
                self.joinedEvents = []
            }
        }
    }


//    func fetchUserEvents(userId: String) async {
//        let db = Firestore.firestore()
//
//        do {
//            // Fetch hosted events
//            let hostedSnapshot = try await db.collection("events")
//                .whereField("hostId", isEqualTo: userId)
//                .order(by: "date", descending: true)
//                .limit(to: 5)
//                .getDocuments()
//
//            hostedEvents = try hostedSnapshot.documents.compactMap { document in
//                try document.data(as: Event.self)
//            }
//
//            // Fetch joined events
//            let joinedSnapshot = try await db.collection("events")
//                .whereField("participants", arrayContains: userId)
//                .whereField("hostId", isNotEqualTo: userId) // exclude hosted events
//                .order(by: "date", descending: true)
//                .limit(to: 5)
//                .getDocuments()
//
//            joinedEvents = try joinedSnapshot.documents.compactMap { document in
//                try document.data(as: Event.self)
//            }
//        } catch {
//            print("Error fetching user events: \(error)")
//            hostedEvents = []
//            joinedEvents = []
//        }
//    }
}

