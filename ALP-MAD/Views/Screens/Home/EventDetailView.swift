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

                                gradient: Gradient(colors: [
                                    .clear, .black.opacity(0.7),
                                ]),

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
                
                // Event description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About the Event")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(.horizontal)
                
                // Location map
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    Map(coordinateRegion: $region, annotationItems: [event]) { event in
                        MapAnnotation(coordinate: event.location.coordinate) {
                            MapPin()
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.accentOrange.opacity(0.3), lineWidth: 1)
                    )
                    
                    Text(event.location.name)
                        .font(.subheadline)
                        .foregroundColor(Theme.primaryText)
                    
                    Text(event.location.address)
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(.horizontal)
                
                // Tournament details if applicable
                if event.isTournament {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tournament Details")
                            .font(.headline)
                            .foregroundColor(Theme.primaryText)
                        
                        if let prize = event.prizePool {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(Theme.accentOrange)
                                Text("Prize Pool: \(prize)")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.secondaryText)
                            }
                        }
                        
                        if let rules = event.rules {
                            Text("Rules: \(rules)")
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                        }
                        
                        if let requirements = event.requirements {
                            Text("Requirements: \(requirements)")
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Join button
                if !isUserParticipating {
                    Button(action: joinEvent) {
                        if isJoining {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(event.isFull ? "Event Full" : "Join Event")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(event.isFull || isJoining)
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Text("You're participating in this event")
                            .font(.subheadline)
                            .foregroundColor(Theme.accentOrange)
                        
                        Button(action: { showChat = true }) {
                            Text("Open Event Chat")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .padding(.vertical)
            
            // MARK: Host-only End Event button
            // In EventDetailView.swift
            // In EventDetailView.swift - replace the current "End Event" button section with this:
            if isCurrentUserHost && !localEvent.isEnded {
                Button(action: {
                    showEndEventConfirmation = true
                }) {
                    Text("End Event")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                        .padding()
                }
                .confirmationDialog(
                    "End Event",
                    isPresented: $showEndEventConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("End Event", role: .destructive) {
                        eventViewModel.endEvent(event: localEvent) { result in
                            switch result {
                            case .success():
                                print("Event successfully ended")
                                // Update local state to reflect the event has ended
                                localEvent.isEnded = true
                            case .failure(let error):
                                print("Error ending event: \(error)")
                                // You might want to show an error alert here
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to end this event? This cannot be undone.")
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: isCurrentUserHost)
            }
//            if isCurrentUserHost && !localEvent.isEnded {
//                Button(action: {
//                    eventViewModel.endEvent(event: localEvent) { result in
//                        switch result {
//                        case .success():
//                            print("Event successfully ended")
//                            // You might want to dismiss the view or show a confirmation
//                        case .failure(let error):
//                            print("Error ending event: \(error)")
//                            // Show error to user
//                        }
//                    }
//                }) {
////                    showEndEventConfirmation = true
//                    Text("End Event")
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.red)
//                        .cornerRadius(12)
//                        .padding()
//                }
////                .confirmationDialog("End Event", isPresented: $showEndEventConfirmation) {
////                        Button("End Event", role: .destructive) {
////                            eventViewModel.endEvent(event: localEvent) { result in
////                                // handle result
////                            }
////                        }
////                        Button("Cancel", role: .cancel) {}
////                    } message: {
////                        Text("Are you sure you want to end this event? This cannot be undone.")
////                    }
//                .transition(.move(edge: .bottom))
//                .animation(.easeInOut, value: isCurrentUserHost)
//            }
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
//            if let userId = authViewModel.currentUser?.id {
//                if userId == event.hostId || event.participants.contains(userId) {
//                    isUserParticipating = true
//                }
//            }
        }
    }
    
    func checkUserParticipation() {
            if let userId = authViewModel.currentUser?.id {
                isUserParticipating = localEvent.participants.contains(userId) || localEvent.hostId == userId
            }
        }
    
    func joinEvent() {
        guard let userId = authViewModel.currentUser?.id,
              let eventId = localEvent.id else { return }
        
        isJoining = true
        
        Task {
            let eventRef = db.collection("events").document(eventId)
            let userRef = db.collection("users").document(userId)
            
            do {
                try await db.runTransaction { transaction, errorPointer in
                    let eventDocument: DocumentSnapshot
                    do {
                        eventDocument = try transaction.getDocument(eventRef)
                    } catch {
                        errorPointer?.pointee = error as NSError
                        return nil
                    }
                    
                    guard var participants = eventDocument.data()?["participants"] as? [String] else {
                        return nil
                    }
                    
                    if !participants.contains(userId) {
                        participants.append(userId)
                        transaction.updateData(["participants": participants], forDocument: eventRef)
                    }
                    
                    return nil
                }
                
                // Tambahkan eventId ke joinedEvents user
                try await userRef.updateData([
                    "joinedEvents": FieldValue.arrayUnion([eventId])
                ])
                
                // Update lokal state
                isUserParticipating = true
                localEvent.participants.append(userId)
                
            } catch {
                print("Error joining event: \(error)")
            }
            
            isJoining = false
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


    
    

