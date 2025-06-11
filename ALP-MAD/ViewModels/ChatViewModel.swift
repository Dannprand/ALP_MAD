import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
        
    private var db = Firestore.firestore()
    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    private var listener: ListenerRegistration?
    
    func setupChat(forEvent eventId: String) {
        listener?.remove()
        messages = []
        
        listener = db.collection("communityChats")
                .document(eventId)
                .collection("messages")
                .order(by: "timestamp", descending: false)
                .addSnapshotListener { [weak self] snapshot, error in
                    self?.handleSnapshot(snapshot: snapshot, error: error)
                }
        
//            listener = db.collection("chats")
//                .document(eventId)
//                .collection("messages")
//                .order(by: "timestamp", descending: false)
//                .addSnapshotListener { [weak self] snapshot, error in
//                    self?.handleSnapshot(snapshot: snapshot, error: error)
//                }
    }
    
    func setupCommunityChat(chatId: String) {
        listener?.remove()
        messages = []
        
        listener = db.collection("communityChats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error)
            }
    }
    
    private func handleSnapshot(snapshot: QuerySnapshot?, error: Error?) {
        guard let snapshot = snapshot else {
            print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        snapshot.documentChanges.forEach { change in
            if change.type == .added {
                if let message = ChatMessage(document: change.document) {
                    DispatchQueue.main.async {
                        self.messages.append(message)
                    }
                }
            }
        }
    }

    func sendMessage(_ message: ChatMessage) {
        // Determine if it's an event chat or community chat
        let collectionName = message.eventId.starts(with: "event_") ? "chats" : "communityChats"
        
        let messageRef = db.collection(collectionName)
            .document(message.eventId)
            .collection("messages")
            .document(message.id)

        messageRef.setData(message.toDictionary()) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func setUserOnlineStatus(eventId: String, userId: String, isOnline: Bool) {
        db.collection("chats").document(eventId)
            .collection("presence").document(userId)
            .setData(["isOnline": isOnline, "lastSeen": Timestamp()])
    }

    deinit {
        listener?.remove()
    }
    
    
    
//    @Published var messages: [ChatMessage] = []
//    
//    private var db = Firestore.firestore()
//    private var listener: ListenerRegistration?
//    
//    func setupChat(forEvent eventId: String) {
//        listener?.remove()
//        
//        listener = db.collection("chats")
//            .document(eventId)
//            .collection("messages")
//            .order(by: "timestamp", descending: false)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let snapshot = snapshot else {
//                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                snapshot.documentChanges.forEach { change in
//                    if change.type == .added {
//                        if let message = ChatMessage(document: change.document) {
//                            DispatchQueue.main.async {
//                                self?.messages.append(message)
//                            }
//                        }
//                    }
//                }
//            }
//    }
//
//    func sendMessage(_ message: ChatMessage) {
//        let messageRef = db.collection("chats")
//            .document(message.eventId)
//            .collection("messages")
//            .document(message.id)
//
//        messageRef.setData(message.toDictionary()) { error in
//            if let error = error {
//                print("Error sending message: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    // In your ChatViewModel
//    func setUserOnlineStatus(eventId: String, userId: String, isOnline: Bool) {
//        db.collection("chats").document(eventId)
//            .collection("presence").document(userId)
//            .setData(["isOnline": isOnline, "lastSeen": Timestamp()])
//    }
//
//    deinit {
//        listener?.remove()
//    }
}

