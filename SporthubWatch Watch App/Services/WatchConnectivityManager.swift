//
//  WatchConnectivityManager.swift
//  SporthubWatch Watch App
//
//  Created by Kevin Christian on 12/06/25.
//

import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    @Published var events: [Event] = []
    
    override init() {
        super.init()
        activateSession()
    }
    
    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let eventsData = message["events"] as? Data {
            do {
                let events = try JSONDecoder().decode([Event].self, from: eventsData)
                DispatchQueue.main.async {
                    self.events = events
                }
            } catch {
                print("Error decoding events: \(error)")
            }
        }
    }
}
