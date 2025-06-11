//
//  ExploreViewModelTests.swift
//  ALP-MAD
//
//  Created by student on 11/06/25.
//

import Foundation
import XCTest
@testable import ALP_MAD

final class ExploreViewModelTests: XCTestCase {

    func testFilterUsers_WithSearchText() {
        let vm = ExploreViewModel()
        let user1 = User(id: "1", fullname: "Alice Johnson", email: "a@a.com")
        let user2 = User(id: "2", fullname: "Bob Smith", email: "b@b.com")
        vm.allUsers = [user1, user2]

        vm.filterUsers(searchText: "bob")

        XCTAssertEqual(vm.filteredUsers.count, 1)
        XCTAssertEqual(vm.filteredUsers.first?.fullname, "Bob Smith")
    }

    func testCheckFollowingStatus_True() {
        let vm = ExploreViewModel()
        let currentUser = User(id: "u1", fullname: "Current", email: "test@test.com", following: ["u2"])
        let targetUser = User(id: "u2", fullname: "Target", email: "target@test.com")

        vm.checkFollowingStatus(currentUser: currentUser, targetUser: targetUser)

        XCTAssertTrue(vm.isFollowing)
    }

    func testCheckFollowingStatus_False() {
        let vm = ExploreViewModel()
        let currentUser = User(id: "u1", fullname: "Current", email: "test@test.com", following: [])
        let targetUser = User(id: "u2", fullname: "Target", email: "target@test.com")

        vm.checkFollowingStatus(currentUser: currentUser, targetUser: targetUser)

        XCTAssertFalse(vm.isFollowing)
    }
}
