//
//  SplashScreenView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var scale = 0.5
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack {
                Image(systemName: "sportscourt.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Theme.accentOrange)
                    .scaleEffect(scale)
                
                Text("SportHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.primaryText)
                    .opacity(opacity)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

