import Foundation

nonisolated protocol SuggestionStore: Sendable {
    func fetchSuggestions(
        for period: MealPeriod,
        usedSince date: Date,
        limit: Int
    ) async throws -> [StoredSuggestion]
    func record(_ meal: Meal, period: MealPeriod) async throws
    func delete(id: UUID) async throws
    func deleteAll() async throws
}
