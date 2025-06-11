//
//  FirestoreServiceProtocol.swift
//  ALP-MAD
//
//  Created by Kevin Christian on 12/06/25.
//

import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import Combine

protocol FirestoreServiceProtocol {
    // Document operations
    func getDocument<T: Decodable>(from collection: String, documentId: String) async throws -> T
    func setDocument<T: Encodable>(in collection: String, documentId: String, data: T) async throws
    func updateDocument(in collection: String, documentId: String, data: [String: Any]) async throws
    func deleteDocument(from collection: String, documentId: String) async throws
    
    // Collection operations
    func getCollection<T: Decodable>(from collection: String) async throws -> [T]
    func getCollection<T: Decodable>(from collection: String, whereField field: String, isEqualTo value: Any) async throws -> [T]
    func getCollection<T: Decodable>(from collection: String, whereField field: String, arrayContains value: Any) async throws -> [T]
    func getCollection<T: Decodable>(from collection: String, whereField field: String, isGreaterThan value: Any, limit: Int?) async throws -> [T]
    func getCollection<T: Decodable>(from collection: String, whereField field: String, isNotEqualTo value: Any) async throws -> [T]
    
    // Listener operations
    func addSnapshotListener<T: Decodable>(
        for collection: String,
        documentId: String?,
        subCollection: String?,
        orderBy field: String?,
        descending: Bool,
        completion: @escaping (Result<[T], Error>) -> Void
    ) -> ListenerRegistration
    
    // Transaction operations
    func runTransaction<T>(_ updateBlock: @escaping (Transaction, NSErrorPointer) -> T?) async throws -> T
    
    // Field value operations
    func fieldArrayUnion(_ elements: [Any]) -> FieldValue
    func fieldArrayRemove(_ elements: [Any]) -> FieldValue
}
