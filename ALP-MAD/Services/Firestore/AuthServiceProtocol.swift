//
//  AuthServiceProtocol.swift
//  ALP-MAD
//
//  Created by Kevin Christian on 12/06/25.
//

import Foundation
import FirebaseAuth

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult
    func signOut() throws
    func updateProfile(displayName: String?, photoURL: URL?) async throws
}
