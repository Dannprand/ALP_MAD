//
//  FirestoreExtensions.swift
//  ALP-MAD
//
//  Created by student on 12/06/25.
//

// File: ALP-MAD/Services/FirestoreService/FirestoreExtensions.swift

import FirebaseFirestore

// MARK: - Firestore Protocol Conformance
extension Firestore: FirestoreProtocol {
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
        let colRef: CollectionReference = self.collection(collectionPath)
        return colRef
    }

    func runTransaction(_ updateBlock: @escaping (TransactionProtocol, NSErrorPointer) -> Any?) async throws -> Any? {
        return try await self.runTransaction(updateBlock)
    }
}

extension CollectionReference: CollectionReferenceProtocol {
//    func document(_ documentPath: String) -> DocumentReferenceProtocol {
//        return self.document(documentPath) as DocumentReferenceProtocol
//    }
    var documentID: String {
                return self.documentID // This accesses the underlying Firestore property
            }
        
    func document(_ documentPath: String) -> DocumentReferenceProtocol {
            let docRef: DocumentReference = self.document(documentPath)
            return docRef as DocumentReferenceProtocol
        }
}

extension DocumentReference: DocumentReferenceProtocol {
    public func updateData(_ fields: [AnyHashable: Any]) async throws {
        try await self.updateData(fields)
    }

    func getDocument(source: FirestoreSource) async throws -> DocumentSnapshotProtocol {
        let snapshot: DocumentSnapshot = try await self.getDocument(source: source)
        return snapshot as DocumentSnapshotProtocol
    }
}

// Query conforms to QueryProtocol directly; nothing to change here unless you override methods
//extension Query: QueryProtocol {}
extension Query: QueryProtocol {
    func whereField(_ field: String, isEqualTo value: Any) -> QueryProtocol {
        let query: Query = self.whereField(field, isEqualTo: value)
        return query as QueryProtocol
    }

    func whereField(_ field: String, isGreaterThan value: Any) -> QueryProtocol {
        let query: Query = self.whereField(field, isGreaterThan: value)
        return query as QueryProtocol
    }

    func order(by field: String) -> QueryProtocol {
        let query: Query = self.order(by: field)
        return query as QueryProtocol
    }

    func limit(to limit: Int) -> QueryProtocol {
        let query: Query = self.limit(to: limit)
        return query as QueryProtocol
    }

    func getDocuments(source: FirestoreSource) async throws -> QuerySnapshotProtocol {
        let snapshot: QuerySnapshot = try await self.getDocuments(source: source)
        return snapshot as QuerySnapshotProtocol
    }
}


// DocumentSnapshot extension
extension DocumentSnapshot: DocumentSnapshotProtocol {
    public func data() -> [String: Any]? {
        let data: [String: Any]? = self.data()
        return data
    }
}

extension QuerySnapshot: QuerySnapshotProtocol {
    var documents: [QueryDocumentSnapshotProtocol] {
        return self.documents.map { $0 as QueryDocumentSnapshotProtocol }
    }
}

extension QueryDocumentSnapshot: QueryDocumentSnapshotProtocol {}

// Transaction extension
extension Transaction: TransactionProtocol {
    func getDocument(_ document: DocumentReferenceProtocol) throws -> DocumentSnapshotProtocol {
        guard let docRef: DocumentReference = document as? DocumentReference else {
            throw NSError(domain: "FirestoreError", code: 1, userInfo: nil)
        }
        let snapshot: DocumentSnapshot = try self.getDocument(docRef)
        return snapshot as DocumentSnapshotProtocol
    }

    func updateData(_ fields: [AnyHashable: Any], forDocument document: DocumentReferenceProtocol) {
        guard let docRef: DocumentReference = document as? DocumentReference else { return }
        self.updateData(fields, forDocument: docRef)
    }
}
