import Testing
import Foundation
@testable import QuietCal

@Suite("HistoryViewModel")
@MainActor
struct HistoryViewModelTests {

    private func makeViewModel(
        meals: [Meal] = [],
        target: Int = 2000
    ) -> HistoryViewModel {
        HistoryViewModel(
            mealStore: InMemoryMealStore(meals: meals),
            settingsStore: InMemorySettingsStore(target: target)
        )
    }

    // MARK: - load() / target

    @Test func loadReadsTargetFromSettingsStore() async {
        let vm = makeViewModel(target: 2400)
        await vm.load()
        #expect(vm.target == 2400)
    }

    // MARK: - week

    @Test func weekHasExactlySevenEntries() async {
        let vm = makeViewModel()
        await vm.load()
        #expect(vm.week.count == 7)
    }

    @Test func weekFillsEmptyDaysWithZeroKcal() async {
        let vm = makeViewModel()
        await vm.load()
        #expect(vm.week.allSatisfy { $0.kcal == 0 })
        #expect(vm.week.allSatisfy { $0.mealCount == 0 })
    }

    @Test func weekIsOrderedOldestToToday() async throws {
        let vm = makeViewModel()
        await vm.load()

        try #require(vm.week.count == 7)
        for index in 1..<vm.week.count {
            #expect(vm.week[index].date > vm.week[index - 1].date)
        }
        #expect(vm.week.last?.isToday == true)
    }

    @Test func weekPopulatesKcalForDaysWithMeals() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let meals = [
            Meal(name: "T", grams: 100, kcal: 1500,
                 createdAt: today.addingTimeInterval(8 * 3600)),
            Meal(name: "Y", grams: 100, kcal: 1800,
                 createdAt: yesterday.addingTimeInterval(8 * 3600))
        ]
        let vm = makeViewModel(meals: meals)
        await vm.load()

        try #require(vm.week.count == 7)
        #expect(vm.week.last?.kcal == 1500)
        #expect(vm.week[vm.week.count - 2].kcal == 1800)
    }

    // MARK: - averageKcal

    @Test func averageKcalIsZeroWhenAllDaysEmpty() async {
        let vm = makeViewModel()
        await vm.load()
        #expect(vm.averageKcal == 0)
    }

    @Test func averageKcalExcludesZeroDays() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let meals = [
            Meal(name: "T", grams: 100, kcal: 1800,
                 createdAt: today.addingTimeInterval(8 * 3600)),
            Meal(name: "Y", grams: 100, kcal: 2200,
                 createdAt: yesterday.addingTimeInterval(8 * 3600))
        ]
        let vm = makeViewModel(meals: meals)
        await vm.load()

        // (1800 + 2200) / 2 = 2000
        #expect(vm.averageKcal == 2000)
    }

    // MARK: - earlier

    @Test func earlierIsEmptyWhenNoOldMeals() async {
        let vm = makeViewModel()
        await vm.load()
        #expect(vm.earlier.isEmpty)
    }

    @Test func earlierIsNewestFirst() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let day10 = calendar.date(byAdding: .day, value: -10, to: today)!
        let day15 = calendar.date(byAdding: .day, value: -15, to: today)!
        let day20 = calendar.date(byAdding: .day, value: -20, to: today)!
        let meals = [
            Meal(name: "10", grams: 100, kcal: 1500,
                 createdAt: day10.addingTimeInterval(8 * 3600)),
            Meal(name: "20", grams: 100, kcal: 1700,
                 createdAt: day20.addingTimeInterval(8 * 3600)),
            Meal(name: "15", grams: 100, kcal: 1600,
                 createdAt: day15.addingTimeInterval(8 * 3600))
        ]
        let vm = makeViewModel(meals: meals)
        await vm.load()

        #expect(vm.earlier.map(\.kcal) == [1500, 1600, 1700])
    }

    @Test func earlierExcludesMealsFromThisWeek() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: today)!
        let meals = [
            Meal(name: "Recent", grams: 100, kcal: 1500,
                 createdAt: twoDaysAgo.addingTimeInterval(8 * 3600)),
            Meal(name: "Earlier", grams: 100, kcal: 1700,
                 createdAt: tenDaysAgo.addingTimeInterval(8 * 3600))
        ]
        let vm = makeViewModel(meals: meals)
        await vm.load()

        // recent goes into week, not earlier
        #expect(vm.earlier.map(\.kcal) == [1700])
    }
}
