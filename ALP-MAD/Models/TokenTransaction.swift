//
//  TokenTransaction.swift
//  ALP-MAD
//
//  Created by student on 11/06/25.
//

import Foundation

struct TokenTransaction: Identifiable, Codable {
    var id: String
    var userId: String
    var rewardId: String
    var rewardName: String
    var tokenAmount: Int
    var date: Date
}
