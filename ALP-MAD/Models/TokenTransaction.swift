import Foundation

struct TokenTransaction: Identifiable, Codable {
    let id: String
    let amount: Int
    let date: Date
    let eventName: String?
    let reason: String?
}
