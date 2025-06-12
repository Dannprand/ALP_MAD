//
//  SporthubWatchAppApp.swift
//  SporthubWatchApp Watch App
//
//  Created by student on 11/06/25.
//

import SwiftUI

@main
struct SporthubWatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                EventWatchListView()
            }
        }
    }
}


