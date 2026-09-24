import Foundation
import CalorieEstimator

struct AppleIntelligenceCalorieEstimator: CalorieEstimating {
    let source: CalorieEstimationSource = .appleIntelligence
    private let estimator = CalorieEstimator()

    func estimate(name: String, grams: Int) async throws -> CalorieEstimate {
        let result = try await estimator.estimate(meal: name, grams: grams)
        return CalorieEstimate(
            calories: result.calories,
            confidence: EstimateConfidence(result.confidence),
            ingredients: (result.ingredients ?? []).map {
                EstimatedIngredient(name: $0.name, grams: $0.grams, calories: $0.calories)
            }
        )
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
            calories: result.calories,
            confidence: EstimateConfidence(result.confidence),
            ingredients: (result.ingredients ?? []).map {
                EstimatedIngredient(name: $0.name, grams: $0.grams, calories: $0.calories)
            }
        )
    }
}

private extension EstimateConfidence {
    /// Maps the `CalorieEstimator` package's confidence onto the app's own
    /// ``EstimateConfidence``, keeping the package type from leaking past this
    /// service into the rest of the app. The package reports confidence only
    /// where available (`Confidence?`), so a `nil` figure maps to `nil` here.
    init?(_ packageConfidence: Confidence?) {
        switch packageConfidence {
        case .high: self = .high
        case .medium: self = .medium
        case .low: self = .low
        case nil: return nil
        }
    }
}
