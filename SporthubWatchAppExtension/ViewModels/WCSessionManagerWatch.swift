//
//  WatchSessionManager.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import Foundation
import WatchConnectivity

class WCSessionManagerWatch: NSObject, WCSessionDelegate {
    static let shared = WCSessionManagerWatch()

    private override init() {
        super.init()
        activateSession()
    }

    private let session = WCSession.default

    func activateSession() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activated with state: \(activationState.rawValue)")
        if let error = error {
            print("Activation error: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let joinedEventsData = message["joinedEvents"] as? [[String: Any]] {
                let events: [EventWatch] = joinedEventsData.compactMap { dict in
                    guard let id = dict["id"] as? String,
                          let title = dict["title"] as? String,
                          let timestamp = dict["timestamp"] as? TimeInterval else {
                        return nil
                    }
                    return EventWatch(id: id, title: title, date: Date(timeIntervalSince1970: timestamp))
                }
                NotificationCenter.default.post(name: .didReceiveEvents, object: events)
            }
        }
    }
}


