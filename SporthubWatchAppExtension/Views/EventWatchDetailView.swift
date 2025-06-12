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
        VStack(alignment: .leading, spacing: 10) {
            Text(event.title)
                .font(.title2)
                .bold()

            Text("Date: \(event.date.formatted(.dateTime.month().day().hour().minute()))")
                .font(.body)

            Spacer()
        }
        .padding()
        .navigationTitle("Detail")
    }
}


