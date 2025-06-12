//
//  SporthubWatchApp.swift
//  SporthubWatch Watch App
//
//  Created by Kevin Christian on 12/06/25.
//

import SwiftUI

@main
struct SporthubWatchApp: App {
    @StateObject private var connectivityManager = WatchConnectivityManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityManager)
        }
    }
}
//@main
//struct SporthubWatch_Watch_AppApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
