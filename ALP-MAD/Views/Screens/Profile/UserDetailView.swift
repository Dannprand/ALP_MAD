//
//  UserDetailView.swift
//  ALP-MAD
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct UserDetailView: View {
    let user: User

    var body: some View {
        VStack {
            Text(user.fullname)
                .font(.largeTitle)
                .padding()

            if let urlString = user.profileImageUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Theme.accentOrange.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Text(user.initials)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.accentOrange)
                    )
            }

            Spacer()
        }
    }
}


