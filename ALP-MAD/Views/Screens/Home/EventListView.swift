import SwiftUI

struct EventListView: View {
    @EnvironmentObject var eventViewModel: EventViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Loading Indicator
                    if eventViewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading Events...")
                                .padding()
                            Spacer()
                        }
                    }

                    // Featured Events
                    if !eventViewModel.featuredEvents.isEmpty {
                        Text("Featured Events")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(eventViewModel.featuredEvents) { event in
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        EventCardView(event: event)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Nearby Events
                    if !eventViewModel.nearbyEvents.isEmpty {
                        Text("Nearby Events")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        VStack(spacing: 16) {
                            ForEach(eventViewModel.nearbyEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventRowView(event: event)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Popular Events
                    if !eventViewModel.popularEvents.isEmpty {
                        Text("Popular Events")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        VStack(spacing: 16) {
                            ForEach(eventViewModel.popularEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventRowView(event: event)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Empty state fallback
                    if !eventViewModel.isLoading &&
                        eventViewModel.featuredEvents.isEmpty &&
                        eventViewModel.nearbyEvents.isEmpty &&
                        eventViewModel.popularEvents.isEmpty {
                        
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .foregroundColor(.gray)
                            Text("No upcoming events found.")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Events")
            .task {
                await eventViewModel.fetchEvents()
            }
            .alert("Error", isPresented: $eventViewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(eventViewModel.error?.localizedDescription ?? "Unknown error")
            }
        }
    }
}
