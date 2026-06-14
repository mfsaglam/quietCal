import Testing
import Foundation
import SwiftData
@testable import QuietCal

@Suite("MealStore")
struct MealStoreTests {

    enum Kind: String, CaseIterable, Sendable, CustomStringConvertible {
        case inMemory
        case swiftData

        var description: String { rawValue }

        func make() throws -> any MealStore {
            switch self {
            case .inMemory:
                return InMemoryMealStore(meals: [])
            case .swiftData:
                let container = try ModelContainer(
                    for: MealEntity.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
                return SwiftDataMealStore(modelContainer: container)
            }
        }
    }

    @Test(arguments: Kind.allCases)
    func emptyStoreReturnsEmpty(_ kind: Kind) async throws {
        let store = try kind.make()
        let result = try await store.fetchMeals(in: dayInterval(2026, 6, 14))
        #expect(result.isEmpty)
    }

    @Test(arguments: Kind.allCases)
    func savedMealRoundTripsAllFields(_ kind: Kind) async throws {
        let store = try kind.make()
        let createdAt = dateAt(2026, 6, 14, 10, 30)
        let meal = makeMeal(name: "Apple", grams: 150, kcal: 80, createdAt: createdAt)

        try await store.save(meal)
        let result = try await store.fetchMeals(in: dayInterval(2026, 6, 14))

        try #require(result.count == 1)
        let fetched = result[0]
        #expect(fetched.id == meal.id)
        #expect(fetched.name == "Apple")
        #expect(fetched.grams == 150)
        #expect(fetched.kcal == 80)
        #expect(fetched.createdAt == createdAt)
    }

    @Test(arguments: Kind.allCases)
    func mealsOutsideIntervalAreExcluded(_ kind: Kind) async throws {
        let store = try kind.make()
        try await store.save(makeMeal(name: "Yesterday", createdAt: dateAt(2026, 6, 13, 12)))
        try await store.save(makeMeal(name: "Today", createdAt: dateAt(2026, 6, 14, 12)))
        try await store.save(makeMeal(name: "Tomorrow", createdAt: dateAt(2026, 6, 15, 12)))

        let result = try await store.fetchMeals(in: dayInterval(2026, 6, 14))

        #expect(result.map(\.name) == ["Today"])
    }

    @Test(arguments: Kind.allCases)
    func intervalIsHalfOpen(_ kind: Kind) async throws {
        let store = try kind.make()
        let interval = dayInterval(2026, 6, 14)
        try await store.save(makeMeal(name: "AtStart", createdAt: interval.start))
        try await store.save(makeMeal(name: "AtEnd", createdAt: interval.end))

        let result = try await store.fetchMeals(in: interval)

        #expect(result.map(\.name) == ["AtStart"])
    }

    @Test(arguments: Kind.allCases)
    func resultsSortedAscendingByCreatedAt(_ kind: Kind) async throws {
        let store = try kind.make()
        try await store.save(makeMeal(name: "Lunch", createdAt: dateAt(2026, 6, 14, 12, 30)))
        try await store.save(makeMeal(name: "Dinner", createdAt: dateAt(2026, 6, 14, 19, 0)))
        try await store.save(makeMeal(name: "Breakfast", createdAt: dateAt(2026, 6, 14, 8, 0)))

        let result = try await store.fetchMeals(in: dayInterval(2026, 6, 14))

        #expect(result.map(\.name) == ["Breakfast", "Lunch", "Dinner"])
    }

    @Test(arguments: Kind.allCases)
    func deleteRemovesOnlyMatchingMeal(_ kind: Kind) async throws {
        let store = try kind.make()
        let a = makeMeal(name: "A", createdAt: dateAt(2026, 6, 14, 8))
        let b = makeMeal(name: "B", createdAt: dateAt(2026, 6, 14, 12))
        try await store.save(a)
        try await store.save(b)

        try await store.delete(a)
        let result = try await store.fetchMeals(in: dayInterval(2026, 6, 14))

        #expect(result.map(\.id) == [b.id])
    }

    @Test(arguments: Kind.allCases)
    func deleteUnknownMealIsNoOp(_ kind: Kind) async throws {
        let store = try kind.make()
        let saved = makeMeal(name: "Saved", createdAt: dateAt(2026, 6, 14, 12))
        try await store.save(saved)

        let unknown = makeMeal(name: "Unknown", createdAt: dateAt(2026, 6, 14, 12))
        try await store.delete(unknown)
        let result = try await store.fetchMeals(in: dayInterval(2026, 6, 14))

        #expect(result.map(\.id) == [saved.id])
    }
}

// MARK: - Helpers

private let utcCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

private func makeMeal(
    id: UUID = UUID(),
    name: String = "Test",
    grams: Int = 100,
    kcal: Int = 200,
    createdAt: Date = Date()
) -> Meal {
    Meal(id: id, name: name, grams: grams, kcal: kcal, createdAt: createdAt)
}

private func dateAt(
    _ year: Int,
    _ month: Int,
    _ day: Int,
    _ hour: Int = 12,
    _ minute: Int = 0
) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    return utcCalendar.date(from: components)!
}

private func dayInterval(_ year: Int, _ month: Int, _ day: Int) -> DateInterval {
    let date = dateAt(year, month, day, 12, 0)
    return utcCalendar.dateInterval(of: .day, for: date)!
}
