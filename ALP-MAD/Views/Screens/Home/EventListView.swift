import SwiftUI

struct EventListView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
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
            }
        }
        .onAppear {
            Task {
                await eventViewModel.fetchEvents()
            }
        }
    }
}
