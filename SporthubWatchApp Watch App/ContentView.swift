//
//  ContentView.swift
//  SporthubWatchApp Watch App
//
//  Created by student on 11/06/25.
//

import SwiftUI

struct ContentView: View {
    var eventTitle: String
       var eventTime: String
       var eventLocation: String

        var body: some View {
                ZStack {
                    Theme.background
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 6) {
                        Text("Upcoming Event")
                            .font(.footnote)
                            .foregroundColor(Theme.accentOrangeLight)

                        Text(eventTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Theme.primaryText)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)

                        Text(eventTime)
                            .font(.caption)
                            .foregroundColor(Theme.secondaryText)

                        Text(eventLocation)
                            .font(.caption2)
                            .foregroundColor(Theme.accentOrangeDark)
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
   }

   #Preview {
       ContentView(
           eventTitle: "Futsal with Team",
           eventTime: "Today at 5:00 PM",
           eventLocation: "Jakarta Sport Hall"
       )
   }
