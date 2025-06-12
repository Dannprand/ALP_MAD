//
//  SporthubWatchApp.swift
//  SporthubWatch Watch App
//
//  Created by student on 12/06/25.
//

import SwiftUI

@main
struct SporthubWatchApp: App {
    @StateObject private var sessionManager = WatchSessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}
