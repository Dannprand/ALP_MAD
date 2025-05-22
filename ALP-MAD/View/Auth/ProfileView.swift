//
//  ProfileView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var username = DummyUser.sampleUser.username
    @State private var email = DummyUser.sampleUser.email
    @State private var bio = DummyUser.sampleUser.bio
    @State private var showEditProfile = false

    // Custom Colors
    let hubOrange = Color(red: 1.0, green: 0.6, blue: 0.0) // #FF9900
    let hubBlack = Color.black
    let hubWhite = Color.white

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
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
                                Text(String(username.prefix(1)).uppercased())
                                    .font(.largeTitle)
                                    .foregroundColor(hubBlack)
                            }
                            .overlay(Circle().stroke(hubOrange, lineWidth: 4))
                            .offset(y: 20)
                        }
                    }

                    VStack(spacing: 8) {
                        Text(username)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(hubWhite)

                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(bio)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(hubWhite)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .padding(.top, -10)

                    // Buttons
                    HStack(spacing: 20) {
                        Button(action: { print("Follow tapped") }) {
                            Text("Follow")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(hubOrange)
                                .foregroundColor(hubBlack)
                                .cornerRadius(10)
                        }

                        Button(action: { print("Message tapped") }) {
                            Text("Message")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(hubOrange)
                                .foregroundColor(hubBlack)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    // Stats
                    HStack(spacing: 30) {
                        StatisticView(label: "FOLLOWERS", value: "15K", color: hubWhite)
                        StatisticView(label: "FOLLOWING", value: "23K", color: hubWhite)
                    }
                    .padding(.vertical)

                    // Interests
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Interests")
                            .font(.headline)
                            .foregroundColor(hubWhite)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(DummyUser.sampleUser.sports, id: \.self) { sport in
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

                    Spacer()
                }
            }
            .background(hubBlack.edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Profile")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditProfile = true
                    }
                    .foregroundColor(hubOrange)
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(username: $username, email: $email, bio: $bio)
            }
        }
    }
}

struct StatisticView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(color)

            Text(label)
                .font(.caption)
                .foregroundColor(color.opacity(0.7))
        }
    }
}

#Preview {
    ProfileView()
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


#Preview {
    ProfileView()
}
