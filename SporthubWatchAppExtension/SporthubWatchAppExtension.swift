//
//  SporthubWatchAppExtension.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import AppIntents

struct SporthubWatchAppExtension: AppIntent {
    static var title: LocalizedStringResource { "SporthubWatchAppExtension" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
