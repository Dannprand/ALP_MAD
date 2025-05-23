//
//  MapView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), // Default to London
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedEvent: Event?
    @State private var showFilters = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Map with annotations
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: viewModel.nearbyEvents,
                annotationContent: { event in
                    MapAnnotation(coordinate: event.location.coordinate) {
                        MapPin()
                            .scaleEffect(selectedEvent?.id == event.id ? 1.3 : 1)
                            .onTapGesture {
                                selectedEvent = event
                            }
                            .animation(.spring(), value: selectedEvent)
                    }
                }
            )
            .ignoresSafeArea()
            .onAppear {
//                viewModel.locationManager.requestLocation()
                viewModel.requestUserLocation()

                Task {
                    await viewModel.fetchEvents()
                    if let userLocation = viewModel.lastKnownLocation {
                        region.center = userLocation.coordinate
                    }
                }
            }
            
            // Filter button
            Button(action: { showFilters.toggle() }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.headline)
                    .padding(12)
                    .background(Theme.cardBackground)
                    .foregroundColor(Theme.primaryText)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
            
            // Event detail sheet
            if let event = selectedEvent {
                VStack {
                    Spacer()
                    EventMapCard(event: event) {
                        selectedEvent = nil
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            
            // Filter sheet
            if showFilters {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showFilters = false }
                    .zIndex(1)
                
                VStack {
                    Spacer()
                    FilterView(selectedCategory: $viewModel.selectedCategory) {
                        showFilters = false
                        Task {
                            await viewModel.fetchEvents()
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
                .zIndex(2)
            }
        }
        .animation(.spring(), value: selectedEvent)
        .animation(.spring(), value: showFilters)
    }
}

struct MapPin: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(Theme.accentOrange)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(Theme.accentOrange)
                .offset(y: -6)
        }
    }
}

struct EventMapCard: View {
    let event: Event
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(Theme.primaryText)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.secondaryText)
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(Theme.accentOrange)
                Text(event.date.dateValue().formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
    
                Image(systemName: "clock")
                    .foregroundColor(Theme.accentOrange)
                Text(event.date.dateValue().formatted(date: .omitted, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Theme.accentOrange)
                Text(event.location.name)
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
                    .lineLimit(1)
            }
            
            NavigationLink {
                EventDetailView(event: event)
            } label: {
                Text("View Details")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Theme.accentOrange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .padding()
        .shadow(radius: 10)
    }
}

struct FilterView: View {
    @Binding var selectedCategory: SportCategory?
    let onApply: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Filter Events")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Theme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button(action: {
                        selectedCategory = nil
                    }) {
                        Text("All Sports")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == nil ? Theme.accentOrange : Theme.cardBackground)
                            .foregroundColor(selectedCategory == nil ? .white : Theme.primaryText)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Theme.accentOrange, lineWidth: 1)
                            )
                    }
                    
                    ForEach(SportCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Theme.accentOrange : Theme.cardBackground)
                                .foregroundColor(selectedCategory == category ? .white : Theme.primaryText)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Theme.accentOrange, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: onApply) {
                Text("Apply Filters")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accentOrange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Theme.background)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
