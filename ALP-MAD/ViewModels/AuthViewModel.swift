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
    
    func fetchUser() async {
        guard let uid = userSession?.uid else { return }
        
        do {
//            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
//            let user = try snapshot.data(as: User.self)
            
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()

            guard snapshot.exists else {
                print("❌ No user document found for uid: \(uid)")
                return
            }

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
            joinedEvents: user.joinedEvents,
            hostedEvents: user.hostedEvents,
            profileImageUrl: updatedData["profileImageUrl"] as? String ?? user.profileImageUrl,
            notificationEnabled: user.notificationEnabled
        )
        
        DispatchQueue.main.async {
            self.currentUser = newUser
        }
    }
    
}
