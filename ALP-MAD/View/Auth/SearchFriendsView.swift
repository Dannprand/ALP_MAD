//
//  SearchAndFeedView.swift
//  ALP-MAD
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct SearchFriendsView: View {
    @State private var searchText = ""
    @State private var addedFriends: Set<String> = []
    @State private var selectedUser: DummyUser? = nil
    @State private var showProfile = false

    let hubBlack = Color.black
    let hubWhite = Color.white
    let hubOrange = Color(red: 1.0, green: 0.6, blue: 0.0)

    var filteredFriends: [DummyUser] {
        if searchText.isEmpty {
            return DummyUser.sampleUsers
        } else {
            return DummyUser.sampleUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search friends...", text: $searchText)
                        .foregroundColor(hubWhite)
                }
                .padding()
                .background(hubBlack.opacity(0.8))
                .cornerRadius(12)
                .padding()

                // Friend List
                List(filteredFriends, id: \.email) { user in
                    HStack {
                        // Avatar
                        Circle()
                            .fill(randomColor(for: user.username))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(user.username.prefix(1)).uppercased())
                                    .font(.headline)
                                    .foregroundColor(hubBlack)
                            )

                        // Username + Email + Followers info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.username)
                                .foregroundColor(hubWhite)
                                .font(.headline)

    

                            Text("\(Int.random(in: 100...10_000)) followers • \(Int.random(in: 50...5_000)) following")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }

                        Spacer()

                        // View Profile button
                        Button("View Profile") {
                            selectedUser = user
                            showProfile = true
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(hubOrange)
                        .foregroundColor(hubBlack)
                        .cornerRadius(10)
                        .buttonStyle(PlainButtonStyle()) // important!

                        // Add Friend button
                        Button(action: {
                            if !addedFriends.contains(user.email) {
                                addedFriends.insert(user.email)
                            }
                        }) {
                            Image(systemName: addedFriends.contains(user.email) ? "checkmark" : "person.badge.plus")
                                .foregroundColor(hubOrange)
                        }
                        .padding(.leading, 8)
                        .buttonStyle(PlainButtonStyle()) // important!
                    }
                    .listRowBackground(hubBlack)
                    .contentShape(Rectangle()) // supaya tap di luar button tidak aktif
                    // Hapus onTapGesture atau navigasi row secara keseluruhan
                }
                .listStyle(PlainListStyle())

                // NavigationLink untuk buka profil
                NavigationLink(isActive: $showProfile) {
                    if let user = selectedUser {
                        UserProfileView(user: user)
                    } else {
                        EmptyView()
                    }
                } label: {
                    EmptyView()
                }
            }
            .background(hubBlack.edgesIgnoringSafeArea(.all))
        }
    }

    private func randomColor(for name: String) -> Color {
        let hash = abs(name.hashValue)
        let r = Double((hash >> 8) & 0xFF) / 255.0
        let g = Double((hash >> 4) & 0xFF) / 255.0
        let b = Double((hash >> 0) & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}

#Preview {
    SearchFriendsView()
}
