//
//  FriendListView.swift
//  ALP-MAD
//
//  Created by student on 23/05/25.
//

import SwiftUI
struct FriendListView: View {
    let title: String
    let friends: [Friend]
    
    let hubBlack = Color.black
    let hubWhite = Color.white
    let hubOrange = Color(red: 1.0, green: 0.6, blue: 0.0)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(friends) { friend in
                    HStack(spacing: 16) {
                        Circle()
                            .fill(randomColor(for: friend.name))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(friend.name.prefix(1)).uppercased())
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(hubBlack)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(friend.name)
                                .font(.headline)
                                .foregroundColor(hubWhite)
                            // Email dihapus, jadi tidak ditampilkan
                            // Text(friend.email)
                            //     .font(.subheadline)
                            //     .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .background(hubBlack.edgesIgnoringSafeArea(.all))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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
    FriendListView(
        title: "Followers",
        friends: [
            Friend(name: "Alice", email: "alice@example.com"),
            Friend(name: "Bob", email: "bob@example.com"),
            Friend(name: "Cathy", email: "cathy@example.com")
        ]
    )
}

