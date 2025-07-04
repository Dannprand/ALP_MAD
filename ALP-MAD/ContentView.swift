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

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }

    var body: some View {
        Group {
            if authViewModel.isLoading {
                SplashScreenView()
            } else if authViewModel.userSession == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .overlay(
            Group {
                if authViewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView()
                            .scaleEffect(2)
                            .tint(Theme.accentOrange)
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
