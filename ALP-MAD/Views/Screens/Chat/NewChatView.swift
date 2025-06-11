//
//  NewChatView.swift
//  ALP-MAD
//
//  Created by student on 11/06/25.
//

import SwiftUI
import FirebaseFirestore

struct NewChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var chatTitle = ""
    @State private var selectedUsers: [User] = []
    @State private var searchText = ""
    @State private var allUsers: [User] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Chat Details")) {
                    TextField("Chat Title", text: $chatTitle)
                }
                
                Section(header: Text("Add Participants")) {
                    TextField("Search users", text: $searchText)
                    
                    ForEach(filteredUsers) { user in
                        HStack {
                            Text(user.fullname)
                            Spacer()
                            if selectedUsers.contains(where: { $0.id == user.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.accentOrange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleUserSelection(user)
                        }
                    }
                }
            }
            .navigationTitle("New Chat")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createCommunityChat()
                    }
                    .disabled(chatTitle.isEmpty || selectedUsers.isEmpty)
                }
            }
            .onAppear {
                fetchAllUsers()
            }
        }
    }
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return allUsers
        } else {
            return allUsers.filter { $0.fullname.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func toggleUserSelection(_ user: User) {
        if let index = selectedUsers.firstIndex(where: { $0.id == user.id }) {
            selectedUsers.remove(at: index)
        } else {
            selectedUsers.append(user)
        }
    }
    
    private func fetchAllUsers() {
        // Implement fetching all users from Firestore
        // This is a placeholder - you'll need to implement the actual Firestore query
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                self.allUsers = documents.compactMap { document in
                    try? document.data(as: User.self)
                }
            }
        }
    }
    
    private func createCommunityChat() {
        guard let currentUserId = authViewModel.currentUser?.id else { return }
        
        let db = Firestore.firestore()
        let chatRef = db.collection("communityChats").document()
        
        let participantIds = selectedUsers.map { $0.id } + [currentUserId]
        
        let chatData: [String: Any] = [
            "title": chatTitle,
            "participants": participantIds,
            "createdBy": currentUserId,
            "createdAt": Timestamp(),
            "lastMessage": "",
            "lastMessageTimestamp": Timestamp()
        ]
        
        chatRef.setData(chatData) { error in
            if let error = error {
                print("Error creating chat: \(error.localizedDescription)")
            } else {
                dismiss()
            }
        }
    }
}
