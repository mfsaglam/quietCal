import Foundation
import SwiftData

@Model
final class SuggestionEntity {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var key: String
    var name: String
    var grams: Int
    var kcal: Int

    var breakfastCount: Int
    var breakfastLastUsedAt: Date?
    var lunchCount: Int
    var lunchLastUsedAt: Date?
    var afternoonCount: Int
    var afternoonLastUsedAt: Date?
    var dinnerCount: Int
    var dinnerLastUsedAt: Date?
    var lateNightCount: Int
    var lateNightLastUsedAt: Date?

    init(suggestion: StoredSuggestion) {
        id = suggestion.id
        key = suggestion.key
        name = suggestion.name
        grams = suggestion.grams
        kcal = suggestion.kcal
        breakfastCount = suggestion.breakfastCount
        breakfastLastUsedAt = suggestion.breakfastLastUsedAt
        lunchCount = suggestion.lunchCount
        lunchLastUsedAt = suggestion.lunchLastUsedAt
        afternoonCount = suggestion.afternoonCount
        afternoonLastUsedAt = suggestion.afternoonLastUsedAt
        dinnerCount = suggestion.dinnerCount
        dinnerLastUsedAt = suggestion.dinnerLastUsedAt
        lateNightCount = suggestion.lateNightCount
        lateNightLastUsedAt = suggestion.lateNightLastUsedAt
    }

    var asSuggestion: StoredSuggestion {
        StoredSuggestion(
            id: id,
            key: key,
            name: name,
            grams: grams,
            kcal: kcal,
            breakfastCount: breakfastCount,
            breakfastLastUsedAt: breakfastLastUsedAt,
            lunchCount: lunchCount,
            lunchLastUsedAt: lunchLastUsedAt,
            afternoonCount: afternoonCount,
            afternoonLastUsedAt: afternoonLastUsedAt,
            dinnerCount: dinnerCount,
            dinnerLastUsedAt: dinnerLastUsedAt,
            lateNightCount: lateNightCount,
            lateNightLastUsedAt: lateNightLastUsedAt
        )
    }

    func record(meal: Meal, period: MealPeriod) {
        name = meal.name.trimmingCharacters(in: .whitespacesAndNewlines)
        kcal = meal.kcal
        switch period {
        case .breakfast:
            breakfastCount += 1
            breakfastLastUsedAt = meal.createdAt
        case .lunch:
            lunchCount += 1
            lunchLastUsedAt = meal.createdAt
        case .afternoon:
            afternoonCount += 1
            afternoonLastUsedAt = meal.createdAt
        case .dinner:
            dinnerCount += 1
            dinnerLastUsedAt = meal.createdAt
        case .lateNight:
            lateNightCount += 1
            lateNightLastUsedAt = meal.createdAt
        }
    }
}
