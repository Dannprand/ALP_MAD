import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Setup chat listener untuk event tertentu
    func setupChat(forEvent eventId: String) {
        listener?.remove() // remove previous listener (jika ada)

        listener = db.collection("chats")
            .document(eventId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else {
                    print("Error listening to messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self.messages = snapshot.documents.compactMap { ChatMessage(document: $0) }
            }
    }

    // Kirim pesan ke Firestore
    func sendMessage(_ message: ChatMessage) {
        db.collection("chats")
            .document(message.eventId)
            .collection("messages")
            .document(message.id)
            .setData(message.toDictionary()) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                }
            }
    }

    deinit {
        listener?.remove()
    }
}
