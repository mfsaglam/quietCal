import Foundation
import CalorieEstimator

/// Adapts the package's local-database-first estimator to QuietCal's domain
/// types. Availability and fallback selection intentionally remain inside the
/// package.
struct PackageCalorieEstimator: CalorieEstimating {
    private let estimator = CalorieEstimator()

    func estimate(name: String, grams: Int) async throws -> CalorieEstimate {
        let result = try await estimator.estimate(meal: name, grams: grams)
        return CalorieEstimate(
            calories: result.calories,
            confidence: EstimateConfidence(result.confidence),
            source: source(for: result.provenance),
            ingredients: (result.ingredients ?? []).map {
                EstimatedIngredient(name: $0.name, grams: $0.grams, calories: $0.calories)
            }
        )
    }

    func estimate(phrase: String) async throws -> QuietCal.MealEstimate {
        let result = try await estimator.estimate(phrase: phrase)
        return QuietCal.MealEstimate(
            foodName: result.foodName,
            grams: result.grams,
            calories: result.calories,
            confidence: EstimateConfidence(result.confidence),
            source: source(for: result.provenance),
            ingredients: (result.ingredients ?? []).map {
                EstimatedIngredient(name: $0.name, grams: $0.grams, calories: $0.calories)
            }
        )
    }

    private func source(for provenance: EstimateProvenance) -> CalorieEstimationSource {
        switch provenance {
        case .localRecipe, .localNutrition:
            .localDatabase
        case .modelAssistedRecipe, .modelNutrition:
            .appleIntelligence
        }
    }
}

private extension EstimateConfidence {
    nonisolated init?(_ packageConfidence: Confidence?) {
        switch packageConfidence {
        case .high: self = .high
        case .medium: self = .medium
        case .low: self = .low
        case nil: return nil
        }
    }
}
