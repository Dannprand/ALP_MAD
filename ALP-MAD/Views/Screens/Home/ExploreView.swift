//
//  ExploreVIew.swift
//  ALP-MAD
//
//  Created by student on 30/05/25.
//

import FirebaseFirestore
import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var allUsers: [User] = []
    @State private var filteredUsers: [User] = []

    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.secondaryText)
                TextField("Search users by name...", text: $searchText)
                    .foregroundColor(Theme.primaryText)
            }
            .padding()
            .background(Theme.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)

            // User List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredUsers, id: \.id) { user in
                        HStack(spacing: 16) {
                            // Profile Image
                            AsyncImage(
                                url: URL(string: user.profileImageUrl ?? "")
                            ) { image in
                                image.resizable()
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())

                            // User Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.headline)
                                    .foregroundColor(Theme.primaryText)

                                if let level = user.skillLevel {
                                    Text(level.rawValue.capitalized)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(skillBadgeColor(level))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Theme.accentOrange, lineWidth: 1)
                                .background(
                                    Theme.cardBackground.cornerRadius(16)
                                )
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                        .padding(.horizontal)
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Explore Friends")
        .onAppear(perform: fetchUsers)
        .onChange(of: searchText) { _ in
            filterUsers()
        }
        .background(Theme.background.ignoresSafeArea())
    }

    // MARK: - Helper Functions

    private func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            let users = documents.compactMap { User(document: $0) }
            self.allUsers = users
            self.filteredUsers = users
        }
    }

    private func filterUsers() {
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter {
                $0.fullname.lowercased().contains(searchText.lowercased())
            }
        }
    }

    private func skillBadgeColor(_ level: SkillLevel) -> Color {
        switch level {
        case .beginner:
            return .gray
        case .intermediate:
            return .blue
        case .advanced:
            return Theme.accentOrange
        @unknown default:
            return .gray
        }
    }

}
