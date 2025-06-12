//
//  SporthubWatchExtension.swift
//  SporthubWatchExtension
//
//  Created by student on 11/06/25.
//

import AppIntents

struct SporthubWatchExtension: AppIntent {
    static var title: LocalizedStringResource { "SporthubWatchExtension" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
