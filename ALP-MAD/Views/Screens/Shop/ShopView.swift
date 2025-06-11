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
        let currentTokens = authViewModel.currentUser?.tokens ?? 0
        let selectedCategory = viewModel.selectedCategory
        let categories = RewardCategory.allCases
        let rewards = viewModel.filteredRewards

        ScrollView {
            VStack(spacing: 20) {

                // Token Balance Section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Balance")
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryText)

                        HStack(spacing: 8) {
                            Image(systemName: "s.circle.fill")
                                .foregroundColor(Theme.accentOrange)

                            Text("\(currentTokens)")
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

                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            let isSelected = selectedCategory == category

                            Button {
                                viewModel.selectedCategory = category
                            } label: {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? Theme.accentOrange : Theme.cardBackground)
                                    .foregroundColor(isSelected ? .white : Theme.primaryText)
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

                // Rewards Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(rewards) { reward in
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
            RewardDetailView(reward: reward) {
                Task {
                    if let userId = authViewModel.currentUser?.id {
                        await viewModel.redeemReward(reward, for: userId)
                        await authViewModel.fetchUser()
                    }
                }
            }
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

