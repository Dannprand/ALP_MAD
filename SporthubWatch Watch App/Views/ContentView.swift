//
//  ContentView.swift
//  SporthubWatch Watch App
//
//  Created by Kevin Christian on 12/06/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var connectivityManager: WatchConnectivityManager
    
    var body: some View {
        NavigationStack {
            if connectivityManager.events.isEmpty {
                ProgressView()
                    .navigationTitle("Loading Events...")
            } else {
                List(connectivityManager.events) { event in
                    NavigationLink(value: event) {
                        EventRow(event: event)
                    }
                }
                .navigationTitle("Upcoming Events")
                .navigationDestination(for: Event.self) { event in
                    EventDetailView(event: event)
                }
            }
        }
    }
}
//struct ContentView: View {
//    @StateObject private var connectivityManager = WatchConnectivityManager()
//    @State private var selectedEvent: Event?
//    
//    var body: some View {
//        NavigationStack {
//            List(connectivityManager.events) { event in
//                NavigationLink(value: event) {
//                    EventRow(event: event)
//                }
//            }
//            .navigationTitle("Events")
//            .navigationDestination(for: Event.self) { event in
//                EventDetailView(event: event)
//            }
//        }
//    }
//}

//struct EventRow: View {
//    let event: Event
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(event.title)
//                .font(.headline)
//            Text(event.date.dateValue().formatted())
//                .font(.caption)
//            Text("\(event.participants.count)/\(event.maxParticipants)")
//                .font(.caption2)
//        }
//    }
//}


