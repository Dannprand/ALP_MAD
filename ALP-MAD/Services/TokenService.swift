//
//  TokenService.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import FirebaseFirestore

class TokenService {
    private let db = Firestore.firestore()
    
    func awardTokens(userId: String, eventId: String, amount: Int, reason: String) async {
        do {
            // Update user's token balance
            try await db.collection("users").document(userId).updateData([
                "tokens": FieldValue.increment(Int64(amount))
            ])
            
            // Record transaction
            let transaction = TokenTransaction(
                id: UUID().uuidString,
                amount: amount,
                date: Date(),
                eventName: reason,
                reason: "Event participation"
            )
            
            try db.collection("users").document(userId)
                .collection("tokenHistory")
                .document(transaction.id)
                .setData(from: transaction)
            
        } catch {
            print("Error awarding tokens: \(error)")
        }
    }
    
    func redeemReward(userId: String, reward: Reward) async -> Bool {
        guard let currentUser = try? await db.collection("users").document(userId).getDocument().data(as: User.self) else {
            return false
        }
        
        // Check if user has enough tokens
        guard currentUser.tokens >= reward.cost else {
            return false
        }
        
        do {
            // Deduct tokens
            try await db.collection("users").document(userId).updateData([
                "tokens": FieldValue.increment(Int64(-reward.cost)),
                "redeemedRewards": FieldValue.arrayUnion([reward.id])
            ])
            
            // Record transaction
            let transaction = TokenTransaction(
                id: UUID().uuidString,
                amount: -reward.cost,
                date: Date(),
                eventName: reward.name,
                reason: "Reward redemption"
            )
            
            try db.collection("users").document(userId)
                .collection("tokenHistory")
                .document(transaction.id)
                .setData(from: transaction)
            
            return true
        } catch {
            print("Error redeeming reward: \(error)")
            return false
        }
    }
}
