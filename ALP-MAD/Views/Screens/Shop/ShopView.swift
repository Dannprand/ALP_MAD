//
//  ShopView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseFirestore

struct ShopView: View {
    @StateObject var viewModel = ShopViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Token balance section
                let tokens = authViewModel.currentUser?.tokens ?? 0
                let tokenView = HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Balance")
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryText)

                        HStack(spacing: 8) {
                            Image(systemName: "s.circle.fill")
                                .foregroundColor(Theme.accentOrange)
                            Text("\(tokens)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.primaryText)
                        }
                    }

                    Spacer()

                    NavigationLink(destination: TokenHistoryView()) {
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

//                tokenView

                // Reward categories
                let categoryButtons = ForEach(RewardCategory.allCases, id: \.self) { category in
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

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        categoryButtons
                    }
                    .padding(.horizontal)
                }

                // Rewards grid
                let rewardGrid = LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.filteredRewards) { reward in
                        RewardCard(reward: reward) {
                            viewModel.selectedReward = reward
                        }
                    }
                }
                .padding()

                rewardGrid
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Rewards Shop")
        .sheet(item: $viewModel.selectedReward) { reward in
            RewardDetailView(reward: reward, onRedeem: {
                Task {
                    if let userId = authViewModel.currentUser?.id {
                        await viewModel.redeemReward(reward, for: userId)
                        await authViewModel.fetchUser()
                    }
                }
            })
        }
        .task {
            await viewModel.fetchRewards()
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

