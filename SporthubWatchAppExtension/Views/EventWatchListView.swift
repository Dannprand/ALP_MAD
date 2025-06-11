//
//  EventListView.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import SwiftUI

struct EventWatchListView: View {
    @StateObject private var viewModel = EventWatchViewModel()

    var body: some View {
        List(viewModel.events) { event in
            NavigationLink(destination: EventWatchDetailView(event: event)) {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Events")
    }
}

