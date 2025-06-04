//
//  Reward.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation

enum RewardCategory: String, CaseIterable, Codable {
    case all = "All"
    case fitness = "Fitness"
    case apparel = "Apparel"
    case equipment = "Equipment"
    case memberships = "Memberships"
}

struct Reward: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let cost: Int
    let category: RewardCategory
    let imageName: String
    let terms: String
    let stock: Int
}

