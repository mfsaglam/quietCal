import Foundation
import CalorieEstimator

struct AppleIntelligenceCalorieEstimator: CalorieEstimating {
    private let estimator = CalorieEstimator()

    func estimate(name: String, grams: Int) async throws -> Int {
        try await estimator.estimate(meal: name, grams: grams).calories
    }
}
