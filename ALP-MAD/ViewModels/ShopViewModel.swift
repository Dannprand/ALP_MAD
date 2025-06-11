//
//  ShopViewModel.swift
//  ALP-MAD
//
//  Created by student on 05/06/25.
//

import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

class ShopViewModel: ObservableObject {
    @Published var rewards: [Reward] = []
    @Published var filteredRewards: [Reward] = []
    @Published var selectedCategory: RewardCategory = .all {
        didSet {
            filterRewards()
        }
    }
    
    @Published var tokenHistory: [TokenTransaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchRewards() {
        isLoading = true
        db.collection("rewards").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Failed to fetch rewards: \(error.localizedDescription)"
                    return
                }
                
                self.rewards = snapshot?.documents.compactMap { document in
                    try? document.data(as: Reward.self)
                } ?? []
                
                self.filterRewards()
            }
        }
    }
    
    private func filterRewards() {
        if selectedCategory == .all {
            filteredRewards = rewards
        } else {
            filteredRewards = rewards.filter { $0.category == selectedCategory }
        }
    }
    
    func fetchTokenHistory(userId: String) {
        db.collection("users")
            .document(userId)
            .collection("tokenHistory")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Failed to fetch token history: \(error.localizedDescription)"
                        return
                    }
                    
                    self.tokenHistory = snapshot?.documents.compactMap { document in
                        try? document.data(as: TokenTransaction.self)
                    } ?? []
                }
            }
    }
    
    func redeemReward(userId: String, reward: Reward, userToken: Int, completion: @escaping (Bool, String?) -> Void) {
        guard userToken >= reward.cost else {
            completion(false, "Token tidak cukup untuk menukar reward ini.")
            return
        }
        
        let userRef = db.collection("users").document(userId)
        let tokenHistoryRef = userRef.collection("tokenHistory").document()
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // Fetch user token value
            let userDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
            } catch let fetchErr {
                errorPointer?.pointee = fetchErr as NSError
                return nil
            }
            
            guard var tokens = userDoc.data()?["tokens"] as? Int else {
                errorPointer?.pointee = NSError(domain: "ShopViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data token tidak ditemukan."])
                return nil
            }
            
            if tokens < reward.cost {
                errorPointer?.pointee = NSError(domain: "ShopViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token tidak cukup."])
                return nil
            }
            
            // Kurangi token
            tokens -= reward.cost
            transaction.updateData(["tokens": tokens], forDocument: userRef)
            
            // Tambahkan tokenHistory
            let transactionData: [String: Any] = [
                "amount": -reward.cost,
                "date": Timestamp(date: Date()),
                "reason": "Redeemed: \(reward.name)"
            ]
            transaction.setData(transactionData, forDocument: tokenHistoryRef)
            
            return nil
        }, completion: { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        })
    }
}
