//
//  HomeView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var eventViewModel = EventViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Welcome header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.title2)
                        .foregroundColor(Theme.secondaryText)
                    
                    Text(authViewModel.currentUser?.fullname ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primaryText)
                }
                .padding(.horizontal)
                
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(SportCategory.allCases, id: \.self) { category in
                            CategoryPill(category: category, isSelected: eventViewModel.selectedCategory == category)
                                .onTapGesture {
                                    eventViewModel.selectedCategory = category
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Featured events
                if !eventViewModel.featuredEvents.isEmpty {
                    EventSection(title: "Featured", events: eventViewModel.featuredEvents)
                }
                
                // Nearby events
                if !eventViewModel.nearbyEvents.isEmpty {
                    EventSection(title: "Near You", events: eventViewModel.nearbyEvents)
                }
                
                // Popular events
                if !eventViewModel.popularEvents.isEmpty {
                    EventSection(title: "Popular", events: eventViewModel.popularEvents)
                }
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image(systemName: "sportscourt.fill")
                    .foregroundColor(Theme.accentOrange)
            }
        }
        .task {
            await eventViewModel.fetchEvents()
        }
    }
}

struct EventSection: View {
    let title: String
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Theme.primaryText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(events) { event in
                        NavigationLink {
                            EventDetailView(event: event)
                        } label: {
                            EventCard(event: event)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CategoryPill: View {
    let category: SportCategory
    let isSelected: Bool
    
    var body: some View {
        Text(category.rawValue)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Theme.accentOrange : Theme.cardBackground)
            .foregroundColor(isSelected ? .white : Theme.primaryText)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.accentOrange, lineWidth: isSelected ? 0 : 1)
            )
    }
}
