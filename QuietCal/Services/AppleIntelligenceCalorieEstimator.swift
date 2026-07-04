import Foundation
import CalorieEstimator

struct AppleIntelligenceCalorieEstimator: CalorieEstimating {
    let source: CalorieEstimationSource = .appleIntelligence
    private let estimator = CalorieEstimator()

    func estimate(name: String, grams: Int) async throws -> Int {
        try await estimator.estimate(meal: name, grams: grams).calories
    }

    // Until the CalorieEstimator package ships a model-based `estimate(phrase:)`,
    // this type uses the protocol's default phrase handling (local parse via
    // MealPhraseParser + `estimate(name:grams:)`). Once the package can parse a
    // full phrase, override here to delegate — the model handles messy phrasing
    // ("a cup", "a handful", word numbers) far better than the local parser:
    //
    // func estimate(phrase: String) async throws -> MealEstimate {
    //     let result = try await estimator.estimate(phrase: phrase)
    //     return MealEstimate(foodName: result.foodName, grams: result.grams, calories: result.calories)
    // }
}
