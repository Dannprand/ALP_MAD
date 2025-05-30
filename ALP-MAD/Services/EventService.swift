import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

class EventService {
    private let db = Firestore.firestore()
    private var eventsCollection: CollectionReference {
        db.collection("events")
    }

    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        eventsCollection.order(by: "date", descending: false).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }

            let events = documents.compactMap { Event(document: $0) }
            completion(.success(events))
        }
    }

    func createEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        let dict = event.toDictionary()
        eventsCollection.addDocument(data: dict) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func deleteEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let eventId = event.id else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing event ID."])))
            return
        }

        eventsCollection.document(eventId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
