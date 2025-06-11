//
//  EventRow.swift
//  SporthubWatch Watch App
//
//  Created by Kevin Christian on 12/06/25.
//

import SwiftUI

struct EventRow: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .font(.headline)
            HStack {
                Image(systemName: "calendar")
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)
        }
    }
}
