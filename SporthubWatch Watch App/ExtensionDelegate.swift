//
//  ExtensionDelegate.swift
//  SporthubWatch Watch App
//
//  Created by Kevin Christian on 12/06/25.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    private let connectivityManager = WatchConnectivityManager()
    
    func applicationDidFinishLaunching() {
        connectivityManager.activateSession()
    }
}
