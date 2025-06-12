//
//  CommunityChatView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseFirestore

struct CommunityChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    
    let chatRoom: ChatRoom
    @State private var messageText = ""
    @State private var showParticipants = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Theme.accentOrange)
                }
                
                VStack(alignment: .leading) {
                    Text(chatRoom.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text("Community Chat")
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
                    scrollToBottom(proxy: proxy)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
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
            chatViewModel.setupCommunityChat(chatId: chatRoom.id)
        }
        .sheet(isPresented: $showParticipants) {
            // ParticipantsView(participants: getParticipants())
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = chatViewModel.messages.last else { return }
        withAnimation {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
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
            eventId: chatRoom.id // Using chatRoom.id as the "eventId" for community chats
        )
        
        chatViewModel.sendMessage(message)
        messageText = ""
        
        // Update last message in chat room
        updateLastMessage(message: messageText)
    }
    
    private func updateLastMessage(message: String) {
        let db = Firestore.firestore()
        db.collection("communityChats").document(chatRoom.id).updateData([
            "lastMessage": message,
            "lastMessageTimestamp": Timestamp()
        ])
    }
}
