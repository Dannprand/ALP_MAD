//
//  MainTabView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
//            // Map Tab
//            NavigationStack {
//                MapView()
//            }
//            .tabItem {
//                Image(systemName: "map.fill")
//                Text("Map")
//            }
//            .tag(1)
            
            // Shop Tab
            NavigationStack {
                ShopView()
            }
            .tabItem {
                Image(systemName: "bag.fill")
                Text("Shop")
            }
            .tag(3)	
            
            // Create Event Tab
            NavigationStack {
                CreateEventView()
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("Create")
            }
            .tag(2)
            
            
            // Explore Tab
             NavigationStack {
                  ExploreVIew()
              }
              .tabItem {
                  Image(systemName: "person.3.fill")
                  Text("Explore")
              }
              .tag(1)
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(4)
        }
        .accentColor(Theme.accentOrange)
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private func checkOnboardingStatus() {
        guard let user = authViewModel.currentUser else { return }
        if user.preferences.isEmpty {
            // Show onboarding
            selectedTab = 0 // Ensure home tab is selected so navigation works
            DispatchQueue.main.async {
                // Present onboarding sheet
            }
        }
    }
}
