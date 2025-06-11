//
//  WatchSessionManager.swift
//  SporthubWatchAppExtension
//
//  Created by student on 11/06/25.
//

import Foundation
import WatchConnectivity

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

    // Example: Send message to watch or phone
    func send(message: [String: Any]) {
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("WCSession send error: \(error.localizedDescription)")
            })
        }
    }
}

// MARK: - WCSessionDelegate
extension WCSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activated: \(activationState.rawValue)")
    }

    // These are iOS-only
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func sessionDidFinish(_ session: WCSession) {}
    #endif

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("Received message: \(message)")
            // Handle data here
        }
    }
}
