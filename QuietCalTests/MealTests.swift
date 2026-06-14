import Testing
import Foundation
@testable import QuietCal

@Suite("Meal")
struct MealTests {

    @Test func explicitIdIsPreserved() {
        let id = UUID()
        let meal = Meal(id: id, name: "X", grams: 100, kcal: 100, createdAt: Date())
        #expect(meal.id == id)
    }

    @Test func defaultIdIsUnique() {
        let a = Meal(name: "X", grams: 100, kcal: 100, createdAt: Date())
        let b = Meal(name: "X", grams: 100, kcal: 100, createdAt: Date())
        #expect(a.id != b.id)
    }

    @Test func timeStringFormatsHourAndMinute() {
        let date = dateAt(hour: 14, minute: 30)
        let meal = Meal(name: "X", grams: 100, kcal: 100, createdAt: date)
        #expect(meal.timeString == "14:30")
    }

    @Test func timeStringPadsLeadingZero() {
        let date = dateAt(hour: 8, minute: 5)
        let meal = Meal(name: "X", grams: 100, kcal: 100, createdAt: date)
        #expect(meal.timeString == "08:05")
    }
}

private func dateAt(hour: Int, minute: Int) -> Date {
    var components = DateComponents()
    components.year = 2026
    components.month = 6
    components.day = 15
    components.hour = hour
    components.minute = minute
    return Calendar.current.date(from: components)!
}
