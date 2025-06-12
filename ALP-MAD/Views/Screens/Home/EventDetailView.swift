//

//  EventDetailView.swift

//  ALP-MAD

//

//  Created by student on 22/05/25.

//

import FirebaseAuth
import FirebaseFirestore
import MapKit
import SwiftUI

struct EventDetailView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @ObservedObject var eventViewModel: EventViewModel
    
    @StateObject var chatViewModel = ChatViewModel()
    @Environment(\.dismiss) var dismiss
    
    let event: Event
    
    @State private var region: MKCoordinateRegion
    
    @State private var isJoining = false
    
    @State private var showChat = false
    
    @State private var isUserParticipating = false
    
    @State private var localEvent: Event
    
    @State private var isCurrentUserHost: Bool = false
    @State private var showEndEventConfirmation = false
    
    //    @State private var hostName: String = "Loading..."
    
    private let db = Firestore.firestore()
    
    init(event: Event) {
        
        self.event = event
        
        self._eventViewModel = ObservedObject(wrappedValue: EventViewModel())
        
        self._localEvent = State(initialValue: event)
        
        self._isUserParticipating = State(initialValue: false)
        
        let center = CLLocationCoordinate2D(
            
            latitude: event.location.latitude,
            
            longitude: event.location.longitude
            
        )
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        self._region = State(
            initialValue: MKCoordinateRegion(center: center, span: span)
        )
        
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event image and basic info
                VStack(alignment: .leading, spacing: 8) {
                    Image(event.sport.rawValue.lowercased())
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Text(event.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                            }
                        )
                    
                    HStack(spacing: 16) {
                        EventDetailPill(
                            icon: "calendar",
                            text: event.date.dateValue().formatted(
                                date: .abbreviated,
                                time: .omitted
                            )
                        )
                        
                        HStack(spacing: 16) {
                            EventDetailPill(icon: "calendar", text: event.date.dateValue().formatted(date: .abbreviated, time: .omitted))
                            EventDetailPill(icon: "clock", text: event.date.dateValue().formatted(date: .omitted, time: .shortened))
                            EventDetailPill(icon: "person.2.fill", text: "\(event.participants.count)/\(event.maxParticipants)")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Host section
                    HStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Theme.accentOrange.opacity(0.3))
                            .overlay(
                                Text(authViewModel.currentUser?.initials ?? "H")
                                    .font(.headline)
                                    .foregroundColor(Theme.accentOrange)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Hosted by")
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                            Text("Host Name") // Would fetch from user data in real app
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.primaryText)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Theme.cardBackground)
                        .padding(.horizontal)
                    
                    // Rest of your view content...
                    // Make sure all other components are properly nested
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showChat) {
                NavigationStack {
                    EventChatView(event: event)
                        .environmentObject(chatViewModel)
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    isUserParticipating = event.participants.contains(userId) || userId == event.hostId
                    isCurrentUserHost = userId == event.hostId
                }
                localEvent = event
            }
        }
    }
    
    struct EventDetailPill: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(text)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Theme.cardBackground)
            .cornerRadius(20)
        }
    }
    
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.accentOrange)
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(10)
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.cardBackground)
                .foregroundColor(Theme.accentOrange)
                .font(.headline)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.accentOrange, lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    //func migrateOldEventsToAddIsEnded() {
    //    let db = Firestore.firestore()
    //    db.collection("events").getDocuments { snapshot, error in
    //        guard let documents = snapshot?.documents, error == nil else {
    //            print("Error fetching events: \(error?.localizedDescription ?? "Unknown error")")
    //            return
    //        }
    //
    //        for doc in documents {
    //            if doc.data()["isEnded"] == nil {
    //                db.collection("events").document(doc.documentID).updateData([
    //                    "isEnded": false
    //                ]) { err in
    //                    if let err = err {
    //                        print("Failed to update event \(doc.documentID): \(err)")
    //                    } else {
    //                        print("Updated event \(doc.documentID) with isEnded = false")
    //                    }
    //                }
    //            }
    //        }
    //    }
    //}
    
}



