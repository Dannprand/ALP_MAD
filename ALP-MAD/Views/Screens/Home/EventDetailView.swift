import SwiftUI
import MapKit

struct EventDetailView: View {
    @ObservedObject var viewModel: EventViewModel
    @State private var region: MKCoordinateRegion
    @State private var showDeleteConfirmation = false
    let event: Event
    
    init(viewModel: EventViewModel, event: Event) {
        self.viewModel = viewModel
        self.event = event
        self._region = State(initialValue: MKCoordinateRegion(
            center: event.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event Image
                ZStack(alignment: .topTrailing) {
                    Image(event.sport.rawValue.lowercased())
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                    
                    if event.isExpired {
                        Color.black.opacity(0.5)
                        Text("Expired")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    } else if event.isFeatured {
                        Text("Featured")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Theme.accentOrange)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                
                // Event Info
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if event.hostId == viewModel.authService.currentUser?.uid {
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .confirmationDialog("Delete Event", isPresented: $showDeleteConfirmation) {
                                Button("Delete", role: .destructive) {
                                    Task {
                                        await viewModel.deleteEvent(event)
                                    }
                                }
                            }
                        }
                    }
                    
                    Text(event.description)
                        .font(.body)
                    
                    Divider()
                    
                    // Date and Time
                    VStack(alignment: .leading, spacing: 5) {
                        Label("Event Date", systemImage: "calendar")
                            .font(.headline)
                        
                        Text(event.date.dateValue().formatted(date: .complete, time: .shortened))
                        
                        if !event.isExpired {
                            Label("Expires \(event.expiryStatus)", systemImage: "clock.badge.exclamationmark")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Divider()
                    
                    // Location
                    VStack(alignment: .leading, spacing: 5) {
                        Label("Location", systemImage: "mappin.and.ellipse")
                            .font(.headline)
                        
                        Text(event.location.name)
                        Text(event.location.address)
                        
                        Map(coordinateRegion: $region, annotationItems: [event.location]) { location in
                            MapMarker(coordinate: location.coordinate)
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                    }
                    
                    Divider()
                    
                    // Participants
                    VStack(alignment: .leading, spacing: 5) {
                        Label("Participants (\(event.participants.count)/\(event.maxParticipants))", systemImage: "person.2.fill")
                            .font(.headline)
                        
                        if event.isFull {
                            Text("Event is full")
                                .foregroundColor(.red)
                        } else if event.isExpired {
                            Text("Event has expired")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if event.isTournament, let prizePool = event.prizePool {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Label("Prize Pool", systemImage: "trophy.fill")
                                .font(.headline)
                            
                            Text(prizePool)
                        }
                    }
                    
                    if let rules = event.rules {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Label("Rules", systemImage: "list.bullet.rectangle")
                                .font(.headline)
                            
                            Text(rules)
                        }
                    }
                    
                    if let requirements = event.requirements {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Label("Requirements", systemImage: "checklist")
                                .font(.headline)
                            
                            Text(requirements)
                        }
                    }
                }
                .padding()
                
                // Action Buttons
                if !event.isExpired {
                    VStack {
                        if event.participants.contains(viewModel.authService.currentUser?.uid ?? "") {
                            Button("Leave Event") {
                                Task {
                                    await viewModel.leaveEvent(event)
                                }
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .tint(.red)
                        } else if !event.isFull {
                            Button("Join Event") {
                                Task {
                                    await viewModel.joinEvent(event)
                                }
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .tint(Theme.accentOrange)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
