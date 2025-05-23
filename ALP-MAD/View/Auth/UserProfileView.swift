//
//  UserProfileView.swift
//  ALP-MAD
//
//  Created by student on 23/05/25.
//

import SwiftUI

import SwiftUI

struct UserProfileView: View {
    let user: DummyUser

    let hubOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    let hubBlack = Color.black
    let hubWhite = Color.white

    // Random followers & following count
    let followersCount = Int.random(in: 100...10_000)
    let followingCount = Int.random(in: 50...5_000)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    hubBlack
                        .frame(height: 200)
                        .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
                        .edgesIgnoringSafeArea(.top)

                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(hubOrange)
                                .frame(width: 100, height: 100)
                            Text(String(user.username.prefix(1)).uppercased())
                                .font(.largeTitle)
                                .foregroundColor(hubBlack)
                        }
                        .overlay(Circle().stroke(hubOrange, lineWidth: 4))
                        .offset(y: 20)
                    }
                }

                VStack(spacing: 8) {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(hubWhite)

                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Followers & Following
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(followersCount)")
                                .font(.headline)
                                .foregroundColor(hubWhite)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        VStack {
                            Text("\(followingCount)")
                                .font(.headline)
                                .foregroundColor(hubWhite)
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 4)

                    Text(user.bio)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hubWhite)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
                .padding(.top, -10)

                // Interests Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interests")
                        .font(.headline)
                        .foregroundColor(hubWhite)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(user.sports, id: \.self) { sport in
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(hubOrange.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text(sport)
                                            .foregroundColor(hubWhite)
                                            .bold()
                                            .multilineTextAlignment(.center)
                                            .padding(6)
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .background(hubBlack.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    UserProfileView(user: DummyUser.sampleUsers[0])
}
