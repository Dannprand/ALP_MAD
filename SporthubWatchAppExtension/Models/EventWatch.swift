//
//  EventWatch.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import Foundation

struct EventWatch: Identifiable, Codable {
    var id: String
    var title: String
    var date: Date
}


extension EventWatch {
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

