//
//  MacMainView.swift
//  MAC
//
//  Created by student on 11/06/25.
//

import SwiftUI

struct MacMainView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("Home", value: "home")
                NavigationLink("Profile", value: "profile")
            }
        } detail: {
            NavigationStack(path: $router.path) {
                Text("Welcome to macOS App!")
                    .padding()
                    .navigationDestination(for: String.self) { destination in
                        switch destination {
                        case "home":
                            HomeView()
                        case "profile":
                            ProfileView()
                        default:
                            Text("Unknown destination")
                        }
                    }
            }
        }
    }
}


#Preview {
    MacMainView()
}
