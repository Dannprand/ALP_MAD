//
//  ContentView.swift
//  SporthubWatch Watch App
//
//  Created by student on 12/06/25.
//

import SwiftUI
//import SporthubWatchExtension

struct ContentView: View {
    @ObservedObject var sessionManager = WatchSessionManager.shared

    var body: some View {
        NavigationView {
            List(sessionManager.joinedEvents) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.sport.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("My Events")
        }
        .onAppear {
            print("👀 ContentView appeared. Events count: \(sessionManager.joinedEvents.count)")
        }
    }
}

