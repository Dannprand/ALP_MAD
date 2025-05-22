//
//  Theme.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct Theme {
    // Background colors
    static let background = Color(hex: "121212")
    static let cardBackground = Color(hex: "1E1E1E")
    static let tabBarBackground = Color(hex: "1A1A1A")
    
    // Text colors
    static let primaryText = Color(hex: "FFFFFF")
    static let secondaryText = Color(hex: "B3B3B3")
    static let tertiaryText = Color(hex: "808080")
    
    // Accent colors
    static let accentOrange = Color(hex: "FF7B25")
    static let accentOrangeLight = Color(hex: "FF9A56")
    static let accentOrangeDark = Color(hex: "D45A00")
    
    // Status colors
    static let success = Color(hex: "4CAF50")
    static let warning = Color(hex: "FFC107")
    static let error = Color(hex: "F44336")
    
    // Chat bubbles
    static let userBubble = accentOrange
    static let otherBubble = Color(hex: "2C2C2C")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
