//
//  ProfileView.swift
//  ALP-MAD
//
//  Created by ChatGPT.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader

                HStack(spacing: 16) {
                    Button("Edit Profile") {
                        showEditProfile = true
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(width: 50)
                }
                .padding(.horizontal)

                Divider().padding(.horizontal)
                preferencesSection
                Divider().padding(.horizontal)
                hostedEventsSection
                joinedEventsSection

                Spacer()

                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding()
            }
            .padding(.bottom)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)

        // Placeholder sheets
        .sheet(isPresented: $showEditProfile) {
            Text("Edit Profile - Coming Soon")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showSettings) {
            Text("Settings - Coming Soon")
                .font(.title)
                .padding()
        }
        .task {
            await viewModel.fetchUserEvents(userId: authViewModel.currentUser?.id ?? "")
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            if let user = authViewModel.currentUser {
                ZStack {
                    Circle().frame(width: 120, height: 120).foregroundColor(Theme.accentOrange.opacity(0.3))
                    if let url = URL(string: user.profileImageUrl ?? ""), !user.profileImageUrl!.isEmpty {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    } else {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.accentOrange)
                    }
                }

                Text(user.fullname).font(.title2).fontWeight(.bold).foregroundColor(Theme.primaryText)
                Text(user.email).font(.subheadline).foregroundColor(Theme.secondaryText)

                HStack(spacing: 24) {
                    VStack {
                        Text("\(user.joinedEvents.count)")
                            .font(.title3).fontWeight(.bold).foregroundColor(Theme.accentOrange)
                        Text("Events").font(.caption).foregroundColor(Theme.secondaryText)
                    }
                    VStack {
                        Text("\(user.hostedEvents.count)")
                            .font(.title3).fontWeight(.bold).foregroundColor(Theme.accentOrange)
                        Text("Hosted").font(.caption).foregroundColor(Theme.secondaryText)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.top, 40)
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Preferences")
                .font(.headline)
                .foregroundColor(Theme.primaryText)
                .padding(.horizontal)

            if let level = authViewModel.currentUser?.skillLevel {
                Text(level.rawValue)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }

            if let preferences = authViewModel.currentUser?.preferences, !preferences.isEmpty {
                FlowLayout(spacing: 10) {
                    ForEach(preferences, id: \.self) { sport in
                        Text(sport.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.cardBackground)
                            .foregroundColor(Theme.primaryText)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Theme.accentOrange, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No preferences set")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
                    .padding(.horizontal)
            }

            NavigationLink {
                PreferencesView()
            } label: {
                Text("Update Preferences")
                    .font(.subheadline)
                    .foregroundColor(Theme.accentOrange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
        }
    }

    private var hostedEventsSection: some View {
        if let hostedEvents = viewModel.hostedEvents, !hostedEvents.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hosted Events")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(hostedEvents) { event in
                                NavigationLink {
                                    EventDetailView(event: event)
                                } label: {
                                    EventCard(event: event)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    private var joinedEventsSection: some View {
        if let joinedEvents = viewModel.joinedEvents, !joinedEvents.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    Text("Joined Events")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(joinedEvents) { event in
                                NavigationLink {
                                    EventDetailView(event: event)
                                } label: {
                                    EventCard(event: event)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}
