//
//  ShopViewModel.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class ShopViewModel: ObservableObject {
    @Published var rewards: [Reward] = []
    @Published var selectedCategory: RewardCategory = .all
    @Published var selectedReward: Reward?

    var filteredRewards: [Reward] {
        selectedCategory == .all ? rewards : rewards.filter { $0.category == selectedCategory }
    }

    func fetchRewards() async {
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulasi loading

        // Data dummy (ganti dengan Firestore jika perlu)
        rewards = [
            Reward(id: "1", name: "Gym Membership (1 Month)", description: "1 month free membership", cost: 50, category: .memberships, imageName: "gym", terms: "Valid only once", stock: 100),
            Reward(id: "2", name: "Water Bottle", description: "Insulated bottle", cost: 20, category: .apparel, imageName: "water-bottle", terms: "Limited to 2 per user", stock: 50),
            // Tambahkan lainnya
        ]
    }

    func redeemReward(_ reward: Reward, for userId: String) async {
        let db = Firestore.firestore()
        do {
            try await db.collection("users").document(userId).updateData([
                "tokens": FieldValue.increment(Int64(-reward.cost)),
                "redeemedRewards": FieldValue.arrayUnion([reward.id])
            ])

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

        } catch {
            print("Error redeeming reward: \(error)")
        }
    }
}

