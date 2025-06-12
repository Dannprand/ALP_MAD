//
//  PhoneSessionManager.swift
//  ALP-MAD
//
//  Created by student on 12/06/25.
//

import Foundation
import WatchConnectivity

class PhoneSessionManager: NSObject, WCSessionDelegate {
    static let shared = PhoneSessionManager()
    
    private override init() {
        super.init()
        activateSession()
    }

    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("✅ PhoneSessionManager activated WCSession.")
        }
    }

    func sendJoinedEventsToWatch(events: [Event]) {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else {
            print("⌚️ Watch not paired or app not installed.")
            return
        }

        do {
            let data = try JSONEncoder().encode(events)
            WCSession.default.transferUserInfo(["joinedEvents": data])
            print("📤 Sent \(events.count) joined events to watch.")
        } catch {
            print("❌ Failed to encode events: \(error)")
        }
    }

    // Optional WCSessionDelegate methods (not strictly required unless you want to handle more)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Activation error: \(error.localizedDescription)")
        } else {
            print("✅ PhoneSessionManager session activated.")
        }
    }
}
