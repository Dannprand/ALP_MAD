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
    @Published var selectedCategory: SportCategory?
    @Published var isLoading = false
    @Published var showError = false
    @Published var error: Error?
    
    private let locationManager = LocationManager()
    private var db = Firestore.firestore()
    
    @MainActor
    func fetchEvents() async {
        isLoading = true
        do {
            let snapshot = try await db.collection("events")
                .whereField("date", isGreaterThan: Timestamp(date: Date()))
                .order(by: "date")
                .limit(to: 20)
                .getDocuments()
            
            let allEvents = try snapshot.documents.compactMap { try $0.data(as: Event.self) }
            
            // Filter by selected category if any
            let filteredEvents = selectedCategory == nil ?
                allEvents :
                allEvents.filter { $0.sport == selectedCategory }
            
            // Simple logic for demo - in real app would use more sophisticated algorithms
            featuredEvents = filteredEvents.filter { $0.isFeatured }.sorted { $0.date < $1.date }
            popularEvents = filteredEvents.sorted { $0.participants.count > $1.participants.count }
            
            // Sort by distance if location available
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
            guard !event.participants.contains(userId), !event.isFull else { return false }
            
            try await db.collection("events").document(event.id ?? "").updateData([
                "participants": FieldValue.arrayUnion([userId])
            ])
            
            try await db.collection("users").document(userId).updateData([
                "joinedEvents": FieldValue.arrayUnion([event.id ?? ""])
            ])
            
            return true
        } catch {
            self.error = error
            showError = true
            return false
        }
    }
}
