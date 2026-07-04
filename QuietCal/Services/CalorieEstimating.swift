import Foundation

/// Identifies which engine produced a calorie estimate, for display in the UI.
enum CalorieEstimationSource {
    case appleIntelligence
    case stub

    var label: String {
        switch self {
        case .appleIntelligence: "Estimated by Apple Intelligence"
        case .stub: "Estimated by Stub Estimator"
        }
    }
}

/// A meal parsed and estimated from a single natural-language phrase such as
/// "200 grams of grilled chicken". `foodName` is the cleaned food (without the
/// quantity), `grams` an approximate mass (any spoken unit — oz, ml, "a cup" —
/// is normalised to grams), and `calories` the estimate for that amount.
struct MealEstimate: Sendable, Equatable {
    let foodName: String
    let grams: Int
    let calories: Int
}

protocol CalorieEstimating: Sendable {
    var source: CalorieEstimationSource { get }
    func estimate(name: String, grams: Int) async throws -> Int

    /// Estimates a meal from one free-text phrase, doing the food/quantity
    /// parsing for the caller. Used by the low-friction Siri flow, where the
    /// user says a single sentence and everything else is inferred.
    func estimate(phrase: String) async throws -> MealEstimate
}

extension CalorieEstimating {
    /// Interim default: parses the phrase locally with ``MealPhraseParser`` and
    /// reuses ``estimate(name:grams:)`` for the calorie count. The authoritative
    /// implementation is intended to live in the `CalorieEstimator` package's
    /// own `estimate(phrase:)`, which the model can parse far more robustly
    /// ("a cup", "a handful", word-number quantities). Once that ships,
    /// override this method to delegate to it.
    func estimate(phrase: String) async throws -> MealEstimate {
        let parsed = MealPhraseParser.parse(phrase)
        let calories = try await estimate(name: parsed.foodName, grams: parsed.grams)
        return MealEstimate(foodName: parsed.foodName, grams: parsed.grams, calories: calories)
    }
}
