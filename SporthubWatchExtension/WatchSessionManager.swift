import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()

    @Published var joinedEvents: [Event] = []

    override private init() {
        super.init()
        activateSession()
    }

    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("✅ WCSession is supported and activating.")
        } else {
            print("❌ WCSession not supported on this device.")
        }
    }

    // ✅ REQUIRED for watchOS
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print(
                "❌ WCSession activation failed: \(error.localizedDescription)"
            )
        } else {
            print(
                "✅ WCSession activated with state: \(activationState.rawValue)"
            )
        }
    }

    // ✅ Handles receiving events from iPhone
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        print("📩 Received userInfo: \(userInfo.keys)")

        if let data = userInfo["joinedEvents"] as? Data {
            let decoder = JSONDecoder()
            do {
                let events = try decoder.decode([Event].self, from: data)
                DispatchQueue.main.async {
                    self.joinedEvents = events
                    print("✅ Updated events (\(events.count))")
                }
            } catch {
                print("❌ Failed to decode events: \(error)")
            }
        } else {
            print("⚠️ No valid 'joinedEvents' in userInfo.")
        }
    }
}
