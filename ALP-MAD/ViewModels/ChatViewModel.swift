import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func setupChat(forEvent eventId: String) {
        listener?.remove()

        listener = db.collection("chats")
            .document(eventId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }

                self.messages = snapshot?.documents.compactMap { ChatMessage(document: $0) } ?? []
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

    deinit {
        listener?.remove()
    }
}

