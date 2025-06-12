//
//  EventDetailView.swift
//  SporthubWatch Watch App
//
//  Created by Kevin Christian on 12/06/25.
//

import SwiftUI
import Foundation

struct EventDetailView: View {
    let event: Event
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.title3)
                
                Text(event.description)
                    .font(.body)
                
                Text(event.location.name)
                    .font(.caption)
                
                Text(event.date.formatted())
                    .font(.caption)
            }
            .padding()
        }
        .navigationTitle("Event Details")
    }
}
