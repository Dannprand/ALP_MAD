//
//  EventWatchDetailView.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import SwiftUI

struct EventWatchDetailView: View {
    let event: EventWatch

    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .font(.title)
            Text("Date: \(event.dateFormatted)")
                .font(.subheadline)
        }
        .padding()
    }
}

