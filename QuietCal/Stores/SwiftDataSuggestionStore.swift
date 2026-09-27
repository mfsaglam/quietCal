import Foundation
import SwiftData

@ModelActor
actor SwiftDataSuggestionStore: SuggestionStore {
    func fetchSuggestions(
        for period: MealPeriod,
        usedSince date: Date,
        limit: Int
    ) async throws -> [StoredSuggestion] {
        let suggestions = try modelContext.fetch(FetchDescriptor<SuggestionEntity>())
            .map(\.asSuggestion)
            .filter { ($0.lastUsedAt(for: period) ?? .distantPast) >= date }
            .sorted { lhs, rhs in
                let lhsCount = lhs.count(for: period)
                let rhsCount = rhs.count(for: period)
                if lhsCount != rhsCount { return lhsCount > rhsCount }
                return (lhs.lastUsedAt(for: period) ?? .distantPast)
                    > (rhs.lastUsedAt(for: period) ?? .distantPast)
            }
        return Array(suggestions.prefix(limit))
    }

    func record(_ meal: Meal, period: MealPeriod) async throws {
        let key = StoredSuggestion.key(name: meal.name, grams: meal.grams)
        let descriptor = FetchDescriptor<SuggestionEntity>(
            predicate: #Predicate { $0.key == key }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            existing.record(meal: meal, period: period)
        } else {
            modelContext.insert(SuggestionEntity(
                suggestion: StoredSuggestion(meal: meal, period: period)
            ))
        }
        try modelContext.save()
    }

    func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<SuggestionEntity>(
            predicate: #Predicate { $0.id == id }
        )
        for entity in try modelContext.fetch(descriptor) {
            modelContext.delete(entity)
        }
        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: SuggestionEntity.self)
        try modelContext.save()
    }
}
