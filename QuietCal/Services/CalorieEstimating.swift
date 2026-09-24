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

/// How much to trust an estimate, mirroring the `CalorieEstimator` package's
/// `Confidence`: `.high` from the bundled nutrition database (or a well-covered,
/// self-consistent breakdown), `.medium` from a model figure, and `.low` when the
/// figure is implausible or a decomposed dish didn't hold together.
enum EstimateConfidence: Sendable, Equatable {
    case high
    case medium
    case low

    /// User-facing description shown alongside an estimate.
    var label: String {
        switch self {
        case .high: "High confidence"
        case .medium: "Medium confidence"
        case .low: "Low confidence"
        }
    }
}

/// An ingredient inferred by the estimator for the requested portion.
struct EstimatedIngredient: Sendable, Equatable {
    let name: String
    let grams: Int
    let calories: Int
}

/// A calorie estimate for a known food name and gram weight, paired with the
/// confidence reported by the estimator. `confidence` is optional because the
/// package only reports it where available.
struct CalorieEstimate: Sendable, Equatable {
    let calories: Int
    let confidence: EstimateConfidence?
    var ingredients: [EstimatedIngredient] = []
}

/// A meal parsed and estimated from a single natural-language phrase such as
/// "200 grams of grilled chicken". `foodName` is the cleaned food (without the
/// quantity), `grams` an approximate mass (any spoken unit — oz, ml, "a cup" —
/// is normalised to grams), `calories` the estimate for that amount, and
/// `confidence` how the underlying figure was resolved (optional — reported
/// only where the package provides it).
struct MealEstimate: Sendable, Equatable {
    let foodName: String
    let grams: Int
    let calories: Int
    let confidence: EstimateConfidence?
    var ingredients: [EstimatedIngredient] = []
}

protocol CalorieEstimating: Sendable {
    var source: CalorieEstimationSource { get }
    func estimate(name: String, grams: Int) async throws -> CalorieEstimate

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
        let estimate = try await estimate(name: parsed.foodName, grams: parsed.grams)
        return MealEstimate(
            foodName: parsed.foodName,
            grams: parsed.grams,
            calories: estimate.calories,
            confidence: estimate.confidence,
            ingredients: estimate.ingredients
        )
    }
}
