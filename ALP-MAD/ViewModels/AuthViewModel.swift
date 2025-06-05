//
//  AuthViewModel.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var showError = false
    @Published var error: Error?
    
    private var db = Firestore.firestore()
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }
    
//    func login(withEmail email: String, password: String) async {
//        do {
//            isLoading = true
//            let result = try await Auth.auth().signIn(withEmail: email, password: password)
//            self.userSession = result.user
//            await fetchUser()
//            isLoading = false
//        } catch {
//            self.error = error
//            showError = true
//            isLoading = false
//        }
//    }
    
    func login(withEmail email: String, password: String) async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            await MainActor.run {
                self.userSession = result.user
            }

            await fetchUser()

            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.showError = true
                self.isLoading = false
            }
        }
    }

    
    func register(withEmail email: String, password: String, fullname: String) async {
        await MainActor.run {
            self.isLoading = true
            print("isLoading set to true")
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("User created: \(result.user.uid)")
            
            await MainActor.run {
                self.userSession = result.user
            }
            
            let user = User(
                id: result.user.uid,
                fullname: fullname,
                email: email,
                preferences: [],
                tokens: 0,
                joinedEvents: []
            )
            
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            print("User data saved to Firestore")
            
            await fetchUser()
            print("fetchUser completed")
            
            await MainActor.run {
                self.isLoading = false
                print("isLoading set to false")
            }
            
            
            
//            await MainActor.run {
//                self.isLoading = false
//                print("isLoading set to false")
//            }
            
        } catch {
            await MainActor.run {
                self.error = error
                self.showError = true
                self.isLoading = false
                print("Error occurred: \(error.localizedDescription), isLoading set to false")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            self.error = error
            showError = true
        }
    }
    
//    func fetchUser() async {
//        guard let uid = userSession?.uid else { return }
//        
//        do {
//            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
//            let user = try snapshot.data(as: User.self)
//            
//            await MainActor.run {
//                self.currentUser = user
//            }
//        } catch {
//            await MainActor.run {
//                self.error = error
//                self.showError = true
//            }
//        }
//    }
    
    func fetchUser() async {
        guard let uid = userSession?.uid else { return }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            let user = try snapshot.data(as: User.self)
            
            await MainActor.run {
                self.currentUser = user
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.showError = true
            }
        }
    }

    func updateProfile(fullname: String, image: UIImage?) async throws {
            guard let user = currentUser else { return }
            let userRef = Firestore.firestore().collection("users").document(user.id)
            
            var updatedData: [String: Any] = ["fullname": fullname]
            
            // Convert image to Base64 and store as string
            if let image = image, let imageData = image.jpegData(compressionQuality: 0.4) {
                let base64String = imageData.base64EncodedString()
                updatedData["profileImageUrl"] = base64String
            }
            
            // Update Firestore
            try await userRef.updateData(updatedData)
            
            // Update local user object
            var newUser = user
            newUser = User(
                id: user.id,
                fullname: fullname,
                email: user.email,
                preferences: user.preferences,
                tokens: user.tokens,
                joinedEvents: user.joinedEvents,
                hostedEvents: user.hostedEvents,
                profileImageUrl: updatedData["profileImageUrl"] as? String ?? user.profileImageUrl,
                notificationEnabled: user.notificationEnabled
            )
            
            DispatchQueue.main.async {
                self.currentUser = newUser
            }
        }
    
//    // Fungsi untuk follow user
//        func follow(userToFollowId: String) async throws {
//            guard let currentUserId = currentUser?.id, currentUserId != userToFollowId else { return }
//
//            let currentUserRef = db.collection("users").document(currentUserId)
//            let userToFollowRef = db.collection("users").document(userToFollowId)
//
//            try await db.runTransaction { transaction, errorPointer in
//                let currentUserDoc: DocumentSnapshot
//                let userToFollowDoc: DocumentSnapshot
//
//                do {
//                    currentUserDoc = try transaction.getDocument(currentUserRef)
//                    userToFollowDoc = try transaction.getDocument(userToFollowRef)
//                } catch {
//                    errorPointer?.pointee = error as NSError
//                    return nil
//                }
//
//                var currentFollowing = currentUserDoc.data()?["following"] as? [String] ?? []
//                var userToFollowFollowers = userToFollowDoc.data()?["followers"] as? [String] ?? []
//
//                if !currentFollowing.contains(userToFollowId) {
//                    currentFollowing.append(userToFollowId)
//                }
//                if !userToFollowFollowers.contains(currentUserId) {
//                    userToFollowFollowers.append(currentUserId)
//                }
//
//                transaction.updateData(["following": currentFollowing], forDocument: currentUserRef)
//                transaction.updateData(["followers": userToFollowFollowers], forDocument: userToFollowRef)
//
//                return nil
//            }
//
//            // Update local currentUser state supaya UI bisa refresh
//            await fetchUser()
//        }
//
//        // Fungsi untuk unfollow user
//        func unfollow(userToUnfollowId: String) async throws {
//            guard let currentUserId = currentUser?.id, currentUserId != userToUnfollowId else { return }
//
//            let currentUserRef = db.collection("users").document(currentUserId)
//            let userToUnfollowRef = db.collection("users").document(userToUnfollowId)
//
//            try await db.runTransaction { transaction, errorPointer in
//                let currentUserDoc: DocumentSnapshot
//                let userToUnfollowDoc: DocumentSnapshot
//
//                do {
//                    currentUserDoc = try transaction.getDocument(currentUserRef)
//                    userToUnfollowDoc = try transaction.getDocument(userToUnfollowRef)
//                } catch {
//                    errorPointer?.pointee = error as NSError
//                    return nil
//                }
//
//                var currentFollowing = currentUserDoc.data()?["following"] as? [String] ?? []
//                var userToUnfollowFollowers = userToUnfollowDoc.data()?["followers"] as? [String] ?? []
//
//                currentFollowing.removeAll(where: { $0 == userToUnfollowId })
//                userToUnfollowFollowers.removeAll(where: { $0 == currentUserId })
//
//                transaction.updateData(["following": currentFollowing], forDocument: currentUserRef)
//                transaction.updateData(["followers": userToUnfollowFollowers], forDocument: userToUnfollowRef)
//
//                return nil
//            }
//
//            // Update local currentUser state supaya UI bisa refresh
//            await fetchUser()
//        }
//
//        // Fungsi fetchUser untuk update data currentUser, pastikan ini ada
//        @MainActor
//        func fetchUser() async {
//            guard let userId = currentUser?.id else { return }
//            do {
//                let doc = try await db.collection("users").document(userId).getDocument()
//                if let user = User(document: doc) {
//                    self.currentUser = user
//                }
//            } catch {
//                print("Failed to fetch user: \(error)")
//            }
//        }
}
