import SwiftUI
import MapKit
import CoreLocation

struct EventDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @StateObject var chatViewModel = ChatViewModel()
    
    let event: Event
    @State private var region: MKCoordinateRegion
    @State private var isJoining = false
    @State private var showChat = false
    @State private var isUserParticipating = false
    
    init(event: Event) {
        self.event = event
        let center = CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        self._region = State(initialValue: MKCoordinateRegion(center: center, span: span))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event image
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
                        EventDetailPill(icon: "calendar", text: event.date.dateValue().formatted(date: .abbreviated, time: .omitted))
                        EventDetailPill(icon: "clock", text: event.date.dateValue().formatted(date: .omitted, time: .shortened))
                        EventDetailPill(icon: "person.2.fill", text: "\(event.participants.count)/\(event.maxParticipants)")
                    }
                    .padding(.horizontal)
                }
                
                // Host info
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
                        Text("Host Name") // Replace with real data if needed
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
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About the Event")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(.horizontal)
                
                // Location
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
                
                // Tournament info
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
                
                // Join Button
                if !isUserParticipating {
                    Button(action: joinEvent) {
                        if isJoining {
                            ProgressView().tint(.white)
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
                isUserParticipating = event.participants.contains(userId)
            }
        }
    }
    
    private func joinEvent() {
        guard let userId = authViewModel.currentUser?.id else { return }
        isJoining = true
        Task {
            let success = await eventViewModel.joinEvent(event, userId: userId)
            if success {
                isUserParticipating = true
                showChat = true
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
        .background(Color(.systemGray5))
        .cornerRadius(20)
    }
}
