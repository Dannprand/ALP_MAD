//
//  ChatRoom.swift
//  ALP-MAD
//
//  Created by student on 11/06/25.
//

import FirebaseFirestore

struct ChatRoom: Identifiable, Equatable {
    enum ChatType {
        case event
        case community
    }
    
    let id: String
    let title: String
    let lastMessage: String
    let timestamp: Date
    let type: ChatType
    var event: Event?
    
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}
