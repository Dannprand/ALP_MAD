//
//  EventService.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseFirestore

class EventService {
    private let db = Firestore.firestore()

    func deleteEvent(eventId: String, completion: @escaping (Error?) -> Void) {
        db.collection("events").document(eventId).delete { error in
            completion(error)
        }
    }
}
