//
//  EventViewModelTests.swift
//  ALP-MAD
//
//  Created by student on 11/06/25.
//

import XCTest
import FirebaseFirestore
@testable import ALP_MAD

final class EventViewModelTests: XCTestCase {

    func testJoinEvent_AddsUserToParticipants() async {
        // Given
        let mockEvent = Event(
            id: "event1",
            title: "Test Event",
            description: "Mock description",
            hostId: "host1",
            sport: .football,
            date: Timestamp(date: Date().addingTimeInterval(3600)),
            location: EventLocation(
                name: "Test Field",
                address: "123 Street",
                latitude: 0.0,
                longitude: 0.0
            ),
            maxParticipants: 10,
            participants: [],
            isFeatured: false,
            isTournament: false,
            prizePool: nil,
            rules: nil,
            requirements: nil,
            chatId: "chat1",
            createdAt: Timestamp(date: Date())
        )

        let viewModel = EventViewModel()

        // When
        let success = await viewModel.joinEvent(mockEvent, userId: "user123")

        // Then
        XCTAssertTrue(success, "Join event should return true")
        // Catatan: Ini tidak memverifikasi Firestore secara langsung (tanpa mocking)
    }

    func testFetchEvents_DefaultState() async {
        // Given
        let viewModel = EventViewModel()
        viewModel.selectedCategory = nil

        // When
        await viewModel.fetchEvents()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
}
