import Foundation
import Observation

@MainActor
@Observable
final class HistoryViewModel {
    private static let weekDayCount = 7
    private static let earlierDayCount = 30

    private let mealStore: MealStore
    private let settingsStore: SettingsStore

    var target: Int = 2000
    var week: [DayTotal] = []     // exactly 7 entries, oldest → today, zeros for empty days
    var earlier: [DayTotal] = []  // newest first, only days with meals

    init(mealStore: MealStore, settingsStore: SettingsStore) {
        self.mealStore = mealStore
        self.settingsStore = settingsStore
    }

    func load() async {
        if let loaded = try? await settingsStore.loadTarget() {
            target = loaded
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard
            let weekStart = calendar.date(byAdding: .day, value: -(Self.weekDayCount - 1), to: today),
            let weekEnd = calendar.date(byAdding: .day, value: 1, to: today),
            let earlierStart = calendar.date(byAdding: .day,
                                             value: -(Self.weekDayCount + Self.earlierDayCount - 1),
                                             to: today)
        else { return }

        let weekInterval = DateInterval(start: weekStart, end: weekEnd)
        let earlierInterval = DateInterval(start: earlierStart, end: weekStart)

        let weekMeals = (try? await mealStore.fetchMeals(in: weekInterval)) ?? []
        let earlierMeals = (try? await mealStore.fetchMeals(in: earlierInterval)) ?? []

        let weekTotalsByDay = Dictionary(
            uniqueKeysWithValues: weekMeals.dailyTotals(calendar: calendar).map { ($0.date, $0) }
        )

        week = (0..<Self.weekDayCount).compactMap { offset in
            let dayOffset = offset - (Self.weekDayCount - 1)
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { return nil }
            let dayStart = calendar.startOfDay(for: date)
            return weekTotalsByDay[dayStart] ?? DayTotal(date: dayStart, kcal: 0, mealCount: 0)
        }

        earlier = earlierMeals.dailyTotals(calendar: calendar).reversed()
    }

    var averageKcal: Int {
        let nonEmpty = week.filter { $0.kcal > 0 }
        guard !nonEmpty.isEmpty else { return 0 }
        let total = nonEmpty.reduce(0) { $0 + $1.kcal }
        return total / nonEmpty.count
    }
}
