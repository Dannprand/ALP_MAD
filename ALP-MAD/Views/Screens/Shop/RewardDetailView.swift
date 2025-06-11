////
////  RewardDetailView.swift
////  ALP-MAD
////
////  Created by student on 11/06/25.
////
//
//import SwiftUI
//
//
//struct RewardDetailView: View {
//    let reward: Reward
//    let onRedeem: () -> Void
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        VStack(spacing: 16) {
//            if let imageURL = URL(string: reward.imageUrl) {
//                AsyncImage(url: imageURL) { image in
//                    image.resizable()
//                         .aspectRatio(contentMode: .fit)
//                         .frame(height: 200)
//                         .cornerRadius(12)
//                } placeholder: {
//                    ProgressView()
//                }
//            }
//
//            Text(reward.name)
//                .font(.title)
//                .bold()
//
//            Text(reward.description)
//                .font(.body)
//                .padding(.horizontal)
//
//            Text("Cost: \(reward.cost) Tokens")
//                .font(.headline)
//                .foregroundColor(.orange)
//
//            Spacer()
//
//            Button(action: {
//                onRedeem()
//                dismiss()
//            }) {
//                Text("Redeem")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.orange)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//            }
//            .padding(.horizontal)
//        }
//        .padding()
//    }
//}
//
//struct RewardCard: View {
//    let reward: Reward
//    var onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: 16) {
//                if let imageURL = URL(string: reward.imageUrl) {
//                    AsyncImage(url: imageURL) { image in
//                        image.resizable()
//                             .aspectRatio(contentMode: .fill)
//                             .frame(width: 60, height: 60)
//                             .cornerRadius(8)
//                    } placeholder: {
//                        Color.gray.opacity(0.2)
//                            .frame(width: 60, height: 60)
//                            .cornerRadius(8)
//                    }
//                }
//
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(reward.name)
//                        .font(.headline)
//                    Text("\(reward.cost) Tokens")
//                        .font(.subheadline)
//                        .foregroundColor(.orange)
//                }
//                Spacer()
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//        }
//    }
//}
//
//enum RewardCategory: String, CaseIterable, Codable {
//    case all = "All"
//    case fitness = "Fitness"
//    case apparel = "Apparel"
//    case equipment = "Equipment"
//    case memberships = "Memberships"
//}
//
//struct Reward: Identifiable, Codable, Hashable {
//    let id: String
//    let name: String
//    let description: String
//    let cost: Int
//    let category: RewardCategory
//    let imageName: String
//    let terms: String
//    let stock: Int
//}
