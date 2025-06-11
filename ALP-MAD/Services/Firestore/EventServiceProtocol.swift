//
//  EventServiceProtocol.swift
//  ALP-MAD
//
//  Created by Kevin Christian on 12/06/25.
//

import Foundation
import FirebaseFirestore

protocol EventServiceProtocol {
    func fetchEvents(isEnded: Bool, limit: Int) async throws -> [Event]
    func fetchEvents(for category: SportCategory?, isEnded: Bool, limit: Int) async throws -> [Event]
    func fetchEvents(for userId: String, isHost: Bool) async throws -> [Event]
    func joinEvent(eventId: String, userId: String) async throws
    func endEvent(eventId: String) async throws
    func createEvent(_ event: Event) async throws
}
