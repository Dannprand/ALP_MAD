//
//  ContentView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isLoading {
                SplashScreenView()
            } else if authViewModel.userSession == nil {
                LoginView()
            } else if let _ = authViewModel.userSession,
                      let _ = authViewModel.currentUser {
                MainTabView()
            } else {
                SplashScreenView() // fallback until user is fetched
            }
        }
        .overlay(
            Group {
                if authViewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView()
                            .scaleEffect(2)
                            .tint(.orange)
                    }
                }
            }
        )
        .alert("Error", isPresented: $authViewModel.showError, presenting: authViewModel.error) { error in
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject({
            let vm = AuthViewModel()
            vm.isLoading = false
            vm.userSession = Auth.auth().currentUser
            vm.currentUser = User(
                id: "previewUser123",
                fullname: "Preview User",
                email: "preview@example.com",
                preferences: [.football],
                joinedEvents: ["event1"],
                hostedEvents: ["event2"]
            )
            return vm
        }())
    }
}
