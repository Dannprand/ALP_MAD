//
//  ALP_MADApp.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

@main
struct ALP_MADApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var router = AppRouter()
    
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(router)
                .preferredColorScheme(.dark)
        }
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

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var router: AppRouter
    
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
    }
}
