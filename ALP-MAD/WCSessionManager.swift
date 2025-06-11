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

    /// Kirim event yang sudah diikuti ke Apple Watch
    func sendJoinedEventsToWatch(events: [EventWatch]) {
        guard session.isPaired && session.isWatchAppInstalled else {
            print("⌚️ Apple Watch tidak terhubung atau app belum terinstal.")
            return
        }

        let eventDictionaries = events.map { event in
            return [
                "id": event.id,
                "title": event.title,
                "timestamp": event.date.timeIntervalSince1970
            ] as [String: Any]
        }

        session.sendMessage(
            ["joinedEvents": eventDictionaries],
            replyHandler: nil,
            errorHandler: { error in
                print("❌ Gagal mengirim events ke Apple Watch: \(error.localizedDescription)")
            }
        )
    }
}

// MARK: - WCSessionDelegate
extension WCSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("✅ WCSession diaktifkan: \(activationState.rawValue)")
        if let error = error {
            print("⚠️ Error aktivasi: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("📩 Menerima message: \(message)")

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
        print("ℹ️ WCSession tidak aktif sementara.")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("🔁 WCSession dinonaktifkan, aktifkan ulang.")
        session.activate()
    }

    func sessionDidFinish(_ session: WCSession) {
        print("🏁 WCSession selesai.")
    }
}
