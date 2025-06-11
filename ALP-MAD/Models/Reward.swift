//
//  Reward.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import Foundation

struct Reward: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var tokenCost: Int
    var category: RewardCategory
    var imageName: String
}

enum RewardCategory: String, Codable, CaseIterable, Hashable {
    case all = "All"
    case apparel = "Apparel"
    case equipment = "Equipment"
    case supplement = "Supplement"
    case other = "Other"
}
