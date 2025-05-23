//
//  AuthViewModel.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var showError = false
    @Published var error: Error?
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
        }
    }
    
    func login(withEmail email: String, password: String) async {
        do {
            isLoading = true
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
        }
    }
    
    func register(withEmail email: String, password: String, fullname: String) async {
        do {
            isLoading = true
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
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
            
            await fetchUser()
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
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
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: User.self)
        } catch {
            self.error = error
            showError = true
        }
    }
}
