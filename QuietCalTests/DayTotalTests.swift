import Testing
import Foundation
@testable import QuietCal

@Suite("DayTotal grouping")
struct DayTotalTests {

    @Test func emptyArrayProducesEmptyTotals() {
        let meals: [Meal] = []
        #expect(meals.dailyTotals(calendar: utcCalendar).isEmpty)
    }

    @Test func singleMealProducesSingleTotal() throws {
        let meals = [
            Meal(name: "X", grams: 100, kcal: 250, createdAt: dateAt(2026, 6, 15, 8, 0))
        ]
        let totals = meals.dailyTotals(calendar: utcCalendar)

        try #require(totals.count == 1)
        #expect(totals[0].kcal == 250)
        #expect(totals[0].mealCount == 1)
        #expect(totals[0].date == utcCalendar.startOfDay(for: dateAt(2026, 6, 15, 8, 0)))
    }

    @Test func multipleMealsSameDayAreSummed() throws {
        let meals = [
            Meal(name: "A", grams: 100, kcal: 200, createdAt: dateAt(2026, 6, 15, 8, 0)),
            Meal(name: "B", grams: 100, kcal: 300, createdAt: dateAt(2026, 6, 15, 12, 0)),
            Meal(name: "C", grams: 100, kcal: 100, createdAt: dateAt(2026, 6, 15, 18, 0)),
        ]
        let totals = meals.dailyTotals(calendar: utcCalendar)

        try #require(totals.count == 1)
        #expect(totals[0].kcal == 600)
        #expect(totals[0].mealCount == 3)
    }

    @Test func mealsAcrossDaysProduceOneTotalPerDay() {
        let meals = [
            Meal(name: "D1", grams: 100, kcal: 200, createdAt: dateAt(2026, 6, 13, 12)),
            Meal(name: "D2", grams: 100, kcal: 300, createdAt: dateAt(2026, 6, 14, 12)),
            Meal(name: "D3", grams: 100, kcal: 400, createdAt: dateAt(2026, 6, 15, 12)),
        ]
        let totals = meals.dailyTotals(calendar: utcCalendar)

        #expect(totals.count == 3)
        #expect(totals.map(\.kcal) == [200, 300, 400])
        #expect(totals.map(\.mealCount) == [1, 1, 1])
    }

    @Test func totalsSortedAscendingByDate() throws {
        let meals = [
            Meal(name: "Late", grams: 100, kcal: 100, createdAt: dateAt(2026, 6, 15, 12)),
            Meal(name: "Early", grams: 100, kcal: 100, createdAt: dateAt(2026, 6, 13, 12)),
            Meal(name: "Mid", grams: 100, kcal: 100, createdAt: dateAt(2026, 6, 14, 12)),
        ]
        let totals = meals.dailyTotals(calendar: utcCalendar)

        try #require(totals.count == 3)
        #expect(totals[0].date < totals[1].date)
        #expect(totals[1].date < totals[2].date)
    }

    @Test func datesAreNormalizedToStartOfDay() throws {
        let meals = [
            Meal(name: "Morning", grams: 100, kcal: 200, createdAt: dateAt(2026, 6, 15, 8, 30)),
            Meal(name: "Evening", grams: 100, kcal: 300, createdAt: dateAt(2026, 6, 15, 21, 15)),
        ]
        let totals = meals.dailyTotals(calendar: utcCalendar)

        try #require(totals.count == 1)
        #expect(totals[0].date == utcCalendar.startOfDay(for: dateAt(2026, 6, 15, 0)))
    }

    @Test func daysWithoutMealsAreOmitted() {
        // June 13 and June 15 have meals; June 14 has none. Result is 2 totals, no gap entry.
        let meals = [
            Meal(name: "D1", grams: 100, kcal: 100, createdAt: dateAt(2026, 6, 13, 12)),
            Meal(name: "D3", grams: 100, kcal: 100, createdAt: dateAt(2026, 6, 15, 12)),
        ]
        let totals = meals.dailyTotals(calendar: utcCalendar)
        #expect(totals.count == 2)
    }
}

// MARK: - Helpers

private let utcCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

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
