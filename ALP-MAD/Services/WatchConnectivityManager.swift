////
////  WatchConnectivityManager.swift
////  ALP-MAD
////
////  Created by Kevin Christian on 12/06/25.
////
//
//import WatchConnectivity
//
//class WatchConnectivityManager: NSObject, ObservableObject {
//    static let shared = WatchConnectivityManager()
//    private override init() {
//        super.init()
//        activateSession()
//    }
//    
//    private func activateSession() {
//        if WCSession.isSupported() {
//            WCSession.default.delegate = self
//            WCSession.default.activate()
//            print("WCSession activated on iOS")
//        }
//    }
//    
//    func sendEventsToWatch(_ events: [Event]) {
//        guard WCSession.default.isReachable else {
//            print("Watch is not reachable")
//            return
//        }
//        
//        do {
//            let data = try JSONEncoder().encode(events)
//            let message = ["events": data]
//            WCSession.default.sendMessage(message, replyHandler: { reply in
//                print("Received reply from watch: \(reply)")
//            }, errorHandler: { error in
//                print("Error sending message to watch: \(error.localizedDescription)")
//            })
//        } catch {
//            print("Error encoding events: \(error.localizedDescription)")
//        }
//    }
//}
//
//// MARK: - WCSessionDelegate
//extension WatchConnectivityManager: WCSessionDelegate {
//    // Required delegate methods
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        if let error = error {
//            print("Session activation failed: \(error.localizedDescription)")
//        } else {
//            print("Session activated with state: \(activationState.rawValue)")
//        }
//    }
//    
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("Session became inactive")
//    }
//    
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("Session deactivated")
//        // Reactivate the session to allow future connections
//        WCSession.default.activate()
//    }
//    
//    // Optional delegate methods
//    func sessionReachabilityDidChange(_ session: WCSession) {
//        print("Reachability changed: \(session.isReachable ? "Reachable" : "Not reachable")")
//    }
//}
