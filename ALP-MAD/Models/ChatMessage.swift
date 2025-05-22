//
//  ChatMessage.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import FirebaseFirestoreSwift

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let senderId: String
    let senderName: String
    let text: String
    let timestamp: Timestamp
    let eventId: String
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp.dateValue())
    }
}
