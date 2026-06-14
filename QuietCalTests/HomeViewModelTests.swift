import Testing
import Foundation
@testable import QuietCal

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    private func makeViewModel(
        mealStore: any MealStore = InMemoryMealStore(meals: []),
        settingsStore: any SettingsStore = InMemorySettingsStore()
    ) -> HomeViewModel {
        HomeViewModel(
            mealStore: mealStore,
            calorieEstimator: TestCalorieEstimator(),
            settingsStore: settingsStore
        )
    }

    // MARK: - Initial state

    @Test func initialStateBeforeLoad() {
        let vm = makeViewModel()
        #expect(vm.target == 2000)
        #expect(vm.meals.isEmpty)
        #expect(vm.eaten == 0)
        #expect(vm.remaining == 2000)
        #expect(vm.progress == 0)
        #expect(!vm.isOverTarget)
        #expect(vm.overageProgress == 0)
    }

    // MARK: - load()

    @Test func loadReadsTargetFromSettingsStore() async throws {
        let settings = InMemorySettingsStore(target: 2400)
        let vm = makeViewModel(settingsStore: settings)

        await vm.load()

        #expect(vm.target == 2400)
    }

    @Test func loadFetchesOnlyTodaysMeals() async throws {
        let yesterday = Date().addingTimeInterval(-86400)
        let store = InMemoryMealStore(meals: [
            Meal(name: "Yesterday", grams: 100, kcal: 100, createdAt: yesterday),
            Meal(name: "Today", grams: 100, kcal: 200, createdAt: Date())
        ])
        let vm = makeViewModel(mealStore: store)

        await vm.load()

        #expect(vm.meals.map(\.name) == ["Today"])
    }

    @Test func loadReturnsEmptyMealsWhenStoreEmpty() async throws {
        let vm = makeViewModel(mealStore: InMemoryMealStore(meals: []))
        await vm.load()
        #expect(vm.meals.isEmpty)
    }

    // MARK: - delete()

    @Test func deleteRemovesMealLocallyAndInStore() async throws {
        let meal = Meal(name: "Lunch", grams: 200, kcal: 400, createdAt: Date())
        let store = InMemoryMealStore(meals: [meal])
        let vm = makeViewModel(mealStore: store)
        await vm.load()
        try #require(vm.meals.count == 1)

        await vm.delete(meal)

        #expect(vm.meals.isEmpty)
        let interval = Calendar.current.dateInterval(of: .day, for: Date())!
        let storeMeals = try await store.fetchMeals(in: interval)
        #expect(storeMeals.isEmpty)
    }

    @Test func deleteOnlyRemovesMatchingMeal() async throws {
        let a = Meal(name: "A", grams: 100, kcal: 100, createdAt: Date())
        let b = Meal(name: "B", grams: 100, kcal: 200, createdAt: Date())
        let store = InMemoryMealStore(meals: [a, b])
        let vm = makeViewModel(mealStore: store)
        await vm.load()

        await vm.delete(a)

        #expect(vm.meals.map(\.id) == [b.id])
    }

    // MARK: - Derived properties

    @Test func eatenSumsMealKcal() {
        let vm = makeViewModel()
        vm.meals = [
            Meal(name: "A", grams: 100, kcal: 200, createdAt: Date()),
            Meal(name: "B", grams: 200, kcal: 300, createdAt: Date())
        ]
        #expect(vm.eaten == 500)
    }

    @Test func remainingIsTargetMinusEaten() {
        let vm = makeViewModel()
        vm.target = 2000
        vm.meals = [Meal(name: "A", grams: 100, kcal: 800, createdAt: Date())]
        #expect(vm.remaining == 1200)
    }

    @Test func remainingGoesNegativeWhenOverTarget() {
        let vm = makeViewModel()
        vm.target = 2000
        vm.meals = [Meal(name: "A", grams: 100, kcal: 2500, createdAt: Date())]
        #expect(vm.remaining == -500)
    }

    @Test func progressIsFractionEatenOverTarget() {
        let vm = makeViewModel()
        vm.target = 2000
        vm.meals = [Meal(name: "A", grams: 100, kcal: 1000, createdAt: Date())]
        #expect(vm.progress == 0.5)
    }

    @Test func progressClampsAtOneWhenOverTarget() {
        let vm = makeViewModel()
        vm.target = 2000
        vm.meals = [Meal(name: "A", grams: 100, kcal: 3000, createdAt: Date())]
        #expect(vm.progress == 1.0)
    }

    @Test func isOverTargetReflectsEatenVsTarget() {
        let vm = makeViewModel()
        vm.target = 2000

        vm.meals = [Meal(name: "Under", grams: 100, kcal: 1999, createdAt: Date())]
        #expect(!vm.isOverTarget)

        vm.meals = [Meal(name: "Equal", grams: 100, kcal: 2000, createdAt: Date())]
        #expect(!vm.isOverTarget)

        vm.meals = [Meal(name: "Over", grams: 100, kcal: 2001, createdAt: Date())]
        #expect(vm.isOverTarget)
    }

    @Test func overageProgressIsZeroWhenUnderTarget() {
        let vm = makeViewModel()
        vm.target = 2000
        vm.meals = [Meal(name: "A", grams: 100, kcal: 1000, createdAt: Date())]
        #expect(vm.overageProgress == 0)
    }

    @Test func overageProgressIsFractionOfTarget() {
        let vm = makeViewModel()
        vm.target = 2000
        vm.meals = [Meal(name: "A", grams: 100, kcal: 2500, createdAt: Date())]
        // overage = 500, fraction = 500/2000 = 0.25
        #expect(vm.overageProgress == 0.25)
    }

    @Test func overageProgressClampsAtOne() {
        let vm = makeViewModel()
        vm.target = 2000
        vm.meals = [Meal(name: "A", grams: 100, kcal: 10_000, createdAt: Date())]
        #expect(vm.overageProgress == 1.0)
    }
}
