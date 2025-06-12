//
//  FirestoreProtocols.swift
//  ALP-MAD
//
//  Created by student on 12/06/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation

protocol FirestoreProtocol {
    func collection(_ collectionPath: String) -> CollectionReferenceProtocol
    func runTransaction(_ updateBlock: @escaping (TransactionProtocol, NSErrorPointer) -> Any?) async throws -> Any?
}

protocol CollectionReferenceProtocol {
    var documentID: String { get }
    func document(_ documentPath: String) -> DocumentReferenceProtocol
    func whereField(_ field: String, isGreaterThan value: Any) -> QueryProtocol
    func whereField(_ field: String, isEqualTo value: Any) -> QueryProtocol
    func order(by field: String) -> QueryProtocol
    func limit(to limit: Int) -> QueryProtocol
    func getDocuments(source: FirestoreSource) async throws -> QuerySnapshotProtocol
}

protocol DocumentReferenceProtocol {
    var documentID: String { get }
    func updateData(_ fields: [AnyHashable: Any]) async throws -> Void
    func getDocument(source: FirestoreSource) async throws -> DocumentSnapshotProtocol
}

protocol QueryProtocol {
    func whereField(_ field: String, isGreaterThan value: Any) -> QueryProtocol
    func whereField(_ field: String, isEqualTo value: Any) -> QueryProtocol
    func order(by field: String) -> QueryProtocol
    func limit(to limit: Int) -> QueryProtocol
    func getDocuments(source: FirestoreSource) async throws -> QuerySnapshotProtocol
}

protocol DocumentSnapshotProtocol {
    var documentID: String { get }
    func data() -> [String: Any]?
}

protocol QuerySnapshotProtocol {
    var documents: [QueryDocumentSnapshotProtocol] { get }
}

protocol QueryDocumentSnapshotProtocol {
    var documentID: String { get }
    func data() -> [String: Any]
}

protocol TransactionProtocol {
    func getDocument(_ document: DocumentReferenceProtocol) throws -> DocumentSnapshotProtocol
    func updateData(_ fields: [AnyHashable: Any], forDocument document: DocumentReferenceProtocol)
}

// LocationManager Protocol
//protocol LocationManagerProtocol {
//    var lastLocation: CLLocation? { get }
//}
