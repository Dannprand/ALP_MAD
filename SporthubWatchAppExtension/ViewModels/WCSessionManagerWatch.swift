//
//  WatchSessionManager.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import Foundation
import WatchConnectivity

class WCSessionManagerWatch: NSObject, ObservableObject {
    static let shared = WCSessionManagerWatch()
    private let session = WCSession.default
    
    @Published var receivedEvents: [EventWatch] = []

    private override init() {
        super.init()
        activateSession()
    }

    func activateSession() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
}

// MARK: - WCSessionDelegate
extension WCSessionManagerWatch: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            DispatchQueue.main.async {
                print("📩 Watch received message: \(message)")
                
                if let joinedEventsData = message["joinedEvents"] as? [[String: Any]] {
                    let events: [EventWatch] = joinedEventsData.compactMap { dict in
                        guard let id = dict["id"] as? String,
                              let title = dict["title"] as? String,
                              let timestamp = dict["timestamp"] as? TimeInterval else {
                            return nil
                        }
                        return EventWatch(id: id, title: title, date: Date(timeIntervalSince1970: timestamp))
                    }
                    
                    self.receivedEvents = events
                }
            }
        }
}

