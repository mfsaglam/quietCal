import Testing
import Foundation
@testable import QuietCal

@Suite("Meal CSV")
struct MealCSVTests {

    @Test func emptyArrayProducesHeaderOnly() {
        let meals: [Meal] = []
        #expect(meals.csvString == "date,time,name,grams,kcal")
    }

    @Test func singleMealProducesHeaderAndRow() {
        let date = dateAt(year: 2026, month: 6, day: 15, hour: 8, minute: 15)
        let meals = [Meal(name: "Apple", grams: 180, kcal: 95, createdAt: date)]

        let csv = meals.csvString
        let lines = csv.split(separator: "\n")

        #expect(lines.count == 2)
        #expect(lines[0] == "date,time,name,grams,kcal")
        #expect(lines[1] == "2026-06-15,08:15:00,Apple,180,95")
    }

    @Test func nameWithCommaIsQuoted() {
        let date = dateAt(year: 2026, month: 6, day: 15, hour: 12, minute: 0)
        let meals = [Meal(name: "Apple, sliced", grams: 100, kcal: 50, createdAt: date)]

        let csv = meals.csvString
        let lines = csv.split(separator: "\n")
        #expect(lines[1] == "2026-06-15,12:00:00,\"Apple, sliced\",100,50")
    }

    @Test func nameWithQuoteIsDoubledAndQuoted() {
        let date = dateAt(year: 2026, month: 6, day: 15, hour: 12, minute: 0)
        let meals = [Meal(name: "Tom \"the\" salad", grams: 100, kcal: 50, createdAt: date)]

        let csv = meals.csvString
        let lines = csv.split(separator: "\n")
        #expect(lines[1] == "2026-06-15,12:00:00,\"Tom \"\"the\"\" salad\",100,50")
    }

    @Test func multipleMealsProduceOneRowEach() {
        let meals = [
            Meal(name: "A", grams: 100, kcal: 100,
                 createdAt: dateAt(year: 2026, month: 6, day: 15, hour: 8, minute: 0)),
            Meal(name: "B", grams: 200, kcal: 300,
                 createdAt: dateAt(year: 2026, month: 6, day: 15, hour: 12, minute: 30))
        ]
        let lines = meals.csvString.split(separator: "\n")
        #expect(lines.count == 3)
    }
}

private func dateAt(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = 0
    return Calendar.current.date(from: components)!
}
