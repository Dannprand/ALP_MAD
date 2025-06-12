//
//  GroupChatsView.swift
//  ALP-MAD
//
//  Created by student on 11/06/25.
//

import SwiftUI
import FirebaseFirestore

struct GroupChatsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @StateObject var eventViewModel = EventViewModel()
    
    @State private var chats: [ChatRoom] = []
    @State private var showingNewChatSheet = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                eventChatsSection
                communityChatsSection
            }
            .searchable(text: $searchText, prompt: "Search chats")
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewChatSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewChatSheet) {
                NewChatView()
            }
            .onAppear {
                loadUserChats()
            }
        }
    }

    // MARK: - Section Views

    @ViewBuilder
    private var eventChatsSection: some View {
        if !eventChats.isEmpty {
            Section(header: Text("Event Chats")) {
                ForEach(filteredEventChats) { chat in
                    let event = chat.event ?? Event.placeholder()
                    NavigationLink {
                        EventChatView(event: event)
                            .environmentObject(chatViewModel)
                    } label: {
                        ChatRow(chat: chat)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var communityChatsSection: some View {
        if !communityChats.isEmpty {
            Section(header: Text("Community Chats")) {
                ForEach(filteredCommunityChats) { chat in
                    NavigationLink {
                        CommunityChatView(chatRoom: chat)
                            .environmentObject(chatViewModel)
                    } label: {
                        ChatRow(chat: chat)
                    }
                }
            }
        }
    }

    // MARK: - Chat Filters

    private var filteredEventChats: [ChatRoom] {
        if searchText.isEmpty {
            return eventChats
        } else {
            return eventChats.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private var filteredCommunityChats: [ChatRoom] {
        if searchText.isEmpty {
            return communityChats
        } else {
            return communityChats.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private var eventChats: [ChatRoom] {
        chats.filter { $0.type == .event }
    }

    private var communityChats: [ChatRoom] {
        chats.filter { $0.type == .community }
    }

    // MARK: - Data Loading

    private func loadUserChats() {
        guard let userId = authViewModel.currentUser?.id else { return }

        eventViewModel.fetchUserEvents(userId: userId) { events in
            let eventChatRooms = events.map { event in
                ChatRoom(
                    id: event.id ?? UUID().uuidString,
                    title: event.title,
                    lastMessage: "",
                    timestamp: Date(),
                    type: .event,
                    event: event
                )
            }

            loadCommunityChats(userId: userId) { communityChatRooms in
                self.chats = eventChatRooms + communityChatRooms
            }
        }
    }

    private func loadCommunityChats(userId: String, completion: @escaping ([ChatRoom]) -> Void) {
        let db = Firestore.firestore()
        db.collection("communityChats")
            .whereField("participants", arrayContains: userId)
            .getDocuments { snapshot, error in
                var chats: [ChatRoom] = []

                if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        if let title = data["title"] as? String,
                           let lastMessage = data["lastMessage"] as? String,
                           let timestamp = data["timestamp"] as? Timestamp {

                            let chat = ChatRoom(
                                id: document.documentID,
                                title: title,
                                lastMessage: lastMessage,
                                timestamp: timestamp.dateValue(),
                                type: .community
                            )
                            chats.append(chat)
                        }
                    }
                }

                completion(chats)
            }
    }
}

// MARK: - ChatRow

struct ChatRow: View {
    let chat: ChatRoom

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: chat.type == .event ? "calendar" : "person.2.fill")
                .foregroundColor(Theme.accentOrange)
                .frame(width: 40, height: 40)
                .background(Theme.cardBackground)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.title)
                    .font(.headline)
                    .foregroundColor(Theme.primaryText)

                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            Text(chat.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundColor(Theme.secondaryText)
        }
        .padding(.vertical, 8)
    }
}
