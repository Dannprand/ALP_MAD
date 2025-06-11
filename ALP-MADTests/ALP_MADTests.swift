import XCTest
import FirebaseCore
import FirebaseFirestore
@testable import ALP_MAD
import CoreLocation

final class ALP_MADTests: XCTestCase {
    
    var eventViewModel: EventViewModel!
    var exploreViewModel: ExploreViewModel!
    var profileViewModel: ProfileViewModel!
    
    override func setUpWithError() throws {
        eventViewModel = EventViewModel()
        exploreViewModel = ExploreViewModel()
        profileViewModel = ProfileViewModel()
    }

    override func tearDownWithError() throws {
        eventViewModel = nil
        exploreViewModel = nil
        profileViewModel = nil
    }

    // MARK: - EventViewModel Test
    func testJoinEvent() async throws {
        let dummyLocation = EventLocation(
            name: "Dummy Location",
            address: "123 Dummy Street",
            latitude: 0.0,
            longitude: 0.0
        )


        let dummyEvent = Event(
            id: "testEvent123",
            title: "Test Event",
            description: "This is a test event",
            hostId: "host123",
            sport: .football, // Pastikan enum SportCategory memiliki case 'soccer'
            date: Timestamp(date: Date()),
            location: dummyLocation,
            maxParticipants: 10,
            participants: [],
            isFeatured: false,
            isTournament: false,
            prizePool: nil,
            rules: nil,
            requirements: nil,
            chatId: "testChat123",
            createdAt: Timestamp(date: Date())
        )


        let dummyUserId = "user123"
        
        let success = await eventViewModel.joinEvent(dummyEvent, userId: dummyUserId)
        
        // Karena Firestore asli tidak jalan saat testing, hasilnya bisa gagal
        // Tapi ini contoh assert-nya
        XCTAssertFalse(success, "Expected joinEvent to fail in unit test environment without mock Firestore")
    }

    // MARK: - ExploreViewModel Test
    func testFilterUsers() {
        let user1 = User(id: "1", fullname: "Alice Wonder", email: "")
        let user2 = User(id: "2", fullname: "Bob Builder", email: "")
        exploreViewModel.allUsers = [user1, user2]

        exploreViewModel.filterUsers(searchText: "alice")
        XCTAssertEqual(exploreViewModel.filteredUsers.count, 1)
        XCTAssertEqual(exploreViewModel.filteredUsers.first?.fullname, "Alice Wonder")
    }

    func testCheckFollowingStatus() {
        let currentUser = User(id: "1", fullname: "Alice", email: "", following: ["2"])
        let targetUser = User(id: "2", fullname: "Bob", email: "")
        
        exploreViewModel.checkFollowingStatus(currentUser: currentUser, targetUser: targetUser)
        XCTAssertTrue(exploreViewModel.isFollowing)
    }

    // MARK: - ProfileViewModel Test
    func testInitialEventState() {
        XCTAssertNotNil(profileViewModel.hostedEvents)
        XCTAssertNotNil(profileViewModel.joinedEvents)
    }
}




