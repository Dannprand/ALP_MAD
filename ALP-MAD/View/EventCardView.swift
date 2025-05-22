//
//  EventCardView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

// EventCardView.swift

import SwiftUI

struct EventCardView: View {
    var eventTitle: String
    var eventDate: String
    var hostName: String
    var imageName: String

    var body: some View {
        HStack(spacing: 10) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 110, height: 110)
                .clipped()
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 8) {
                Text(eventTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Text(eventDate)
                    .font(.subheadline)
                    .foregroundColor(.orange)

                Text("Host: \(hostName)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack {
                Spacer()
                Button(action: {}) {
                    Text("Join")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .frame(height: 110)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 160) 
        .background(Color(.secondarySystemBackground).opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EventCardView(
            eventTitle: "Sunday Morning Ride",
            eventDate: "25 Mei 2025",
            hostName: "Community Cycling Club",
            imageName: "sportscourt.fill"
        )
        .padding()
    }
}

