//
//  EventChatView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseFirestore

struct EventChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    
    let event: Event
    @State private var messageText = ""
    @State private var showParticipants = false
    
    var body: some View {
        VStack {
            // Chat header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Theme.accentOrange)
                }
                
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(event.participants.count) participants")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
                
                Spacer()
                
                Button(action: { showParticipants = true }) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(Theme.accentOrange)
                }
            }
            .padding()
            .background(Theme.cardBackground)
            
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(chatViewModel.messages) { message in
                            ChatBubble(
                                message: message,
                                isCurrentUser: message.senderId == authViewModel.currentUser?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatViewModel.messages) { _ in
                    if let lastMessage = chatViewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastMessage = chatViewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            // Message input
            HStack {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(ChatTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.headline)
                        .foregroundColor(messageText.isEmpty ? Theme.secondaryText : Theme.accentOrange)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            chatViewModel.setupChat(forEvent: event.id ?? "")
        }
        .sheet(isPresented: $showParticipants) {
            ParticipantsView(participantIds: event.participants)
        }
    }
    
    private func sendMessage() {
        guard let userId = authViewModel.currentUser?.id,
              let userName = authViewModel.currentUser?.fullname else { return }
        
        let message = ChatMessage(
            id: UUID().uuidString,
            senderId: userId,
            senderName: userName,
            text: messageText,
            timestamp: Timestamp(),
            eventId: event.id ?? ""
        )
        
        chatViewModel.sendMessage(message)
        messageText = ""
    }
}

struct ChatTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Theme.cardBackground)
            .cornerRadius(20)
            .foregroundColor(Theme.primaryText)
    }
}

struct ParticipantsView: View {
    @State private var participants: [User] = []
    let participantIds: [String]
    
    var body: some View {
        NavigationStack {
            List(participants) { user in
                HStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Theme.accentOrange.opacity(0.3))
                        .overlay(
                            Text(user.initials)
                                .font(.subheadline)
                                .foregroundColor(Theme.accentOrange)
                        )
                    
                    Text(user.fullname)
                        .font(.subheadline)
                        .foregroundColor(Theme.primaryText)
                    
                    Spacer()
                    
                    if user.id == participantIds.first { // First participant is host
                        Text("Host")
                            .font(.caption)
                            .padding(4)
                            .background(Theme.accentOrange.opacity(0.2))
                            .foregroundColor(Theme.accentOrange)
                            .cornerRadius(4)
                    }
                }
            }
            .listStyle(.plain)
            .background(Theme.background)
            .navigationTitle("Participants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(participants.count)/\(participantIds.count)")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .task {
                await fetchParticipants()
            }
        }
    }
    
    private func fetchParticipants() async {
        let db = Firestore.firestore()
        do {
            var fetchedParticipants: [User] = []
            
            for id in participantIds {
                let snapshot = try await db.collection("users").document(id).getDocument()
                if let user = try? snapshot.data(as: User.self) {
                    fetchedParticipants.append(user)
                }
            }
            
            participants = fetchedParticipants
        } catch {
            print("Error fetching participants: \(error)")
        }
    }
}
