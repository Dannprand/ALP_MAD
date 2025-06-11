//
//  RewardDetailView.swift
//  ALP-MAD
//
//  Created by student on 11/06/25.
//

import SwiftUI


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
