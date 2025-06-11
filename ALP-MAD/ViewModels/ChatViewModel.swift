import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    public var db = Firestore.firestore()
    public var listener: ListenerRegistration?

//    func setupChat(forEvent eventId: String) {
//        listener?.remove()
//
//        listener = db.collection("chats")
//            .document(eventId)
//            .collection("messages")
//            .order(by: "timestamp", descending: false)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//                if let error = error {
//                    print("Error fetching messages: \(error.localizedDescription)")
//                    return
//                }
//
//                self.messages = snapshot?.documents.compactMap { ChatMessage(document: $0) } ?? []
//            }
//    }
    
    func setupChat(forEvent eventId: String) {
        listener?.remove()
        
        listener = db.collection("chats")
            .document(eventId)
            .collection("messages")
//            .order(by: "timestamp", ascending: true)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    if change.type == .added {
                        if let message = ChatMessage(document: change.document) {
                            DispatchQueue.main.async {
                                self?.messages.append(message)
                            }
                        }
                    }
                }
            }
    }

    func sendMessage(_ message: ChatMessage) {
        let messageRef = db.collection("chats")
            .document(message.eventId)
            .collection("messages")
            .document(message.id)

        messageRef.setData(message.toDictionary()) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    // In your ChatViewModel
    func setUserOnlineStatus(eventId: String, userId: String, isOnline: Bool) {
        db.collection("chats").document(eventId)
            .collection("presence").document(userId)
            .setData(["isOnline": isOnline, "lastSeen": Timestamp()])
    }

    deinit {
        listener?.remove()
    }
}

