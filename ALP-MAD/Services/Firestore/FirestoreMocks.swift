//
//  FirestoreMocks.swift
//  ALP-MAD
//
//  Created by Kevin Christian on 12/06/25.
//

import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import Combine
import CoreLocation
@testable import ALP_MAD

// MARK: - Mock Classes and Protocols

protocol AuthProtocol {
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResultProtocol
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResultProtocol
    func signOut() throws
    var currentUser: UserProtocol? { get }
}

protocol AuthDataResultProtocol {
    var user: UserProtocol { get }
}

protocol UserProtocol {
    var uid: String { get }
}

protocol FirestoreProtocol {
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol
}

protocol CollectionReferenceProtocol {
    func document(_ documentPath: String) -> DocumentReferenceProtocol
    func whereField(_ field: String, isEqualTo: Any) -> QueryProtocol
    func whereField(_ field: String, isGreaterThan: Any) -> QueryProtocol
    func whereField(_ field: String, arrayContains: Any) -> QueryProtocol
    func order(by field: String, descending: Bool) -> QueryProtocol
    func limit(to limit: Int) -> QueryProtocol
    func getDocuments() async throws -> QuerySnapshotProtocol
    func addSnapshotListener(_ listener: @escaping (QuerySnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol
}

protocol DocumentReferenceProtocol {
    func setData(_ data: [String: Any]) async throws
    func updateData(_ data: [String: Any]) async throws
    func getDocument() async throws -> DocumentSnapshotProtocol
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol
}

protocol QueryProtocol {
    func getDocuments() async throws -> QuerySnapshotProtocol
    func addSnapshotListener(_ listener: @escaping (QuerySnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol
}

protocol DocumentSnapshotProtocol {
    var data: [String: Any]? { get }
    func data(as: Any.Type) throws -> Any
    var exists: Bool { get }
}

protocol QuerySnapshotProtocol {
    var documentChanges: [DocumentChangeProtocol] { get }
    var documents: [QueryDocumentSnapshotProtocol] { get }
}

protocol DocumentChangeProtocol {
    var type: DocumentChangeType { get }
    var document: QueryDocumentSnapshotProtocol { get }
}

protocol QueryDocumentSnapshotProtocol {
    var data: [String: Any] { get }
    func data(as: Any.Type) throws -> Any
}

protocol ListenerRegistrationProtocol {
    func remove()
}

enum DocumentChangeType {
    case added, modified, removed
}

// MARK: - Mock Implementations

class MockAuth: AuthProtocol {
    var currentUser: UserProtocol?
    var shouldThrowError = false
    var signedInUser: MockUser?
    
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResultProtocol {
        if shouldThrowError {
            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
        }
        let user = MockUser(uid: "mockUser123")
        signedInUser = user
        currentUser = user
        return MockAuthDataResult(user: user)
    }
    
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResultProtocol {
        if shouldThrowError {
            throw NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Registration failed"])
        }
        let user = MockUser(uid: "newUser123")
        signedInUser = user
        currentUser = user
        return MockAuthDataResult(user: user)
    }
    
    func signOut() throws {
        if shouldThrowError {
            throw NSError(domain: "AuthError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Sign out failed"])
        }
        currentUser = nil
        signedInUser = nil
    }
}

class MockAuthDataResult: AuthDataResultProtocol {
    var user: UserProtocol
    
    init(user: UserProtocol) {
        self.user = user
    }
}

class MockUser: UserProtocol {
    var uid: String
    
    init(uid: String) {
        self.uid = uid
    }
}

class MockFirestore: FirestoreProtocol {
    var mockData: [String: [String: [String: Any]]] = [:]
    var shouldThrowError = false
    
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
        return MockCollectionReference(firestore: self, path: collectionPath)
    }
}

class MockCollectionReference: CollectionReferenceProtocol {
    let firestore: MockFirestore
    let path: String
    
    init(firestore: MockFirestore, path: String) {
        self.firestore = firestore
        self.path = path
    }
    
    func document(_ documentPath: String) -> DocumentReferenceProtocol {
        return MockDocumentReference(firestore: firestore, collectionPath: path, documentPath: documentPath)
    }
    
    func whereField(_ field: String, isEqualTo: Any) -> QueryProtocol {
        return MockQuery(firestore: firestore, collectionPath: path, filters: [(field, "==", isEqualTo)])
    }
    
    func whereField(_ field: String, isGreaterThan: Any) -> QueryProtocol {
        return MockQuery(firestore: firestore, collectionPath: path, filters: [(field, ">", isGreaterThan)])
    }
    
    func whereField(_ field: String, arrayContains: Any) -> QueryProtocol {
        return MockQuery(firestore: firestore, collectionPath: path, filters: [(field, "array-contains", arrayContains)])
    }
    
    func order(by field: String, descending: Bool) -> QueryProtocol {
        return MockQuery(firestore: firestore, collectionPath: path, orderBy: (field, descending))
    }
    
    func limit(to limit: Int) -> QueryProtocol {
        return MockQuery(firestore: firestore, collectionPath: path, limit: limit)
    }
    
    func getDocuments() async throws -> QuerySnapshotProtocol {
        if firestore.shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to get documents"])
        }
        
        let collectionData = firestore.mockData[path] ?? [:]
        let documents = collectionData.map { key, value in
            MockQueryDocumentSnapshot(documentID: key, data: value)
        }
        
        return MockQuerySnapshot(documents: documents)
    }
    
    func addSnapshotListener(_ listener: @escaping (QuerySnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol {
        let documents = (firestore.mockData[path] ?? [:]).map { key, value in
            MockQueryDocumentSnapshot(documentID: key, data: value)
        }
        let snapshot = MockQuerySnapshot(documents: documents)
        listener(snapshot, nil)
        return MockListenerRegistration()
    }
}

class MockDocumentReference: DocumentReferenceProtocol {
    let firestore: MockFirestore
    let collectionPath: String
    let documentPath: String
    
    init(firestore: MockFirestore, collectionPath: String, documentPath: String) {
        self.firestore = firestore
        self.collectionPath = collectionPath
        self.documentPath = documentPath
    }
    
    func setData(_ data: [String: Any]) async throws {
        if firestore.shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to set data"])
        }
        
        if firestore.mockData[collectionPath] == nil {
            firestore.mockData[collectionPath] = [:]
        }
        firestore.mockData[collectionPath]?[documentPath] = data
    }
    
    func updateData(_ data: [String: Any]) async throws {
        if firestore.shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to update data"])
        }
        
        guard var existingData = firestore.mockData[collectionPath]?[documentPath] else {
            throw NSError(domain: "FirestoreError", code: 7, userInfo: [NSLocalizedDescriptionKey: "Document not found"])
        }
        
        for (key, value) in data {
            existingData[key] = value
        }
        firestore.mockData[collectionPath]?[documentPath] = existingData
    }
    
    func getDocument() async throws -> DocumentSnapshotProtocol {
        if firestore.shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 8, userInfo: [NSLocalizedDescriptionKey: "Failed to get document"])
        }
        
        guard let data = firestore.mockData[collectionPath]?[documentPath] else {
            return MockDocumentSnapshot(exists: false, data: nil)
        }
        
        return MockDocumentSnapshot(exists: true, data: data)
    }
    
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
        return MockCollectionReference(firestore: firestore, path: "\(self.collectionPath)/\(documentPath)/\(collectionPath)")
    }
}

class MockQuery: QueryProtocol {
    let firestore: MockFirestore
    let collectionPath: String
    var filters: [(String, String, Any)] = []
    var orderBy: (String, Bool)?
    var limit: Int?
    
    init(firestore: MockFirestore, collectionPath: String, filters: [(String, String, Any)] = [], orderBy: (String, Bool)? = nil, limit: Int? = nil) {
        self.firestore = firestore
        self.collectionPath = collectionPath
        self.filters = filters
        self.orderBy = orderBy
        self.limit = limit
    }
    
    func getDocuments() async throws -> QuerySnapshotProtocol {
        if firestore.shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 9, userInfo: [NSLocalizedDescriptionKey: "Failed to get documents"])
        }
        
        let collectionData = firestore.mockData[collectionPath] ?? [:]
        var documents = collectionData.map { key, value in
            MockQueryDocumentSnapshot(documentID: key, data: value)
        }
        
        // Apply filters
        for filter in filters {
            let (field, operatorString, value) = filter
            documents = documents.filter { snapshot in
                guard let fieldValue = snapshot.data[field] else { return false }
                
                switch operatorString {
                case "==":
                    if let fieldValue = fieldValue as? String, let value = value as? String {
                        return fieldValue == value
                    } else if let fieldValue = fieldValue as? Int, let value = value as? Int {
                        return fieldValue == value
                    } else if let fieldValue = fieldValue as? Bool, let value = value as? Bool {
                        return fieldValue == value
                    }
                    return false
                case ">":
                    if let fieldValue = fieldValue as? Date, let value = value as? Date {
                        return fieldValue > value
                    } else if let fieldValue = fieldValue as? Int, let value = value as? Int {
                        return fieldValue > value
                    }
                    return false
                case "array-contains":
                    if let array = fieldValue as? [String], let value = value as? String {
                        return array.contains(value)
                    }
                    return false
                default:
                    return false
                }
            }
        }
        
        // Apply sorting
        if let orderBy = orderBy {
            let (field, descending) = orderBy
            documents.sort { a, b in
                guard let aValue = a.data[field], let bValue = b.data[field] else { return false }
                
                if let aValue = aValue as? Date, let bValue = bValue as? Date {
                    return descending ? aValue > bValue : aValue < bValue
                } else if let aValue = aValue as? String, let bValue = bValue as? String {
                    return descending ? aValue > bValue : aValue < bValue
                } else if let aValue = aValue as? Int, let bValue = bValue as? Int {
                    return descending ? aValue > bValue : aValue < bValue
                }
                return false
            }
        }
        
        // Apply limit
        if let limit = limit, documents.count > limit {
            documents = Array(documents[0..<limit])
        }
        
        return MockQuerySnapshot(documents: documents)
    }
    
    func addSnapshotListener(_ listener: @escaping (QuerySnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol {
        Task {
            do {
                let snapshot = try await getDocuments()
                listener(snapshot, nil)
            } catch {
                listener(nil, error)
            }
        }
        return MockListenerRegistration()
    }
//    func addSnapshotListener(_ listener: @escaping (QuerySnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol {
//        do {
//            let snapshot = try await getDocuments()
//            listener(snapshot, nil)
//        } catch {
//            listener(nil, error)
//        }
//        return MockListenerRegistration()
//    }
}

class MockDocumentSnapshot: DocumentSnapshotProtocol {
    var exists: Bool
    var data: [String: Any]?
    
    init(exists: Bool, data: [String: Any]?) {
        self.exists = exists
        self.data = data
    }
    
    func data(as type: Any.Type) throws -> Any {
        guard exists, let data = data else {
            throw NSError(domain: "FirestoreError", code: 10, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
        }
        
        // This is a simplified version - in a real implementation you'd need proper decoding
        return data
    }
}

class MockQueryDocumentSnapshot: QueryDocumentSnapshotProtocol {
    var documentID: String
    var data: [String: Any]
    
    init(documentID: String, data: [String: Any]) {
        self.documentID = documentID
        self.data = data
    }
    
    func data(as type: Any.Type) throws -> Any {
        // This is a simplified version - in a real implementation you'd need proper decoding
        return data
    }
}

class MockQuerySnapshot: QuerySnapshotProtocol {
    var documentChanges: [DocumentChangeProtocol] = []
    var documents: [QueryDocumentSnapshotProtocol]
    
    init(documents: [QueryDocumentSnapshotProtocol]) {
        self.documents = documents
        self.documentChanges = documents.map { doc in
            MockDocumentChange(type: .added, document: doc)
        }
    }
}

class MockDocumentChange: DocumentChangeProtocol {
    var type: DocumentChangeType
    var document: QueryDocumentSnapshotProtocol
    
    init(type: DocumentChangeType, document: QueryDocumentSnapshotProtocol) {
        self.type = type
        self.document = document
    }
}

class MockListenerRegistration: ListenerRegistrationProtocol {
    func remove() {
        // No-op for mock
    }
}
//
//// MARK: - Mock FirestoreService
//
//class MockFirestoreService: FirestoreServiceProtocol {
//    // Data storage for mock
//    var documents: [String: [String: Any]] = [:]
//    var collections: [String: [[String: Any]]] = [:]
//    var shouldThrowError = false
//    
//    // Document operations
//    func getDocument<T: Decodable>(from collection: String, documentId: String) async throws -> T {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        let path = "\(collection)/\(documentId)"
//        guard let data = documents[path] else {
//            throw NSError(domain: "NotFound", code: 404, userInfo: nil)
//        }
//        
//        let jsonData = try JSONSerialization.data(withJSONObject: data)
//        return try JSONDecoder().decode(T.self, from: jsonData)
//    }
//    
//    func setDocument<T: Encodable>(in collection: String, documentId: String, data: T) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        let jsonData = try JSONEncoder().encode(data)
//        let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
//        documents["\(collection)/\(documentId)"] = dictionary
//    }
//    
//    func updateDocument(in collection: String, documentId: String, data: [String: Any]) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        let path = "\(collection)/\(documentId)"
//        if var existingData = documents[path] {
//            for (key, value) in data {
//                existingData[key] = value
//            }
//            documents[path] = existingData
//        } else {
//            documents[path] = data
//        }
//    }
//    
//    func deleteDocument(from collection: String, documentId: String) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        documents.removeValue(forKey: "\(collection)/\(documentId)")
//    }
//    
//    // Collection operations
//    func getCollection<T: Decodable>(from collection: String) async throws -> [T] {
//        try await getCollectionWithFilter(collection: collection)
//    }
//    
//    func getCollection<T: Decodable>(from collection: String, whereField field: String, isEqualTo value: Any) async throws -> [T] {
//        try await getCollectionWithFilter(collection: collection, field: field, value: value, arrayContains: false)
//    }
//    
//    func getCollection<T: Decodable>(from collection: String, whereField field: String, arrayContains value: Any) async throws -> [T] {
//        try await getCollectionWithFilter(collection: collection, field: field, value: value, arrayContains: true)
//    }
//    
//    func getCollection<T: Decodable>(from collection: String, whereField field: String, isGreaterThan value: Any, limit: Int?) async throws -> [T] {
//        try await getCollectionWithFilter(collection: collection)
//    }
//    
//    func getCollection<T: Decodable>(from collection: String, whereField field: String, isNotEqualTo value: Any) async throws -> [T] {
//        try await getCollectionWithFilter(collection: collection)
//    }
//    
//    private func getCollectionWithFilter<T: Decodable>(
//        collection: String,
//        field: String? = nil,
//        value: Any? = nil,
//        arrayContains: Bool = false
//    ) async throws -> [T] {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        let collectionData = collections[collection] ?? []
//        var filteredData = collectionData
//        
//        if let field = field, let value = value {
//            filteredData = collectionData.filter { data in
//                if arrayContains {
//                    if let array = data[field] as? [Any] {
//                        return array.contains { element in
//                            if let element = element as? NSObject, let value = value as? NSObject {
//                                return element == value
//                            }
//                            return false
//                        }
//                    }
//                    return false
//                } else {
//                    if let fieldValue = data[field] as? NSObject, let value = value as? NSObject {
//                        return fieldValue == value
//                    }
//                    return false
//                }
//            }
//        }
//        
//        return try filteredData.map { data in
//            let jsonData = try JSONSerialization.data(withJSONObject: data)
//            return try JSONDecoder().decode(T.self, from: jsonData)
//        }
//    }
//    
//    // Listener operations
//    func addSnapshotListener<T: Decodable>(
//        for collection: String,
//        documentId: String?,
//        subCollection: String?,
//        orderBy field: String?,
//        descending: Bool,
//        completion: @escaping (Result<[T], Error>) -> Void
//    ) -> ListenerRegistration {
//        let mockListener = MockListenerRegistration()
//        
//        // Simulate initial data
//        Task {
//            do {
//                let data: [T] = try await getCollection(from: collection)
//                completion(.success(data))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//        
//        return mockListener
//    }
//    
//    // Transaction operations
//    func runTransaction<T>(_ updateBlock: @escaping (Transaction, NSErrorPointer) -> T?) async throws -> T {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        let mockTransaction = MockTransaction(firestoreService: self)
//        var error: NSError?
//        
//        if let result = updateBlock(mockTransaction, &error) {
//            return result
//        } else if let error = error {
//            throw error
//        } else {
//            throw NSError(domain: "TransactionFailed", code: -1, userInfo: nil)
//        }
//    }
//    
//    // Field value operations
//    func fieldArrayUnion(_ elements: [Any]) -> FieldValue {
//        FieldValue.arrayUnion(elements)
//    }
//    
//    func fieldArrayRemove(_ elements: [Any]) -> FieldValue {
//        FieldValue.arrayRemove(elements)
//    }
//}
//
//// MARK: - Mock AuthService
//
//class MockAuthService: AuthServiceProtocol {
//    var currentUser: User?
//    var shouldThrowError = false
//    
//    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        currentUser = User(uid: "mockUser", email: email)
//        return MockAuthDataResult(user: currentUser!)
//    }
//    
//    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        currentUser = User(uid: "newMockUser", email: email)
//        return MockAuthDataResult(user: currentUser!)
//    }
//    
//    func signOut() throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        currentUser = nil
//    }
//    
//    func updateProfile(displayName: String?, photoURL: URL?) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//    }
//}
//
//// MARK: - Mock EventService
//
//class MockEventService: EventServiceProtocol {
//    var events: [Event] = []
//    var shouldThrowError = false
//    
//    func fetchEvents(isEnded: Bool, limit: Int) async throws -> [Event] {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        return events.filter { $0.isEnded == isEnded }
//    }
//    
//    func fetchEvents(for category: SportCategory?, isEnded: Bool, limit: Int) async throws -> [Event] {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        var filteredEvents = events.filter { $0.isEnded == isEnded }
//        if let category = category {
//            filteredEvents = filteredEvents.filter { $0.sport == category }
//        }
//        return filteredEvents
//    }
//    
//    func fetchEvents(for userId: String, isHost: Bool) async throws -> [Event] {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        return isHost
//            ? events.filter { $0.hostId == userId }
//            : events.filter { $0.participants.contains(userId) }
//    }
//    
//    func joinEvent(eventId: String, userId: String) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        guard var event = events.first(where: { $0.id == eventId }) else {
//            throw NSError(domain: "NotFound", code: 404, userInfo: nil)
//        }
//        
//        if !event.participants.contains(userId) {
//            event.participants.append(userId)
//            if let index = events.firstIndex(where: { $0.id == eventId }) {
//                events[index] = event
//            }
//        }
//    }
//    
//    func endEvent(eventId: String) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        guard var event = events.first(where: { $0.id == eventId }) else {
//            throw NSError(domain: "NotFound", code: 404, userInfo: nil)
//        }
//        
//        event.isEnded = true
//        if let index = events.firstIndex(where: { $0.id == eventId }) {
//            events[index] = event
//        }
//    }
//    
//    func createEvent(_ event: Event) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        events.append(event)
//    }
//}
//
//// MARK: - Mock UserService
//
//class MockUserService: UserServiceProtocol {
//    var users: [User] = []
//    var shouldThrowError = false
//    
//    func fetchUser(userId: String) async throws -> User {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        guard let user = users.first(where: { $0.id == userId }) else {
//            throw NSError(domain: "NotFound", code: 404, userInfo: nil)
//        }
//        return user
//    }
//    
//    func fetchUsers() async throws -> [User] {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        return users
//    }
//    
//    func updateUser(userId: String, data: [String: Any]) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        guard var user = users.first(where: { $0.id == userId }) else {
//            throw NSError(domain: "NotFound", code: 404, userInfo: nil)
//        }
//        
//        // Simulate updating user properties
//        if let fullname = data["fullname"] as? String {
//            user.fullname = fullname
//        }
//        if let profileImageUrl = data["profileImageUrl"] as? String {
//            user.profileImageUrl = profileImageUrl
//        }
//        
//        if let index = users.firstIndex(where: { $0.id == userId }) {
//            users[index] = user
//        }
//    }
//    
//    func toggleFollow(currentUserId: String, targetUserId: String, isFollowing: Bool) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        guard var currentUser = users.first(where: { $0.id == currentUserId }),
//              var targetUser = users.first(where: { $0.id == targetUserId }) else {
//            throw NSError(domain: "NotFound", code: 404, userInfo: nil)
//        }
//        
//        if isFollowing {
//            currentUser.following?.removeAll { $0 == targetUserId }
//            targetUser.followers?.removeAll { $0 == currentUserId }
//        } else {
//            currentUser.following?.append(targetUserId)
//            targetUser.followers?.append(currentUserId)
//        }
//        
//        if let currentIndex = users.firstIndex(where: { $0.id == currentUserId }) {
//            users[currentIndex] = currentUser
//        }
//        if let targetIndex = users.firstIndex(where: { $0.id == targetUserId }) {
//            users[targetIndex] = targetUser
//        }
//    }
//    
//    func fetchFollowingStatus(currentUserId: String, targetUserId: String) async throws -> Bool {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        guard let currentUser = users.first(where: { $0.id == currentUserId }) else {
//            throw NSError(domain: "NotFound", code: 404, userInfo: nil)
//        }
//        
//        return currentUser.following?.contains(targetUserId) ?? false
//    }
//}
//
//// MARK: - Mock ChatService
//
//class MockChatService: ChatServiceProtocol {
//    var messages: [String: [ChatMessage]] = [:] // Key: chatId
//    var shouldThrowError = false
//    
//    func sendMessage(_ message: ChatMessage, in chatId: String) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        
//        if messages[chatId] == nil {
//            messages[chatId] = []
//        }
//        messages[chatId]?.append(message)
//    }
//    
//    func fetchMessages(for chatId: String, limit: Int) async throws -> [ChatMessage] {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        return messages[chatId] ?? []
//    }
//    
//    func setupChatListener(for chatId: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration {
//        let mockListener = MockListenerRegistration()
//        
//        // Simulate initial data
//        Task {
//            do {
//                let messages = try await fetchMessages(for: chatId, limit: 0)
//                completion(.success(messages))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//        
//        return mockListener
//    }
//    
//    func setUserOnlineStatus(chatId: String, userId: String, isOnline: Bool) async throws {
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: -1, userInfo: nil)
//        }
//        // No-op in mock
//    }
//}
//
//// MARK: - Mock LocationService
//
//class MockLocationService: LocationServiceProtocol {
//    var lastLocation: CLLocation?
//    var shouldThrowError = false
//    
//    func requestLocation() {
//        lastLocation = CLLocation(latitude: -6.2088, longitude: 106.8456) // Default to Jakarta
//    }
//    
//    func calculateDistance(from location: CLLocation) -> CLLocationDistance? {
//        lastLocation?.distance(from: location)
//    }
//}
//
//// MARK: - Supporting Mock Types
//
//private class MockListenerRegistration: ListenerRegistration {
//    func remove() {}
//}
//
//private class MockTransaction: Transaction {
//    let firestoreService: FirestoreServiceProtocol
//    
//    init(firestoreService: FirestoreServiceProtocol) {
//        self.firestoreService = firestoreService
//    }
//    
//    override func getDocument(_ documentRef: DocumentReference) throws -> DocumentSnapshot {
//        let path = "\(documentRef.collectionID)/\(documentRef.documentID)"
//        guard let data = (firestoreService as? MockFirestoreService)?.documents[path] else {
//            throw NSError(domain: "NotFound", code: 404, userInfo: nil)
//        }
//        return MockDocumentSnapshot(data: data, documentID: documentRef.documentID)
//    }
//    
//    override func updateData(_ fields: [AnyHashable: Any], forDocument documentRef: DocumentReference) {
//        let path = "\(documentRef.collectionID)/\(documentRef.documentID)"
//        (firestoreService as? MockFirestoreService)?.documents[path] = fields as? [String: Any]
//    }
//}
//
//private class MockDocumentSnapshot: DocumentSnapshot {
//    private let mockData: [String: Any]?
//    private let mockDocumentID: String
//    
//    init(data: [String: Any]?, documentID: String) {
//        self.mockData = data
//        self.mockDocumentID = documentID
//        super.init()
//    }
//    
//    override var data: [String: Any]? { mockData }
//    override var documentID: String { mockDocumentID }
//    override var exists: Bool { mockData != nil }
//}
//
//private struct MockAuthDataResult: AuthDataResult {
//    var user: User
//    var additionalUserInfo: AdditionalUserInfo? = nil
//    var credential: AuthCredential? = nil
//}
