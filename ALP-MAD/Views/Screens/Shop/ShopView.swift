//
//  ShopView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ShopViewModel()
    @State private var selectedReward: Reward?

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Category", selection: $viewModel.selectedCategory) {
                    ForEach(RewardCategory.allCases, id: \..self) { category in
                        Text(category.rawValue.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredRewards) { reward in
                            RewardCard(reward: reward) {
                                selectedReward = reward
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Shop")
            .sheet(item: $selectedReward) { reward in
                RewardDetailView(reward: reward) {
                    viewModel.redeem(reward: reward, forUser: authViewModel.currentUser)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TokenHistoryView()) {
                        Image(systemName: "clock")
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
        List(tokenHistory) { transaction in
            VStack(alignment: .leading) {
                Text("\(transaction.amount >= 0 ? "+" : "")\(transaction.amount) Tokens")
                    .font(.headline)
                    .foregroundColor(transaction.amount >= 0 ? .green : .red)
                if let eventName = transaction.eventName {
                    Text(eventName)
                        .font(.subheadline)
                }
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Token History")
        .onAppear {
            guard let user = authViewModel.currentUser else { return }
            authViewModel.fetchTokenHistory(for: user) { transactions in
                self.tokenHistory = transactions
            }
        }
    }
}
