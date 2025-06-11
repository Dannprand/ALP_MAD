//
//  EventWatchViewModel.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import Foundation

class EventWatchViewModel: ObservableObject {
    @Published var events: [EventWatch] = []

    init() {
        loadMockEvents()
    }

    func loadMockEvents() {
        self.events = [
            EventWatch(id: "1", title: "Futsal Match", date: Date()),
            EventWatch(id: "2", title: "Badminton Game", date: Date().addingTimeInterval(3600))
        ]
    }
}
