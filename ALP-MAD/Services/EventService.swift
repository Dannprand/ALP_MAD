import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import Combine

class EventService {
    private let db = Firestore.firestore()
    private var eventsCollection: CollectionReference {
        db.collection("events")
    }
    
    // MARK: - Event Fetching
    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        eventsCollection
            .whereField("expiryDate", isGreaterThan: Timestamp(date: Date()))
            .order(by: "expiryDate")
            .order(by: "date")
            .getDocuments { snapshot, error in
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
    
    func fetchEvents(forHostId hostId: String, completion: @escaping (Result<[Event], Error>) -> Void) {
        eventsCollection
            .whereField("hostId", isEqualTo: hostId)
            .whereField("expiryDate", isGreaterThan: Timestamp(date: Date()))
            .order(by: "expiryDate")
            .getDocuments { snapshot, error in
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
    
    // MARK: - Event Management
    func createEvent(_ event: Event, completion: @escaping (Result<String, Error>) -> Void) {
        let dict = event.toDictionary()
        var ref: DocumentReference?
        
        ref = eventsCollection.addDocument(data: dict) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(ref?.documentID ?? ""))
            }
        }
    }
    
    func updateEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let eventId = event.id else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing event ID"])))
            return
        }
        
        let dict = event.toDictionary()
        eventsCollection.document(eventId).setData(dict, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let eventId = event.id else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing event ID"])))
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
    
    // MARK: - Participant Management
    func joinEvent(eventId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let eventRef = eventsCollection.document(eventId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let eventDocument: DocumentSnapshot
            do {
                try eventDocument = transaction.getDocument(eventRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var participants = eventDocument.data()?["participants"] as? [String] else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get participants"])
                errorPointer?.pointee = error
                return nil
            }
            
            if !participants.contains(userId) {
                participants.append(userId)
                transaction.updateData(["participants": participants], forDocument: eventRef)
            }
            
            return nil
        }) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func leaveEvent(eventId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let eventRef = eventsCollection.document(eventId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let eventDocument: DocumentSnapshot
            do {
                try eventDocument = transaction.getDocument(eventRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var participants = eventDocument.data()?["participants"] as? [String] else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get participants"])
                errorPointer?.pointee = error
                return nil
            }
            
            if let index = participants.firstIndex(of: userId) {
                participants.remove(at: index)
                transaction.updateData(["participants": participants], forDocument: eventRef)
            }
            
            return nil
        }) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Expired Events Cleanup
    func cleanupExpiredEvents(completion: @escaping (Result<Int, Error>) -> Void) {
        let now = Timestamp(date: Date())
        
        eventsCollection
            .whereField("expiryDate", isLessThan: now)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success(0))
                    return
                }
                
                let batch = self.db.batch()
                documents.forEach { batch.deleteDocument($0.reference) }
                
                batch.commit { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(documents.count))
                    }
                }
            }
    }
}
