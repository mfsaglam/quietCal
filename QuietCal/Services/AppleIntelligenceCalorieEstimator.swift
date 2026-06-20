import Foundation
import CalorieEstimator

struct AppleIntelligenceCalorieEstimator: CalorieEstimating {
    let source: CalorieEstimationSource = .appleIntelligence
    private let estimator = CalorieEstimator()

    func estimate(name: String, grams: Int) async throws -> Int {
        try await estimator.estimate(meal: name, grams: grams).calories
    }
}
