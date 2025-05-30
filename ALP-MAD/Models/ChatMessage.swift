//
//  ChatMessage.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

//import FirebaseFirestoreSwift
//
//struct ChatMessage: Identifiable, Codable {
//    @DocumentID var id: String?
//    let senderId: String
//    let senderName: String
//    let text: String
//    let timestamp: Timestamp
//    let eventId: String
//    
//    var timeString: String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: timestamp.dateValue())
//    }
//}

import FirebaseFirestore

struct ChatMessage: Identifiable, Codable, Equatable {
    var id: String
    let senderId: String
    let senderName: String
    let text: String
    let timestamp: Timestamp
    let eventId: String

    // Custom initializer for manual creation
    init(
        id: String = UUID().uuidString,
        senderId: String,
        senderName: String,
        text: String,
        timestamp: Timestamp,
        eventId: String
    ) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.text = text
        self.timestamp = timestamp
        self.eventId = eventId
    }

    // Computed property for formatted time
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp.dateValue())
    }

    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "senderId": senderId,
            "senderName": senderName,
            "text": text,
            "timestamp": timestamp,
            "eventId": eventId
        ]
    }

    // Initialize from Firestore document
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let senderId = data["senderId"] as? String,
              let senderName = data["senderName"] as? String,
              let text = data["text"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let eventId = data["eventId"] as? String else {
            print("❌ Failed to parse chat message")
            return nil
        }

        self.id = document.documentID
        self.senderId = senderId
        self.senderName = senderName
        self.text = text
        self.timestamp = timestamp
        self.eventId = eventId
    }

}
