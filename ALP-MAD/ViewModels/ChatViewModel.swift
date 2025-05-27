//
//  ChatViewModel.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func setupChat(forEvent eventId: String) {
        // Remove previous listener if any
        listener?.remove()
        
        listener = db.collection("chats")
            .whereField("eventId", isEqualTo: eventId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.messages = documents.compactMap { document in
                    try? document.data(as: ChatMessage.self)
                }
            }
    }
    
    func sendMessage(_ message: ChatMessage) {
        do {
            let _ = try db.collection("chats").document(message.id).setData(from: message)
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    deinit {
        listener?.remove()
    }
}
