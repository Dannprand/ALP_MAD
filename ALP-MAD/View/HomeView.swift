//
//  HomeView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

// HomeView.swift

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(0..<10) { index in
                        EventCardView(
                            eventTitle: "Event \(index + 1)",
                            eventDate: "12 Juni 2025",
                            hostName: "Host \(index + 1)",
                            imageName: "sport\(index % 3 + 1)"
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Sport Hub")
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
}

#Preview {
    HomeView()
}

