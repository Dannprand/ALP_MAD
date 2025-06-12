//
//  EventViewModelTests.swift
//  ALP-MADTests
//
//  Created by student on 12/06/25.
//

// File: ALP-MADTests/ViewModels/EventViewModelTests.swift

import XCTest
import CoreLocation
@testable import ALP_MAD

class EventViewModelTests: XCTestCase {
    var viewModel: EventViewModel!
    var mockFirestore: MockFirestore!
    var mockLocationManager: MockLocationManager!
    
    override func setUp() {
        super.setUp()
        mockFirestore = MockFirestore()
        mockLocationManager = MockLocationManager()
        viewModel = EventViewModel(db: mockFirestore, locationManager: mockLocationManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockFirestore = nil
        mockLocationManager = nil
        super.tearDown()
    }
    
    // MARK: - Test Helpers
    
    private func createMockEvent(id: String,
                                sport: SportCategory = .basketball,
                                date: Date = Date().addingTimeInterval(86400), // Tomorrow
                                participants: [String] = [],
                                isFeatured: Bool = false,
                                location: EventLocation = EventLocation(name: "Test", address: "Test", latitude: 0, longitude: 0)) -> Event {
        return Event(
            id: id,
            title: "Test Event",
            description: "Test Description",
            hostId: "host1",
            sport: sport,
            date: Timestamp(date: date),
            location: location,
            maxParticipants: 10,
            participants: participants,
            isFeatured: isFeatured,
            isTournament: false,
            prizePool: nil,
            rules: nil,
            requirements: nil,
            chatId: "chat1",
            createdAt: Timestamp(date: Date()),
            isEnded: false
        )
    }
    
    private func addMockEventsToFirestore(_ events: [Event]) {
        let eventsCollection = mockFirestore.collection("events") as! MockCollectionReference
        
        for event in events {
            let document = eventsCollection.document(event.id ?? UUID().uuidString) as! MockDocumentReference
            document.data = event.toDictionary()
        }
    }
    
    // MARK: - fetchEvents Tests
    
    func testFetchEventsSuccess() async {
        // Given
        let mockEvents = [
            createMockEvent(id: "1", sport: .basketball, isFeatured: true),
            createMockEvent(id: "2", sport: .football),
            createMockEvent(id: "3", sport: .basketball, participants: ["user1", "user2", "user3"])
        ]
        
        addMockEventsToFirestore(mockEvents)
        
        // When
        await viewModel.fetchEvents()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.error)
        
        // Featured events should contain only the featured event
        XCTAssertEqual(viewModel.featuredEvents.count, 1)
        XCTAssertEqual(viewModel.featuredEvents.first?.id, "1")
        
        // Popular events should be ordered by participant count
        XCTAssertEqual(viewModel.popularEvents.count, 3)
        XCTAssertEqual(viewModel.popularEvents.first?.id, "3")
        
        // Nearby events - since we didn't set location, it should just return all events unfiltered
        XCTAssertEqual(viewModel.nearbyEvents.count, 3)
    }
    
    func testFetchEventsWithLocation() async {
        // Given
        let userLocation = CLLocation(latitude: 1.0, longitude: 1.0)
        mockLocationManager.lastLocation = userLocation
        
        let closeLocation = EventLocation(name: "Close", address: "Close", latitude: 1.01, longitude: 1.01)
        let farLocation = EventLocation(name: "Far", address: "Far", latitude: 10.0, longitude: 10.0)
        
        let mockEvents = [
            createMockEvent(id: "1", location: farLocation),
            createMockEvent(id: "2", location: closeLocation),
            createMockEvent(id: "3", location: closeLocation)
        ]
        
        addMockEventsToFirestore(mockEvents)
        
        // When
        await viewModel.fetchEvents()
        
        // Then
        XCTAssertEqual(viewModel.nearbyEvents.count, 3)
        
        // The first event should be the closest one
        let distances = viewModel.nearbyEvents.map { event in
            userLocation.distance(from: CLLocation(latitude: event.location.latitude,
                                                  longitude: event.location.longitude))
        }
        
        // Check if distances are in ascending order
        for i in 0..<distances.count-1 {
            XCTAssertLessThanOrEqual(distances[i], distances[i+1])
        }
    }
    
    func testFetchEventsWithCategoryFilter() async {
        // Given
        let mockEvents = [
            createMockEvent(id: "1", sport: .basketball),
            createMockEvent(id: "2", sport: .football),
            createMockEvent(id: "3", sport: .basketball)
        ]
        
        addMockEventsToFirestore(mockEvents)
        viewModel.selectedCategory = .basketball
        
        // When
        await viewModel.fetchEvents()
        
        // Then
        XCTAssertEqual(viewModel.featuredEvents.count, 0) // None are featured
        XCTAssertEqual(viewModel.popularEvents.count, 2) // Only basketball events
        XCTAssertEqual(viewModel.nearbyEvents.count, 2)  // Only basketball events
        
        for event in viewModel.popularEvents {
            XCTAssertEqual(event.sport, .basketball)
        }
    }
    
    func testFetchEventsFailure() async {
        // Given
        mockFirestore.shouldThrowError = true
        
        // When
        await viewModel.fetchEvents()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.featuredEvents.isEmpty)
        XCTAssertTrue(viewModel.popularEvents.isEmpty)
        XCTAssertTrue(viewModel.nearbyEvents.isEmpty)
    }
    
    // MARK: - joinEvent Tests
    
    func testJoinEventSuccess() async {
        // Given
        let userId = "user1"
        let event = createMockEvent(id: "event1", participants: [])
        addMockEventsToFirestore([event])
        
        // Also add a mock user document
        let usersCollection = mockFirestore.collection("users") as! MockCollectionReference
        let userDoc = usersCollection.document(userId) as! MockDocumentReference
        userDoc.data = ["joinedEvents": []]
        
        // When
        let result = await viewModel.joinEvent(event, userId: userId)
        
        // Then
        XCTAssertTrue(result)
        
        // Verify event was updated
        let updatedEventDoc = mockFirestore.collection("events").document("event1") as! MockDocumentReference
        let updatedParticipants = updatedEventDoc.data?["participants"] as? [String]
        XCTAssertEqual(updatedParticipants?.count, 1)
        XCTAssertEqual(updatedParticipants?.first, userId)
        
        // Verify user was updated
        let updatedUserEvents = userDoc.data?["joinedEvents"] as? [String]
        XCTAssertEqual(updatedUserEvents?.count, 1)
        XCTAssertEqual(updatedUserEvents?.first, "event1")
    }
    
    func testJoinEventAlreadyJoined() async {
        // Given
        let userId = "user1"
        let event = createMockEvent(id: "event1", participants: [userId])
        addMockEventsToFirestore([event])
        
        // When
        let result = await viewModel.joinEvent(event, userId: userId)
        
        // Then
        XCTAssertTrue(result) // Still returns true as it's not an error case
        
        // Verify participants weren't modified
        let eventDoc = mockFirestore.collection("events").document("event1") as! MockDocumentReference
        let participants = eventDoc.data?["participants"] as? [String]
        XCTAssertEqual(participants?.count, 1)
    }
    
    func testJoinEventFailure() async {
        // Given
        let userId = "user1"
        let event = createMockEvent(id: "event1", participants: [])
        
        // Make the firestore throw an error
        mockFirestore.shouldThrowError = true
        
        // When
        let result = await viewModel.joinEvent(event, userId: userId)
        
        // Then
        XCTAssertFalse(result)
    }
    
    // MARK: - endEvent Tests
    
    func testEndEventSuccess() async {
        // Given
        let event = createMockEvent(id: "event1")
        let eventDoc = (mockFirestore.collection("events").document("event1") as! MockDocumentReference)
        eventDoc.data = event.toDictionary()
        
        // When
        await viewModel.endEvent(event)
        
        // Then
        XCTAssertEqual(eventDoc.data?["isEnded"] as? Bool, true)
    }
    
    func testEndEventFailure() async {
        // Given
        let event = createMockEvent(id: "event1")
        let eventDoc = (mockFirestore.collection("events").document("event1") as! MockDocumentReference)
        eventDoc.data = event.toDictionary()
        eventDoc.shouldThrowError = true
        
        // When
        await viewModel.endEvent(event)
        
        // Then
        // The error should be handled gracefully
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - fetchUserEvent Tests
    
    func testFetchUserEventsSuccess() async {
        // Given
        let userId = "user1"
        
        // Create events that the user has joined
        let userEvents = [
            createMockEvent(id: "1", participants: [userId]),
            createMockEvent(id: "2", participants: [userId]),
            createMockEvent(id: "3", participants: []) // Not joined by user
        ]
        
        addMockEventsToFirestore(userEvents)
        
        // When
        let events = await viewModel.fetchUserEvents(userId: userId)
        
        // Then
        XCTAssertEqual(events.count, 2)
        XCTAssertTrue(events.contains(where: { $0.id == "1" }))
        XCTAssertTrue(events.contains(where: { $0.id == "2" }))
        XCTAssertFalse(events.contains(where: { $0.id == "3" }))
    }
    
    func testFetchUserEventsFailure() async {
        // Given
        let userId = "user1"
        mockFirestore.shouldThrowError = true
        
        // When
        let
