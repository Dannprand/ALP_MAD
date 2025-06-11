//
//  MACApp.swift
//  MAC
//
//  Created by student on 11/06/25.
//

import SwiftUI

@main
struct MACApp: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            AppRouter.initialView()
                .environmentObject(router)
        }
    }
}
