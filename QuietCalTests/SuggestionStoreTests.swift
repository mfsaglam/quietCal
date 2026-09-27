import Foundation
import SwiftData
import Testing
@testable import QuietCal

@Suite("SuggestionStore")
struct SuggestionStoreTests {
    enum Kind: String, CaseIterable, Sendable, CustomStringConvertible {
        case inMemory
        case swiftData

        var description: String { rawValue }

        func make() throws -> any SuggestionStore {
            switch self {
            case .inMemory:
                return InMemorySuggestionStore()
            case .swiftData:
                let container = try ModelContainer(
                    for: SuggestionEntity.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
                return SwiftDataSuggestionStore(modelContainer: container)
            }
        }
    }

    @Test(arguments: Kind.allCases)
    func repeatedNameAndGramsUpdateOneSuggestion(_ kind: Kind) async throws {
        let store = try kind.make()
        try await store.record(
            makeSuggestionMeal(name: "Apple", grams: 150, kcal: 80, day: 10),
            period: .afternoon
        )
        try await store.record(
            makeSuggestionMeal(name: " apple ", grams: 150, kcal: 85, day: 11),
            period: .afternoon
        )

        let suggestions = try await store.fetchSuggestions(
            for: .afternoon,
            usedSince: .distantPast,
            limit: 5
        )

        try #require(suggestions.count == 1)
        #expect(suggestions[0].name == "apple")
        #expect(suggestions[0].grams == 150)
        #expect(suggestions[0].kcal == 85)
        #expect(suggestions[0].count(for: .afternoon) == 2)
    }

    @Test(arguments: Kind.allCases)
    func differentGramAmountsRemainSeparate(_ kind: Kind) async throws {
        let store = try kind.make()
        try await store.record(makeSuggestionMeal(name: "Apple", grams: 150), period: .afternoon)
        try await store.record(makeSuggestionMeal(name: "Apple", grams: 200), period: .afternoon)

        let suggestions = try await store.fetchSuggestions(
            for: .afternoon,
            usedSince: .distantPast,
            limit: 5
        )

        #expect(Set(suggestions.map(\.grams)) == [150, 200])
    }

    @Test(arguments: Kind.allCases)
    func oneSuggestionTracksMultiplePeriods(_ kind: Kind) async throws {
        let store = try kind.make()
        try await store.record(makeSuggestionMeal(name: "Yogurt", day: 10), period: .breakfast)
        try await store.record(makeSuggestionMeal(name: "Yogurt", day: 11), period: .afternoon)

        let breakfast = try await store.fetchSuggestions(
            for: .breakfast,
            usedSince: .distantPast,
            limit: 5
        )
        let afternoon = try await store.fetchSuggestions(
            for: .afternoon,
            usedSince: .distantPast,
            limit: 5
        )

        try #require(breakfast.count == 1 && afternoon.count == 1)
        #expect(breakfast[0].id == afternoon[0].id)
        #expect(breakfast[0].count(for: .breakfast) == 1)
        #expect(afternoon[0].count(for: .afternoon) == 1)
    }

    @Test(arguments: Kind.allCases)
    func deleteRemovesSuggestion(_ kind: Kind) async throws {
        let store = try kind.make()
        try await store.record(makeSuggestionMeal(name: "Seasonal fruit"), period: .afternoon)
        let suggestion = try #require(try await store.fetchSuggestions(
            for: .afternoon,
            usedSince: .distantPast,
            limit: 5
        ).first)

        try await store.delete(id: suggestion.id)

        let remaining = try await store.fetchSuggestions(
            for: .afternoon,
            usedSince: .distantPast,
            limit: 5
        )
        #expect(remaining.isEmpty)
    }
}

private func makeSuggestionMeal(
    name: String,
    grams: Int = 100,
    kcal: Int = 200,
    day: Int = 14
) -> Meal {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let date = calendar.date(from: DateComponents(
        year: 2026,
        month: 6,
        day: day,
        hour: 12
    ))!
    return Meal(name: name, grams: grams, kcal: kcal, createdAt: date)
}
