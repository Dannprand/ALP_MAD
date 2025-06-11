//
//  EventWatchViewModel.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import Foundation
import Combine
import WatchConnectivity

class EventWatchViewModel: ObservableObject {
    @Published var joinedEvents: [EventWatch] = []

    init() {
        NotificationCenter.default.addObserver(
            forName: .didReceiveEvents,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let events = notification.object as? [EventWatch] {
                self?.joinedEvents = events
            }
        }

        // Now this will be recognized if WCSessionManagerWatch.swift is correct
        WCSessionManagerWatch.shared.activateSession()
    }
}

extension Notification.Name {
    static let didReceiveEvents = Notification.Name("didReceiveEvents")
}


