//
//  ShopViewModel.swift
//  ALP-MAD
//
//  Created by student on 05/06/25.
//

import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

@MainActor
class ShopViewModel: ObservableObject {
    @Published var rewards: [Reward] = []
    @Published var selectedCategory: RewardCategory = .all
    @Published var selectedReward: Reward?
    @Published var tokenTransactions: [TokenTransaction] = []
    @Published var errorMessage: String?

    // Filter rewards sesuai kategori yang dipilih
    var filteredRewards: [Reward] {
        if selectedCategory == .all {
            return rewards
        } else {
            return rewards.filter { $0.category == selectedCategory }
        }
    }

    // Fetch daftar rewards dari Firestore
    func fetchRewards() async {
        do {
            let snapshot = try await Firestore.firestore().collection("rewards").getDocuments()
            let fetchedRewards = try snapshot.documents.compactMap { document in
                try document.data(as: Reward.self)
            }
            DispatchQueue.main.async {
                self.rewards = fetchedRewards
            }
        } catch {
            print("Failed to fetch rewards: \(error)")
        }
    }

    // Redeem reward untuk user tertentu
    func redeemReward(_ reward: Reward, for userId: String) async -> Bool {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        let tokenTransactionRef = db.collection("token_transactions").document()

        do {
            let userSnapshot = try await userRef.getDocument()
            guard var currentTokens = userSnapshot.data()?["tokens"] as? Int else {
                errorMessage = "Unable to retrieve token balance."
                return false
            }

            guard currentTokens >= reward.cost else {
                errorMessage = "Insufficient tokens."
                return false
            }

            // Mulai transaksi batch
            let batch = db.batch()

            // Update token user
            currentTokens -= reward.cost
            batch.updateData(["tokens": currentTokens], forDocument: userRef)

            // Simpan transaksi token
            let transaction = TokenTransaction(
                id: tokenTransactionRef.documentID,
                amount: -reward.cost,
                date: Date(),
                eventName: nil,
                reason: "Redeemed \(reward.name)"
            )

            try batch.setData(from: transaction, forDocument: tokenTransactionRef)

            // Commit batch
            try await batch.commit()
            return true
        } catch {
            print("Failed to redeem reward: \(error)")
            errorMessage = "Redemption failed. Please try again."
            return false
        }
    }

    // Fetch riwayat transaksi token user
    func fetchTokenTransactions(for userId: String) async {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("token_transactions")
                .whereField("userId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .getDocuments()

            let transactions = try snapshot.documents.compactMap { doc in
                try doc.data(as: TokenTransaction.self)
            }

            DispatchQueue.main.async {
                self.tokenTransactions = transactions
            }
        } catch {
            print("Failed to fetch token transactions: \(error)")
        }
    }
}
