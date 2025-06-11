//
//  SporthubWatchAppApp.swift
//  SporthubWatchApp Watch App
//
//  Created by student on 11/06/25.
//

import SwiftUI

@main
struct SporthubWatchApp_Watch_App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(eventTitle: "Futsal with Team",
                        eventTime: "Today at 5:00 PM",
                        eventLocation: "Jakarta Sport Hall")
        }
    }
}
