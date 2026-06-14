import Foundation

protocol CalorieEstimating: Sendable {
    func estimate(name: String, grams: Int) async throws -> Int
}
