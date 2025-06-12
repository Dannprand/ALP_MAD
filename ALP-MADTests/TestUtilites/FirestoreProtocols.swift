//
//  FirestoreProtocols.swift
//  ALP-MADTests
//
//  Created by student on 12/06/25.
//

// File: ALP-MADTests/TestUtilities/FirestoreProtocols.swift

import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import CoreLocation

protocol FirestoreProtocol {

    func collection(_ collectionPath: String) -> CollectionReferenceProtocol
    func runTransaction(_ updateBlock: @escaping (TransactionProtocol, NSErrorPointer) -> Any?) async throws -> Any?
}

protocol DocumentReferenceProtocol {
    var documentID: String { get }
    func updateData(_ fields: [AnyHashable: Any]) async throws -> Void
    func getDocument(source: FirestoreSource) async throws -> DocumentSnapshotProtocol
}

protocol QueryProtocol {
    func whereField(_ field: String, isEqualTo value: Any) -> QueryProtocol
    func whereField(_ field: String, isGreaterThan value: Any) -> QueryProtocol
    func order(by field: String) -> QueryProtocol
    func limit(to limit: Int) -> QueryProtocol
    func getDocuments(source: FirestoreSource) async throws -> QuerySnapshotProtocol
}

protocol CollectionReferenceProtocol: QueryProtocol {
    func document(_ documentPath: String) -> DocumentReferenceProtocol
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

// Mock LocationManager
protocol LocationManagerProtocol {
    var lastLocation: CLLocation? { get }
}

class MockLocationManager: LocationManagerProtocol {
    var lastLocation: CLLocation?
    
    init(lastLocation: CLLocation? = nil) {
        self.lastLocation = lastLocation
    }
}
