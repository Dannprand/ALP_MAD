//
//  ChatServiceProtocol.swift
//  ALP-MAD
//
//  Created by Kevin Christian on 12/06/25.
//

import Foundation
import FirebaseFirestore

protocol ChatServiceProtocol {
    func sendMessage(_ message: ChatMessage, in chatId: String) async throws
    func fetchMessages(for chatId: String, limit: Int) async throws -> [ChatMessage]
    func setupChatListener(for chatId: String, completion: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration
    func setUserOnlineStatus(chatId: String, userId: String, isOnline: Bool) async throws
}
