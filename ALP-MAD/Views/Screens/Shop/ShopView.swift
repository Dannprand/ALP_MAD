//
//  ShopView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseFirestore

struct ShopView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var viewModel = ShopViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Token balance
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Balance")
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryText)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "s.circle.fill")
                                .foregroundColor(Theme.accentOrange)
                            Text("\(authViewModel.currentUser?.tokens ?? 0)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.primaryText)
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        TokenHistoryView()
                    } label: {
                        Text("History")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.cardBackground)
                            .foregroundColor(Theme.accentOrange)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Rewards categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(RewardCategory.allCases, id: \.self) { category in
                            Button(action: {
                                viewModel.selectedCategory = category
                            }) {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedCategory == category ? Theme.accentOrange : Theme.cardBackground)
                                    .foregroundColor(viewModel.selectedCategory == category ? .white : Theme.primaryText)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Theme.accentOrange, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Rewards grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.filteredRewards) { reward in
                        RewardCard(reward: reward) {
                            viewModel.selectedReward = reward
                        }
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Rewards Shop")
        .sheet(item: $viewModel.selectedReward) { reward in
            RewardDetailView(reward: reward, onRedeem: {
                Task {
                    await viewModel.redeemReward(reward, for: authViewModel.currentUser?.id ?? "")
                    await authViewModel.fetchUser()
                }
            })
        }
        .task {
            await viewModel.fetchRewards()
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(reward.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, 8)
                
                Text(reward.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.primaryText)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                
                HStack(spacing: 4) {
                    Image(systemName: "s.circle.fill")
                        .foregroundColor(Theme.accentOrange)
                    Text("\(reward.cost)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.accentOrange)
                }
                .padding(6)
                .background(Theme.accentOrange.opacity(0.2))
                .cornerRadius(10)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .background(Theme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.accentOrange.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct RewardDetailView: View {
    let reward: Reward
    let onRedeem: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(reward.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(reward.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.primaryText)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "s.circle.fill")
                                .foregroundColor(Theme.accentOrange)
                            Text("\(reward.cost) tokens")
                                .font(.headline)
                                .foregroundColor(Theme.accentOrange)
                        }
                        
                        Divider()
                            .background(Theme.cardBackground)
                        
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(Theme.primaryText)
                        
                        Text(reward.description)
                            .font(.body)
                            .foregroundColor(Theme.secondaryText)
                        
                        if !reward.terms.isEmpty {
                            Text("Terms & Conditions")
                                .font(.headline)
                                .foregroundColor(Theme.primaryText)
                                .padding(.top, 8)
                            
                            Text(reward.terms)
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        onRedeem()
                        dismiss()
                    }) {
                        Text("Redeem Reward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Reward Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.primaryText)
                    }
                }
            }
        }
    }
}

struct TokenHistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var tokenHistory: [TokenTransaction] = []
    
    var body: some View {
        List {
            ForEach(tokenHistory) { transaction in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(transaction.eventName ?? "System")
                            .font(.subheadline)
                            .foregroundColor(Theme.primaryText)
                        
                        Spacer()
                        
                        Text(transaction.amount >= 0 ? "+\(transaction.amount)" : "\(transaction.amount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(transaction.amount >= 0 ? Theme.success : Theme.error)
                    }
                    
                    Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                    
                    if let reason = transaction.reason {
                        Text(reason)
                            .font(.caption)
                            .foregroundColor(Theme.secondaryText)
                    }
                }
            }
        }
        .listStyle(.plain)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Token History")
        .task {
            await fetchTokenHistory()
        }
    }
    
    private func fetchTokenHistory() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("tokenHistory")
                .order(by: "date", descending: true)
                .getDocuments()
            
            tokenHistory = try snapshot.documents.compactMap { document in
                try document.data(as: TokenTransaction.self)
            }
        } catch {
            print("Error fetching token history: \(error)")
        }
    }
}

enum RewardCategory: String, CaseIterable, Codable {
    case all = "All"
    case fitness = "Fitness"
    case apparel = "Apparel"
    case equipment = "Equipment"
    case memberships = "Memberships"
}


struct Reward: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let cost: Int
    let category: RewardCategory
    let imageName: String
    let terms: String
    let stock: Int
}

struct TokenTransaction: Identifiable, Codable {
    let id: String
    let amount: Int
    let date: Date
    let eventName: String?
    let reason: String?
}

class ShopViewModel: ObservableObject {
    @Published var rewards: [Reward] = []
    @Published var selectedCategory: RewardCategory = .all
    @Published var selectedReward: Reward?
    
    var filteredRewards: [Reward] {
        if selectedCategory == .all {
            return rewards
        } else {
            return rewards.filter { $0.category == selectedCategory }
        }
    }
    
    func fetchRewards() async {
        // Simulate network request
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // In a real app, you would fetch from Firestore or your backend
        let mockRewards = [
            Reward(
                id: "1",
                name: "Gym Membership (1 Month)",
                description: "1 month free membership at any participating gym",
                cost: 50,
                category: .memberships,
                imageName: "gym",
                terms: "Valid at participating locations only. One per person.",
                stock: 100
            ),
            Reward(
                id: "2",
                name: "Sports Water Bottle",
                description: "Premium insulated water bottle with SportHub logo",
                cost: 20,
                category: .apparel,
                imageName: "water-bottle",
                terms: "While supplies last. Limited to 2 per user.",
                stock: 50
            ),
            Reward(
                id: "3",
                name: "Running Shoes Discount",
                description: "30% off on selected running shoes",
                cost: 30,
                category: .apparel,
                imageName: "running-shoes",
                terms: "Valid at partner stores. Exclusions apply.",
                stock: 200
            ),
            Reward(
                id: "4",
                name: "Yoga Mat",
                description: "High-quality non-slip yoga mat",
                cost: 40,
                category: .equipment,
                imageName: "yoga-mat",
                terms: "Colors may vary. Limited stock.",
                stock: 30
            ),
            Reward(
                id: "5",
                name: "Personal Training Session",
                description: "One free session with certified trainer",
                cost: 60,
                category: .fitness,
                imageName: "personal-training",
                terms: "Must be redeemed within 3 months.",
                stock: 25
            ),
            Reward(
                id: "6",
                name: "SportHub T-Shirt",
                description: "Official SportHub branded t-shirt",
                cost: 25,
                category: .apparel,
                imageName: "tshirt",
                terms: "Sizes subject to availability.",
                stock: 75
            )
        ]
        
        await MainActor.run {
            rewards = mockRewards
        }
    }
    
    func redeemReward(_ reward: Reward, for userId: String) async {
        // In a real app, you would:
        // 1. Verify user has enough tokens
        // 2. Create transaction record
        // 3. Update user's token balance
        // 4. Send reward details to user
        
        let db = Firestore.firestore()
        
        do {
            // Add to user's redeemed rewards
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
            
            // In a real app, you might also:
            // - Send email with redemption code
            // - Update reward stock
            // - Notify admin of redemption
        } catch {
            print("Error redeeming reward: \(error)")
        }
    }
}
