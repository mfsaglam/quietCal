import Foundation
import CalorieEstimator

struct AppleIntelligenceCalorieEstimator: CalorieEstimating {
    let source: CalorieEstimationSource = .appleIntelligence
    private let estimator = CalorieEstimator()

    func estimate(name: String, grams: Int) async throws -> Int {
        try await estimator.estimate(meal: name, grams: grams).calories
    }

    /// Delegates whole-phrase parsing to the package's model-based
    /// `estimate(phrase:)` (CalorieEstimator 1.2.0+), which handles messy
    /// phrasing — "a cup", "a handful", word-number quantities — far better than
    /// the interim `MealPhraseParser` used by the protocol's default. The return
    /// type is the app's own `MealEstimate` (`QuietCal.MealEstimate`), distinct
    /// from the package's identically-named type.
    func estimate(phrase: String) async throws -> QuietCal.MealEstimate {
        let result = try await estimator.estimate(phrase: phrase)
        return QuietCal.MealEstimate(
            foodName: result.foodName,
            grams: result.grams,
            calories: result.calories
        )
    }
}
