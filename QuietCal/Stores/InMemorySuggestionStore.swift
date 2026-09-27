import Foundation

actor InMemorySuggestionStore: SuggestionStore {
    private var suggestions: [StoredSuggestion]

    init(suggestions: [StoredSuggestion] = []) {
        self.suggestions = suggestions
    }

    func fetchSuggestions(
        for period: MealPeriod,
        usedSince date: Date,
        limit: Int
    ) async throws -> [StoredSuggestion] {
        Array(suggestions
            .filter { ($0.lastUsedAt(for: period) ?? .distantPast) >= date }
            .sorted { lhs, rhs in
                let lhsCount = lhs.count(for: period)
                let rhsCount = rhs.count(for: period)
                if lhsCount != rhsCount { return lhsCount > rhsCount }
                return (lhs.lastUsedAt(for: period) ?? .distantPast)
                    > (rhs.lastUsedAt(for: period) ?? .distantPast)
            }
            .prefix(limit))
    }

    func record(_ meal: Meal, period: MealPeriod) async throws {
        let key = StoredSuggestion.key(name: meal.name, grams: meal.grams)
        if let index = suggestions.firstIndex(where: { $0.key == key }) {
            suggestions[index].record(meal: meal, period: period)
        } else {
            suggestions.append(StoredSuggestion(meal: meal, period: period))
        }
    }

    func delete(id: UUID) async throws {
        suggestions.removeAll { $0.id == id }
    }

    func deleteAll() async throws {
        suggestions.removeAll()
    }
}
