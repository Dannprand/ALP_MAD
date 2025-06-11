//
//  UserServiceProtocol.swift
//  ALP-MAD
//
//  Created by Kevin Christian on 12/06/25.
//

import Foundation
import FirebaseFirestore

protocol UserServiceProtocol {
    func fetchUser(userId: String) async throws -> User
    func fetchUsers() async throws -> [User]
    func updateUser(userId: String, data: [String: Any]) async throws
    func toggleFollow(currentUserId: String, targetUserId: String, isFollowing: Bool) async throws
    func fetchFollowingStatus(currentUserId: String, targetUserId: String) async throws -> Bool
}
