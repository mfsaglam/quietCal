import Foundation

nonisolated struct DayTotal: Hashable, Sendable, Identifiable {
    let date: Date  // start of the day in the supplied calendar
    let kcal: Int
    let mealCount: Int

    var id: Date { date }
}

extension Array where Element == Meal {
    /// Groups meals by calendar day and returns one ``DayTotal`` per day with
    /// meals in this array, sorted ascending by date.
    func dailyTotals(calendar: Calendar = .current) -> [DayTotal] {
        let grouped = Dictionary(grouping: self) {
            calendar.startOfDay(for: $0.createdAt)
        }
        return grouped
            .map { (date, meals) in
                DayTotal(
                    date: date,
                    kcal: meals.reduce(0) { $0 + $1.kcal },
                    mealCount: meals.count
                )
            }
            .sorted { $0.date < $1.date }
    }
}
