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
    
    // Extracted header view for better type-checking
    private var headerView: some View {
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
    }
    
    // Extracted message input view
    private var messageInputView: some View {
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
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
//                        ForEach(chatViewModel.messages) { message in
//                            ChatBubble(
//                                message: message,
//                                isCurrentUser: message.senderId == authViewModel.currentUser?.id
//                            )
//                            .id(message.id)
//                        }
                        ForEach(chatViewModel.messages) { message in
                            chatBubble(for: message)
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
            
            messageInputView
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            chatViewModel.setupChat(forEvent: event.id ?? "")
        }
        .sheet(isPresented: $showParticipants) {
           // MARK: - ParticipantView
//            ParticipantsView(participantIds: event.participants)
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
            eventId: event.id ?? ""
        )
        
        chatViewModel.sendMessage(message)
        messageText = ""
    }
    
//    private func chatBubble(for message: ChatMessage) -> some View {
//        let isCurrentUser = message.senderId == authViewModel.currentUser?.id
//        return ChatBubble(
//            message: message,
//            isCurrentUser: isCurrentUser
//        )
//        .id(message.id)
//    }
    
    private func chatBubble(for message: ChatMessage) -> some View {
        let isCurrentUser = message.senderId == authViewModel.currentUser?.id
        return ChatBubble(
            message: message,
            isCurrentUser: isCurrentUser
        )
        .id(message.id as String)
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

