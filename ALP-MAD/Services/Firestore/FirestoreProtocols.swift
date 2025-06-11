//
//  FirestoreProtocols.swift
//  ALP-MAD
//
//  Created by Kevin Christian on 12/06/25.
//

// FirestoreProtocols.swift
import Foundation

protocol FirestoreService {
    func collection(_ path: String) -> FirestoreCollection
}

protocol FirestoreCollection {
    func document(_ path: String) -> FirestoreDocument
    func whereField(_ field: String, isEqualTo value: Any) -> FirestoreQuery
}

protocol FirestoreDocument {
    func getDocument(completion: @escaping (Result<[String: Any], Error>) -> Void)
}

protocol FirestoreQuery {
    func getDocuments(completion: @escaping (Result<[[String: Any]], Error>) -> Void)
}

