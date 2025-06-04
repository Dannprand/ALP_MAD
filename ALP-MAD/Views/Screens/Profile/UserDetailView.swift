//
//  UserDetailView.swift
//  ALP-MAD
//
//  Created by student on 03/06/25.
//

import SwiftUI
import FirebaseFirestore

struct UserDetailView: View {
    let user: User
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = UserDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Foto profil dan nama lengkap
                if let urlString = user.profileImageUrl,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Text(user.initials)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        )
                }

                Text(user.fullname)
                    .font(.title)
                    .fontWeight(.bold)

                // Statistik Followers dan Following
                HStack(spacing: 40) {
                    VStack {
                        Text("\(viewModel.followersCount)")
                            .font(.headline)
                        Text("Followers")
                            .font(.subheadline)
                    }
                    VStack {
                        Text("\(viewModel.followingCount)")
                            .font(.headline)
                        Text("Following")
                            .font(.subheadline)
                    }
                }

                // Tombol Follow/Unfollow
                if user.id != authViewModel.currentUser?.id {
                    Button(action: {
                        viewModel.toggleFollow(userId: user.id)
                    }) {
                        Text(viewModel.isFollowing ? "Unfollow" : "Follow")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isFollowing ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }

                // Preferensi
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferences")
                        .font(.headline)
                    HStack {
                        Text("Skill Level:")
                            .fontWeight(.semibold)
                        Text(user.skillLevel)
                    }
                    HStack {
                        Text("Preferred Sport:")
                            .fontWeight(.semibold)
                        Text(user.selectedSport.rawValue)
                    }
                }
                .padding(.horizontal)

                // Daftar Event yang di-host
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hosted Events")
                        .font(.headline)
                    ForEach(viewModel.hostedEvents) { event in
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(event.date.dateValue(), style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear {
            viewModel.fetchUserStats(userId: user.id)
            viewModel.checkIfFollowing(userId: user.id)
            viewModel.fetchHostedEvents(userId: user.id)
        }
    }
}
