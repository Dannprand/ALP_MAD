//
//  ProfileView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                VStack(spacing: 16) {
                    if let user = authViewModel.currentUser {
                        // Profile image
                        ZStack {
                            Circle()
                                .frame(width: 120, height: 120)
                                .foregroundColor(
                                    Theme.accentOrange.opacity(0.3)
                                )

                            if let imageUrl = user.profileImageUrl,
                               let url = URL(string: imageUrl),
                               url.scheme?.hasPrefix("http") == true {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                            } else {
                                Text(user.initials)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.accentOrange)
                            }

//                            if let imageUrl = user.profileImageUrl,
//                                !imageUrl.isEmpty
//                            {
//                                AsyncImage(url: URL(string: imageUrl)) {
//                                    image in
//                                    image.resizable()
//                                } placeholder: {
//                                    ProgressView()
//                                }
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 120, height: 120)
//                                .clipShape(Circle())
//                            } else {
//                                Text(user.initials)
//                                    .font(.title)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(Theme.accentOrange)
//                            }
                        }

                        // Name and email
                        VStack(spacing: 4) {
                            Text(user.fullname)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.primaryText)

                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                        }

                        // Stats
                        HStack(spacing: 24) {
                            VStack {
                                Text("\(user.joinedEvents.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.accentOrange)
                                Text("Events")
                                    .font(.caption)
                                    .foregroundColor(Theme.secondaryText)
                            }

                            VStack {
                                Text("\(user.hostedEvents.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.accentOrange)
                                Text("Hosted")
                                    .font(.caption)
                                    .foregroundColor(Theme.secondaryText)
                            }

                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.top, 40)

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: { showEditProfile = true }) {
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity)
                    }
//                    .buttonStyle(SecondaryButtonStyle())

                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .frame(width: 20, height: 20)
                    }
//                    .buttonStyle(SecondaryButtonStyle())
                    .frame(width: 50)
                }
                .padding(.horizontal)

                Divider()
                    .background(Theme.cardBackground)
                    .padding(.horizontal)

                // Preferences
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Preferences")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                        .padding(.horizontal)
                    
                    // show Skill Level
                    if let skillLevels = authViewModel.currentUser?.skillLevel {
                        Text(skillLevels.map { $0.rawValue }.joined(separator: ", "))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }



                    if let preferences = authViewModel.currentUser?.preferences,
                        !preferences.isEmpty
                    {
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
                                            .stroke(
                                                Theme.accentOrange,
                                                lineWidth: 1
                                            )
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

                Divider()
                    .background(Theme.cardBackground)
                    .padding(.horizontal)

                // Hosted events
                if let hostedEvents = viewModel.hostedEvents,
                    !hostedEvents.isEmpty
                {
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
                }

                // Joined events
                if let joinedEvents = viewModel.joinedEvents,
                    !joinedEvents.isEmpty
                {
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
                }

                Spacer()

                // Sign out button
                Button(action: authViewModel.signOut) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                }
//                .buttonStyle(SecondaryButtonStyle())
                .padding()
            }
            .padding(.bottom)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .task {
            await viewModel.fetchUserEvents(
                userId: authViewModel.currentUser?.id ?? ""
            )
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var fullname = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 30) {
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                            } else if let imageUrl = authViewModel.currentUser?.profileImageUrl,
                                      let imageData = Data(base64Encoded: imageUrl),
                                      let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Theme.accentOrange.opacity(0.3))
                                    .frame(width: 140, height: 140)
                                    .overlay(
                                        Text(authViewModel.currentUser?.initials ?? "")
                                            .font(.largeTitle.bold())
                                            .foregroundColor(Theme.accentOrangeDark)
                                    )
                            }

                            Button(action: {
                                isShowingImagePicker = true
                            }) {
                                Image(systemName: "camera.fill")
                                    .font(.body)
                                    .padding(10)
                                    .background(Theme.accentOrangeDark)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            .offset(x: 50, y: 50)
                        }
                        .padding(.top, 32)
                        .sheet(isPresented: $isShowingImagePicker) {
                            ImagePicker(selectedImage: $selectedImage)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.headline)
                                .foregroundColor(Theme.primaryText)

                            TextField("Enter your name", text: $fullname)
                                .textFieldStyle(SportHubTextFieldStyle())
                        }
                        .padding(.horizontal)
                        Button(action: saveProfile) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                            }
                        }
//                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(fullname.isEmpty || isSaving)
                        .padding(.top, 20)
                        .padding(.horizontal)

                        Spacer()
                    }
                }
                .background(Theme.background.ignoresSafeArea())
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(Theme.accentOrange)
                    }
                }
                .onAppear {
                    fullname = authViewModel.currentUser?.fullname ?? ""
                }
            }
        }

        private func saveProfile() {
            guard !fullname.isEmpty else { return }

            isSaving = true
            errorMessage = nil

            Task {
                do {
                    try await authViewModel.updateProfile(fullname: fullname, image: selectedImage)
                    isSaving = false
                    dismiss()
                } catch {
                    isSaving = false
                    errorMessage = "Failed to update profile: \(error.localizedDescription)"
                }
            }
        }
}

extension UIImage {
    func resized(to width: CGFloat) -> UIImage? {
        let scale = width / self.size.width
        let height = self.size.height * scale
        let newSize = CGSize(width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.7)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func toBase64() -> String? {
        guard let resized = self.resized(to: 300), // resize to 300pt width
              let imageData = resized.jpegData(compressionQuality: 0.5) else { return nil }
        return imageData.base64EncodedString()
    }
}


struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var notificationEnabled = true
    @State private var darkModeEnabled = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Enable Notifications", isOn: $notificationEnabled)
                        .tint(Theme.accentOrange)

                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .tint(Theme.accentOrange)
                } header: {
                    Text("Preferences")
                }

                Section {
                    NavigationLink {
                        Text("Privacy Policy")
                    } label: {
                        Text("Privacy Policy")
                    }

                    NavigationLink {
                        Text("Terms of Service")
                    } label: {
                        Text("Terms of Service")
                    }

                    NavigationLink {
                        Text("Help & Support")
                    } label: {
                        Text("Help & Support")
                    }
                } header: {
                    Text("About")
                }

                Section {
                    Button(role: .destructive) {
                        authViewModel.signOut()
                        dismiss()
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(Theme.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.accentOrange)
                }
            }
            .onAppear {
                notificationEnabled =
                    authViewModel.currentUser?.notificationEnabled ?? true
            }
        }
    }
}

