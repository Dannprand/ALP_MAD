//
//  ALP_MADApp.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseCore

@main
struct ALP_MADApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var router = AppRouter()
    
    // Initiate Firebase
    init() {
        FirebaseApp.configure()
        setupAppearance()
    }
//    init() {
//        // Add this before Firebase configuration
//        let settings = FirestoreSettings()
//        settings.isPersistenceEnabled = false // Disable cache temporarily for debugging
//        Firestore.firestore().settings = settings
//        
//        FirebaseApp.configure()
//        
//        // Verify configuration
//        if FirebaseApp.app() == nil {
//            print("🔥 Firebase configuration failed!")
//        } else {
//            print("✅ Firebase configured successfully")
//        }
//    }
    
    var body: some Scene {
        WindowGroup {
                    ContentView()
                        .environmentObject(authViewModel)
                        .environmentObject(router)
                        .preferredColorScheme(.dark)
                        .onAppear {
                            // Check if user wants to stay signed in (if you implement that option)
                            checkAuthenticationStatus()
                        }
                }
//        WindowGroup {
//            ContentView()
//                .environmentObject(authViewModel)
//                .environmentObject(router)
//                .preferredColorScheme(.dark)
//        }
    }
    
    private func checkAuthenticationStatus() {
            // If you want to completely disable automatic login:
            authViewModel.signOut()
            
            // OR if you want to implement "Remember me" functionality:
            /*
            if !UserDefaults.standard.bool(forKey: "staySignedIn") {
                authViewModel.signOut()
            }
            */
        }
    
    private func setupAppearance() {
        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Theme.primaryText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Theme.primaryText)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Theme.accentOrange)
        
        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Theme.background)
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Theme.secondaryText)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.secondaryText)]
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.accentOrange)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.accentOrange)]
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
