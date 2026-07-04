import Foundation

/// Interim natural-language parser that extracts an approximate quantity, unit
/// and food name from a spoken phrase such as "200 grams of grilled chicken".
///
/// This is a lightweight, digit-based fallback so the Siri flow works before
/// the model-based parser lands. The authoritative parsing is intended to move
/// into the `CalorieEstimator` package's `estimate(phrase:)`, which handles
/// messy phrasing ("a cup", "a handful", "two eggs") and word-number
/// quantities that this parser deliberately doesn't attempt.
enum MealPhraseParser {
    struct Result: Sendable, Equatable {
        let foodName: String
        let grams: Int
    }

    /// Grams assumed when the phrase names a food but no measurable amount.
    static let defaultGrams = 100

    /// Known units mapped to their gram multiplier. Volume units (ml, l) are
    /// approximated at water density (1 ml ≈ 1 g) — good enough as an interim.
    /// Order matters: longer/compound units are matched before shorter ones.
    private static let units: [(pattern: String, multiplier: Double)] = [
        ("\\b(kg|kilograms?|kilos?)\\b", 1000),
        ("\\b(mg|milligrams?)\\b", 0.001),
        ("\\b(g|grams?)\\b", 1),
        ("\\b(oz|ounces?)\\b", 28.3495),
        ("\\b(lbs?|pounds?)\\b", 453.592),
        ("\\b(ml|milliliters?|millilitres?)\\b", 1),
        ("\\b(l|liters?|litres?)\\b", 1000),
    ]

    static func parse(_ phrase: String) -> Result {
        let trimmed = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        let grams: Int
        if let quantity = firstNumber(in: lower) {
            grams = max(1, Int((quantity * unitMultiplier(in: lower)).rounded()))
        } else {
            grams = defaultGrams
        }

        let foodName = cleanedFoodName(from: trimmed)
        return Result(foodName: foodName.isEmpty ? trimmed : foodName, grams: grams)
    }

    /// The first decimal number in the text, if any. "1,5" and "1.5" both parse.
    private static func firstNumber(in text: String) -> Double? {
        guard let range = text.range(of: "[0-9]+([.,][0-9]+)?", options: .regularExpression) else {
            return nil
        }
        return Double(text[range].replacingOccurrences(of: ",", with: "."))
    }

    /// Multiplier for the first recognised unit token, defaulting to grams.
    private static func unitMultiplier(in text: String) -> Double {
        for unit in units where text.range(of: unit.pattern, options: .regularExpression) != nil {
            return unit.multiplier
        }
        return 1
    }

    /// Strips the quantity, unit tokens and filler words, leaving the food.
    private static func cleanedFoodName(from phrase: String) -> String {
        let patterns = [
            "[0-9]+([.,][0-9]+)?",
            "\\b(kg|kilograms?|kilos?|mg|milligrams?|g|grams?|oz|ounces?|lbs?|pounds?|ml|milliliters?|millilitres?|l|liters?|litres?)\\b",
            "\\b(of|a|an|the)\\b",
        ]
        var result = phrase
        for pattern in patterns {
            result = result.replacingOccurrences(
                of: pattern,
                with: " ",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        return result
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
