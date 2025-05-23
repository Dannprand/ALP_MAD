//
//  ProfileView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
                                .foregroundColor(Theme.accentOrange.opacity(0.3))
                            
                            if let imageUrl = user.profileImageUrl, !imageUrl.isEmpty {
                                AsyncImage(url: URL(string: imageUrl)) { image in
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
                            
                            VStack {
                                Text("\(user.tokens)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.accentOrange)
                                Text("Tokens")
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
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(SecondaryButtonStyle())
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
                
                Divider()
                    .background(Theme.cardBackground)
                    .padding(.horizontal)
                
                // Hosted events
                if let hostedEvents = viewModel.hostedEvents, !hostedEvents.isEmpty {
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
                if let joinedEvents = viewModel.joinedEvents, !joinedEvents.isEmpty {
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
                .buttonStyle(SecondaryButtonStyle())
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
            await viewModel.fetchUserEvents(userId: authViewModel.currentUser?.id ?? "")
        }
    }
}

class ProfileViewModel: ObservableObject {
    @Published var hostedEvents: [Event]?
    @Published var joinedEvents: [Event]?
    
    func fetchUserEvents(userId: String) async {
        let db = Firestore.firestore()
        
        do {
            // Fetch hosted events
            let hostedSnapshot = try await db.collection("events")
                .whereField("hostId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .limit(to: 5)
                .getDocuments()
            
            hostedEvents = try hostedSnapshot.documents.compactMap { document in
                try document.data(as: Event.self)
            }
            
            // Fetch joined events
            let joinedSnapshot = try await db.collection("events")
                .whereField("participants", arrayContains: userId)
                .whereField("hostId", isNotEqualTo: userId) // Exclude hosted events
                .order(by: "date", descending: true)
                .limit(to: 5)
                .getDocuments()
            
            joinedEvents = try joinedSnapshot.documents.compactMap { document in
                try document.data(as: Event.self)
            }
        } catch {
            print("Error fetching user events: \(error)")
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile image
                    ZStack {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        } else if let imageUrl = authViewModel.currentUser?.profileImageUrl, !imageUrl.isEmpty {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .frame(width: 150, height: 150)
                                .foregroundColor(Theme.accentOrange.opacity(0.3))
                                .overlay(
                                    Text(authViewModel.currentUser?.initials ?? "")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.accentOrange)
                                )
                        }
                        
                        Button(action: { isShowingImagePicker = true }) {
                            Image(systemName: "camera.fill")
                                .padding(12)
                                .background(Theme.accentOrange)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .offset(x: 50, y: 50)
                    }
                    .frame(height: 150)
                    .padding(.top, 20)
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(selectedImage: $selectedImage)
                    }
                    
                    // Form fields
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.headline)
                            .foregroundColor(Theme.primaryText)
                        
                        TextField("Enter your name", text: $fullname)
                            .textFieldStyle(SportHubTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Save Changes")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(fullname.isEmpty || isSaving)
                    .padding()
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
        guard let userId = authViewModel.currentUser?.id else { return }
        
        isSaving = true
        
        // In a real app, you would:
        // 1. Upload image to storage if selected
        // 2. Update user document with new data
        // 3. Update local user object
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSaving = false
            dismiss()
        }
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
                notificationEnabled = authViewModel.currentUser?.notificationEnabled ?? true
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
    }
}
