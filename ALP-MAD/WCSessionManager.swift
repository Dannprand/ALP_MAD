//
//  WCSessionManager.swift
//  ALP-MAD
//
//  Created by student on 11/06/25.
//

import Foundation
import WatchConnectivity

extension Notification.Name {
    static let didReceiveEvents = Notification.Name("didReceiveEvents")
}

class WCSessionManager: NSObject, ObservableObject {
    static let shared = WCSessionManager()

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

}

// MARK: - WCSessionDelegate
extension WCSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activated with state: \(activationState.rawValue)")
        if let error = error {
            print("Activation error: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("📩 Received message: \(message)")

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

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession did become inactive.")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession did deactivate.")
        session.activate()
    }

    func sessionDidFinish(_ session: WCSession) {
        print("WCSession did finish.")
    }
}



