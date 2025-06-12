//
//  EventViewModel.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation

class EventViewModel: ObservableObject {
    
    @Published var featuredEvents: [Event] = []
        @Published var nearbyEvents: [Event] = []
        @Published var popularEvents: [Event] = []
        @Published var isLoading = false
        @Published var showError = false
        @Published var error: Error?
        @Published var selectedCategory: SportCategory? {
            didSet {
                Task {
                    await fetchEvents()
                }
            }
        }
        
        private let locationManager: LocationManagerProtocol
        private let db: FirestoreProtocol
        
        init(db: FirestoreProtocol, locationManager: LocationManagerProtocol) {
            self.db = db
            self.locationManager = locationManager
        }
        
        convenience init() {
            // Default initializer that uses the real Firestore and LocationManager
            // You'll need to create a wrapper for CLLocationManager that conforms to LocationManagerProtocol
            self.init(
                db: Firestore.firestore(),
                locationManager: RealLocationManager() // You'll need to implement this
            )
        }
    

    @MainActor
    func fetchEvents() async {
        isLoading = true
        
        do {
            let snapshot = try await Firestore.firestore()
                .collection("events")
                .whereField("date", isGreaterThan: Timestamp(date: Date()))
                .whereField("isEnded", isEqualTo: false)
                .order(by: "date")
                .limit(to: 20)
                .getDocuments()
//            let snapshot = try await db.collection("events")
//                .whereField("date", isGreaterThan: Timestamp(date: Date()))
//                .whereField("isEnded", isEqualTo: false) // Add this line
//                .order(by: "date")
//                .limit(to: 20)
//                .getDocuments()
            
            let allEvents = snapshot.documents.compactMap { Event(document: $0) }
            
            // Filter by selected category if any
            let filteredEvents = selectedCategory == nil ?
            allEvents :
            allEvents.filter { $0.sport == selectedCategory }
            featuredEvents = filteredEvents.filter { $0.isFeatured }.sorted { $0.date.dateValue() < $1.date.dateValue() }
            popularEvents = filteredEvents.sorted { $0.participants.count > $1.participants.count }
            
            if let userLocation = locationManager.lastLocation {
                nearbyEvents = filteredEvents.sorted {
                    let loc1 = CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)
                    let loc2 = CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude)
                    return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
                }
            } else {
                nearbyEvents = filteredEvents
            }
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
        }
    }
    
    func joinEvent(_ event: Event, userId: String) async -> Bool {
        do {
            guard let eventId = event.id else { return false }
            let eventRef = db.collection("events").document(eventId)
            
            try await db.runTransaction { transaction, errorPointer in
                do {
                    let eventDocument = try transaction.getDocument(eventRef)
                    guard var participants = eventDocument.data()?["participants"] as? [String] else {
                        return nil
                    }
                    
                    if !participants.contains(userId) {
                        participants.append(userId)
                        transaction.updateData(["participants": participants], forDocument: eventRef)
                    }
                    return nil
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }
            
            // Also add to user's joined events
            try await db.collection("users").document(userId).updateData([
                "joinedEvents": FieldValue.arrayUnion([eventId])
            ])
            return true
            
        } catch {
            print("Error joining event: \(error)")
            return false
        }
    }
//    func joinEvent(_ event: Event, userId: String) async -> Bool {
//        do {
//            
//            let eventRef = db.collection("events").document(event.id ?? "")
//            
//            try await db.runTransaction { transaction, errorPointer in
//                
//                let eventDocument: DocumentSnapshot
//                do {
//                    guard let eventDocument = try transaction.getDocument(eventRef) as? DocumentSnapshot else {
//                        return nil
//                    }
////                    try eventDocument = transaction.getDocument(eventRef)
//                } catch {
//                    errorPointer?.pointee = error as NSError
//                    return nil
//                }
//                guard var participants = eventDocument.data()?["participants"] as? [String] else {
//                    return nil
//                }
//                if !participants.contains(userId) {
//                    participants.append(userId)
//                    transaction.updateData(["participants": participants], forDocument: eventRef)
//                }
//                return nil
//            }
//            
//            // Also add to user's joined events
//            
//            try await db.collection("users").document(userId).updateData([
//                "joinedEvents": FieldValue.arrayUnion([event.id ?? ""])
//            ])
//            return true
//            
//        } catch {
//            print("Error joining event: \(error)")
//            return false
//        }
//    }
    
    func requestUserLocation() {
        locationManager.requestLocation()
    }
    
    var lastKnownLocation: CLLocation? {
        locationManager.lastLocation
    }
    
    func fetchUserEvents(userId: String, completion: @escaping ([Event]) -> Void) {
        Firestore.firestore()
            .collection("events")
            .whereField("participants", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching events for user: \(error)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let events = documents.compactMap { Event(document: $0) }
                completion(events)
            }

//        db.collection("events")
//            .whereField("participants", arrayContains: userId)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching events for user: \(error)")
//                    completion([])
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    completion([])
//                    return
//                }
//                
//                let events = documents.compactMap { Event(document: $0) }
//                completion(events)
//            }
    }
    
    // In EventViewModel.swift
    func endEvent(event: Event) async -> Result<Void, Error> {
        guard let eventId = event.id else {
            return .failure(NSError(domain: "InvalidEventID", code: 0))
        }
        
        let eventRef = db.collection("events").document(eventId)
        
        do {
            try await eventRef.updateData(["isEnded": true])
            // Remove from local arrays to update UI immediately
            DispatchQueue.main.async {
                self.featuredEvents.removeAll { $0.id == eventId }
                self.nearbyEvents.removeAll { $0.id == eventId }
                self.popularEvents.removeAll { $0.id == eventId }
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
//    func endEvent(event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let eventId = event.id else {
//            completion(.failure(NSError(domain: "InvalidEventID", code: 0)))
//            return
//        }
//        
////        let eventRef = FirebaseFirestore.Firestore.firestore().collection("events").document(eventId)
//        let eventRef = db.collection("events").document(eventId)
////        let eventRef = Firestore.firestore().collection("events").document(eventId)
//        
//        eventRef.updateData(["isEnded": true]) { error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                // Remove from local arrays to update UI immediately
//                DispatchQueue.main.async {
//                    self.featuredEvents.removeAll { $0.id == eventId }
//                    self.nearbyEvents.removeAll { $0.id == eventId }
//                    self.popularEvents.removeAll { $0.id == eventId }
//                }
//                completion(.success(()))
//            }
//        }
//    }
    
}
