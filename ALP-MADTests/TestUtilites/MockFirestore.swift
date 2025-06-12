//
//  MockFirestore.swift
//  ALP-MADTests
//
//  Created by student on 12/06/25.
//

// File: ALP-MADTests/TestUtilities/MockFirestore.swift

class MockFirestore: FirestoreProtocol {
    var collections: [String: MockCollectionReference] = [:]
    var shouldThrowError = false
    
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
        if let existing = collections[collectionPath] {
            return existing
        }
        let newCollection = MockCollectionReference(id: collectionPath, firestore: self)
        collections[collectionPath] = newCollection
        return newCollection
    }
    
    func runTransaction(_ updateBlock: @escaping (TransactionProtocol, NSErrorPointer) -> Any?) async throws -> Any? {
        if shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 1, userInfo: nil)
        }
        let mockTransaction = MockTransaction(firestore: self)
        var error: NSError?
        return updateBlock(mockTransaction, &error)
    }
}

class MockCollectionReference: CollectionReferenceProtocol {
    var id: String
    var firestore: MockFirestore
    var documents: [String: MockDocumentReference] = [:]
    
    init(id: String, firestore: MockFirestore) {
        self.id = id
        self.firestore = firestore
    }
    
    var documentID: String { id }
    
    func document(_ documentPath: String) -> DocumentReferenceProtocol {
        if let existing = documents[documentPath] {
            return existing
        }
        let newDoc = MockDocumentReference(id: documentPath, collection: self)
        documents[documentPath] = newDoc
        return newDoc
    }
    
    func whereField(_ field: String, isGreaterThan value: Any) -> QueryProtocol {
        return self as QueryProtocol
    }
    
    func whereField(_ field: String, isEqualTo value: Any) -> QueryProtocol {
        return self as QueryProtocol
    }
    
    func order(by field: String) -> QueryProtocol {
        return self as QueryProtocol
    }
    
    func limit(to limit: Int) -> QueryProtocol {
        return self as QueryProtocol
    }
    
    func getDocuments(source: FirestoreSource) async throws -> QuerySnapshotProtocol {
        if firestore.shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 1, userInfo: nil)
        }
        return MockQuerySnapshot(documents: Array(documents.values.map { MockQueryDocumentSnapshot(document: $0) }))
    }
}

class MockDocumentReference: DocumentReferenceProtocol {
    var id: String
    var collection: MockCollectionReference
    var data: [String: Any]?
    var shouldThrowError = false
    
    init(id: String, collection: MockCollectionReference, data: [String: Any]? = nil) {
        self.id = id
        self.collection = collection
        self.data = data
    }
    
    var documentID: String { id }
    
    func updateData(_ fields: [AnyHashable: Any]) async throws {
        if shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 1, userInfo: nil)
        }
        data = fields as? [String: Any]
    }
    
    func getDocument(source: FirestoreSource) async throws -> DocumentSnapshotProtocol {
        if shouldThrowError {
            throw NSError(domain: "FirestoreError", code: 1, userInfo: nil)
        }
        return MockDocumentSnapshot(document: self)
    }
}

class MockQuerySnapshot: QuerySnapshotProtocol {
    var documents: [QueryDocumentSnapshotProtocol]
    
    init(documents: [QueryDocumentSnapshotProtocol]) {
        self.documents = documents
    }
}

class MockQueryDocumentSnapshot: QueryDocumentSnapshotProtocol {
    var document: MockDocumentReference
    
    init(document: MockDocumentReference) {
        self.document = document
    }
    
    var documentID: String { document.id }
    
    func data() -> [String: Any] {
        return document.data ?? [:]
    }
}

class MockDocumentSnapshot: DocumentSnapshotProtocol {
    var document: MockDocumentReference
    
    init(document: MockDocumentReference) {
        self.document = document
    }
    
    var documentID: String { document.id }
    
    func data() -> [String: Any]? {
        return document.data
    }
}

class MockTransaction: TransactionProtocol {
    var firestore: MockFirestore
    
    init(firestore: MockFirestore) {
        self.firestore = firestore
    }
    
    func getDocument(_ document: DocumentReferenceProtocol) throws -> DocumentSnapshotProtocol {
        guard let mockDoc = document as? MockDocumentReference else {
            throw NSError(domain: "FirestoreError", code: 1, userInfo: nil)
        }
        return MockDocumentSnapshot(document: mockDoc)
    }
    
    func updateData(_ fields: [AnyHashable: Any], forDocument document: DocumentReferenceProtocol) {
        guard let mockDoc = document as? MockDocumentReference else { return }
        mockDoc.data = fields as? [String: Any]
    }
}
