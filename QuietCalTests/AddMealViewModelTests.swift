import Testing
import Foundation
@testable import QuietCal

@Suite("AddMealViewModel")
@MainActor
struct AddMealViewModelTests {

    private func makeViewModel(
        store: any MealStore = InMemoryMealStore(meals: []),
        suggestionStore: any SuggestionStore = InMemorySuggestionStore(),
        estimator: TestCalorieEstimator = TestCalorieEstimator(),
        defaultUnit: WeightUnit = .g,
        calendar: Calendar = .autoupdatingCurrent,
        now: @escaping () -> Date = Date.init
    ) -> AddMealViewModel {
        AddMealViewModel(
            mealStore: store,
            suggestionStore: suggestionStore,
            calorieEstimator: estimator,
            defaultUnit: defaultUnit,
            calendar: calendar,
            now: now
        )
    }

    @Test func ingredientsUpdateAndClearImmediatelyWhenDishNameChanges() async {
        let estimator = TestCalorieEstimator()
        estimator.ingredients = [EstimatedIngredient(name: "Chicken", grams: 100, calories: 165)]
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Chicken salad"
        vm.amount = "200"
        await vm.estimate()
        #expect(vm.estimatedIngredients == estimator.ingredients)

        vm.name = "Tofu salad"
        #expect(vm.estimatedIngredients.isEmpty)
        #expect(!vm.canSave)
        estimator.ingredients = [EstimatedIngredient(name: "Tofu", grams: 100, calories: 76)]
        await vm.estimate()
        #expect(vm.estimatedIngredients == estimator.ingredients)

        estimator.error = TestEstimatorError()
        await vm.retry()
        #expect(vm.estimatedIngredients.isEmpty)
    }

    @Test func defaultUnitIsApplied() {
        let vm = makeViewModel(defaultUnit: .oz)
        #expect(vm.unit == .oz)
    }

    @Test func initialStateIsEmpty() {
        let vm = makeViewModel()
        #expect(vm.state == .empty)
        #expect(!vm.canSave)
    }

    @Test func stateIsEstimatingDuringEstimateCall() async {
        let estimator = TestCalorieEstimator()
        estimator.delay = .milliseconds(120)
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Salad"
        vm.amount = "200"

        let task = Task { await vm.estimate() }
        try? await Task.sleep(for: .milliseconds(40))
        #expect(vm.state == .estimating)
        await task.value
        #expect(vm.state == .estimated)
    }

    @Test func estimatePopulatesCalories() async {
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Salad"
        vm.amount = "200"

        await vm.estimate()

        #expect(vm.estimatedCalories == 350)
        #expect(vm.state == .estimated)
    }

    @Test func estimateSkippedWhenNameIsEmpty() async {
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        let vm = makeViewModel(estimator: estimator)
        vm.amount = "200"

        await vm.estimate()

        #expect(estimator.callCount == 0)
        #expect(vm.estimatedCalories == nil)
    }

    @Test func estimateSkippedWhenAmountIsZero() async {
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Salad"
        vm.amount = "0"

        await vm.estimate()

        #expect(estimator.callCount == 0)
        #expect(vm.estimatedCalories == nil)
    }

    @Test func estimateClearsCaloriesWhenInputBecomesInvalid() async {
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Salad"
        vm.amount = "200"

        await vm.estimate()
        #expect(vm.estimatedCalories == 350)

        vm.name = ""
        await vm.estimate()
        #expect(vm.estimatedCalories == nil)
    }

    @Test func estimateEntersFailedStateOnError() async {
        let estimator = TestCalorieEstimator()
        estimator.error = TestEstimatorError()
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Salad"
        vm.amount = "200"

        await vm.estimate()

        #expect(vm.estimatedCalories == nil)
        #expect(vm.state == .failed)
        #expect(vm.errorMessage != nil)
        #expect(!vm.canSave)
    }

    @Test func retryRecoversFromFailedState() async {
        let estimator = TestCalorieEstimator()
        estimator.error = TestEstimatorError()
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Salad"
        vm.amount = "200"

        await vm.estimate()
        #expect(vm.state == .failed)

        estimator.error = nil
        estimator.calories = 350
        await vm.retry()

        #expect(vm.state == .estimated)
        #expect(vm.estimatedCalories == 350)
        #expect(vm.errorMessage == nil)
    }

    @Test func staleEstimateIsDiscardedWhenNameChangesMidCall() async {
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        estimator.delay = .milliseconds(100)
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Salad"
        vm.amount = "200"

        let task = Task { await vm.estimate() }
        try? await Task.sleep(for: .milliseconds(30))
        vm.name = "Sandwich"
        await task.value

        #expect(vm.estimatedCalories == nil)
    }

    @Test func canSaveOnlyWhenEstimated() async {
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        let vm = makeViewModel(estimator: estimator)
        vm.name = "Salad"
        vm.amount = "200"

        #expect(!vm.canSave)

        await vm.estimate()

        #expect(vm.canSave)
    }

    @Test func savePersistsMealWithExpectedFields() async throws {
        let store = InMemoryMealStore(meals: [])
        let suggestionStore = InMemorySuggestionStore()
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        let vm = makeViewModel(
            store: store,
            suggestionStore: suggestionStore,
            estimator: estimator
        )
        vm.name = "  Salad  "
        vm.amount = "200"

        await vm.estimate()
        await vm.save()

        let interval = anyInterval()
        let meals = try await store.fetchMeals(in: interval)
        try #require(meals.count == 1)
        let saved = meals[0]
        #expect(saved.name == "Salad")
        #expect(saved.grams == 200)
        #expect(saved.kcal == 350)
        let period = MealPeriod(date: saved.createdAt, calendar: .autoupdatingCurrent)
        let storedSuggestions = try await suggestionStore.fetchSuggestions(
            for: period,
            usedSince: .distantPast,
            limit: 5
        )
        #expect(storedSuggestions.count == 1)
        #expect(storedSuggestions.first?.name == "Salad")
    }

    @Test func saveDoesNothingWhenNotEstimated() async throws {
        let store = InMemoryMealStore(meals: [])
        let vm = makeViewModel(store: store)
        vm.name = "Salad"
        vm.amount = "200"

        await vm.save()

        let meals = try await store.fetchMeals(in: anyInterval())
        #expect(meals.isEmpty)
    }

    @Test func unitOzConvertsToGramsAtEstimateAndSave() async throws {
        let store = InMemoryMealStore(meals: [])
        let estimator = TestCalorieEstimator()
        estimator.calories = 100
        let vm = makeViewModel(store: store, estimator: estimator)
        vm.name = "Apple"
        vm.amount = "10"
        vm.unit = .oz

        await vm.estimate()
        await vm.save()

        // 10 oz * 28.3495 = 283
        #expect(estimator.lastGrams == 283)

        let meals = try await store.fetchMeals(in: anyInterval())
        #expect(meals.first?.grams == 283)
    }

    @Test func unitLbConvertsToGramsAtEstimateAndSave() async throws {
        let store = InMemoryMealStore(meals: [])
        let estimator = TestCalorieEstimator()
        estimator.calories = 100
        let vm = makeViewModel(store: store, estimator: estimator)
        vm.name = "Steak"
        vm.amount = "1"
        vm.unit = .lb

        await vm.estimate()
        await vm.save()

        // 1 lb * 453.592 = 453
        #expect(estimator.lastGrams == 453)

        let meals = try await store.fetchMeals(in: anyInterval())
        #expect(meals.first?.grams == 453)
    }

    // MARK: - Time-based quick log suggestions

    @Test func suggestionsUseCurrentPeriodAndRankByFrequencyThenRecency() async throws {
        let calendar = fixedCalendar()
        let now = fixedDate(day: 27, hour: 8, calendar: calendar)
        let meals = [
            Meal(name: "Oatmeal", grams: 220, kcal: 310,
                 createdAt: fixedDate(day: 24, hour: 8, calendar: calendar)),
            Meal(name: " oatmeal ", grams: 220, kcal: 315,
                 createdAt: fixedDate(day: 25, hour: 9, calendar: calendar)),
            Meal(name: "OATMEAL", grams: 220, kcal: 320,
                 createdAt: fixedDate(day: 26, hour: 7, calendar: calendar)),
            Meal(name: "Eggs", grams: 120, kcal: 185,
                 createdAt: fixedDate(day: 25, hour: 8, calendar: calendar)),
            Meal(name: "Eggs", grams: 120, kcal: 185,
                 createdAt: fixedDate(day: 26, hour: 8, calendar: calendar)),
            Meal(name: "Chicken salad", grams: 300, kcal: 450,
                 createdAt: fixedDate(day: 26, hour: 12, calendar: calendar)),
        ]
        let suggestionStore = InMemorySuggestionStore()
        for meal in meals {
            try await suggestionStore.record(
                meal,
                period: MealPeriod(date: meal.createdAt, calendar: calendar)
            )
        }
        let vm = makeViewModel(
            suggestionStore: suggestionStore,
            calendar: calendar,
            now: { now }
        )

        await vm.loadSuggestions()

        #expect(vm.suggestionPeriodLabel == "Breakfast")
        #expect(vm.suggestions.map(\.name) == ["OATMEAL", "Eggs"])
        #expect(vm.suggestions.map(\.occurrenceCount) == [3, 2])
        #expect(vm.suggestions.first?.kcal == 320)
    }

    @Test func suggestionPeriodChangesAtLunchBoundary() async {
        let calendar = fixedCalendar()
        let now = fixedDate(day: 27, hour: 11, calendar: calendar)
        let meals = [
            Meal(name: "Breakfast", grams: 100, kcal: 100,
                 createdAt: fixedDate(day: 26, hour: 10, calendar: calendar)),
            Meal(name: "Lunch", grams: 200, kcal: 200,
                 createdAt: fixedDate(day: 26, hour: 11, calendar: calendar)),
        ]
        let suggestionStore = InMemorySuggestionStore()
        for meal in meals {
            try? await suggestionStore.record(
                meal,
                period: MealPeriod(date: meal.createdAt, calendar: calendar)
            )
        }
        let vm = makeViewModel(
            suggestionStore: suggestionStore,
            calendar: calendar,
            now: { now }
        )

        await vm.loadSuggestions()

        #expect(vm.suggestionPeriodLabel == "Lunch")
        #expect(vm.suggestions.map(\.name) == ["Lunch"])
    }

    @Test func quickLogRepeatsHistoricalValuesWithoutCallingEstimator() async throws {
        let calendar = fixedCalendar()
        let now = fixedDate(day: 27, hour: 8, calendar: calendar)
        let previous = Meal(
            name: "Oatmeal",
            grams: 220,
            kcal: 310,
            createdAt: fixedDate(day: 26, hour: 8, calendar: calendar)
        )
        let store = InMemoryMealStore(meals: [previous])
        let suggestionStore = InMemorySuggestionStore()
        try await suggestionStore.record(previous, period: .breakfast)
        let estimator = TestCalorieEstimator()
        let vm = makeViewModel(
            store: store,
            suggestionStore: suggestionStore,
            estimator: estimator,
            calendar: calendar,
            now: { now }
        )
        await vm.loadSuggestions()
        let suggestion = try #require(vm.suggestions.first)

        let outcome = await vm.logSuggestion(suggestion)

        #expect(outcome == .saved)
        #expect(estimator.callCount == 0)
        let today = try #require(calendar.dateInterval(of: .day, for: now))
        let logged = try await store.fetchMeals(in: today)
        #expect(logged.count == 1)
        #expect(logged.first?.name == "Oatmeal")
        #expect(logged.first?.grams == 220)
        #expect(logged.first?.kcal == 310)
        #expect(logged.first?.createdAt == now)
        let updatedSuggestions = try await suggestionStore.fetchSuggestions(
            for: .breakfast,
            usedSince: .distantPast,
            limit: 5
        )
        #expect(updatedSuggestions.count == 1)
        #expect(updatedSuggestions.first?.count(for: .breakfast) == 2)
    }

    @Test func suggestionArrowCopiesOnlyNameAndLeavesAmountEmpty() async throws {
        let calendar = fixedCalendar()
        let now = fixedDate(day: 27, hour: 8, calendar: calendar)
        let previous = Meal(
            name: "Oatmeal",
            grams: 220,
            kcal: 310,
            createdAt: fixedDate(day: 26, hour: 8, calendar: calendar)
        )
        let suggestionStore = InMemorySuggestionStore()
        try await suggestionStore.record(previous, period: .breakfast)
        let vm = makeViewModel(
            suggestionStore: suggestionStore,
            calendar: calendar,
            now: { now }
        )
        await vm.loadSuggestions()
        let suggestion = try #require(vm.suggestions.first)
        vm.amount = "999"

        vm.useSuggestionName(suggestion)

        #expect(vm.name == "Oatmeal")
        #expect(vm.amount.isEmpty)
        #expect(!vm.shouldShowSuggestions)
        #expect(!vm.canSave)
    }

    @Test func deletingSuggestionRemovesSuggestionButPreservesMealHistory() async throws {
        let calendar = fixedCalendar()
        let now = fixedDate(day: 27, hour: 8, calendar: calendar)
        let meals = [
            Meal(name: "Oatmeal", grams: 220, kcal: 310,
                 createdAt: fixedDate(day: 26, hour: 8, calendar: calendar)),
            Meal(name: " oatmeal ", grams: 220, kcal: 315,
                 createdAt: fixedDate(day: 25, hour: 12, calendar: calendar)),
            Meal(name: "OATMEAL", grams: 300, kcal: 400,
                 createdAt: fixedDate(day: 24, hour: 8, calendar: calendar)),
            Meal(name: "Eggs", grams: 120, kcal: 185,
                 createdAt: fixedDate(day: 26, hour: 8, calendar: calendar)),
        ]
        let mealStore = InMemoryMealStore(meals: meals)
        let suggestionStore = InMemorySuggestionStore()
        for meal in meals {
            try await suggestionStore.record(
                meal,
                period: MealPeriod(date: meal.createdAt, calendar: calendar)
            )
        }
        let vm = makeViewModel(
            store: mealStore,
            suggestionStore: suggestionStore,
            calendar: calendar,
            now: { now }
        )
        await vm.loadSuggestions()
        let suggestion = try #require(vm.suggestions.first { $0.name == "Oatmeal" })

        await vm.deleteSuggestion(suggestion)

        #expect(!vm.suggestions.contains { $0.name.normalizedMealName == "oatmeal" && $0.grams == 220 })
        let remainingSuggestions = try await suggestionStore.fetchSuggestions(
            for: .breakfast,
            usedSince: .distantPast,
            limit: 5
        )
        #expect(Set(remainingSuggestions.map(\.name)) == ["OATMEAL", "Eggs"])
        let everything = DateInterval(start: .distantPast, end: .distantFuture)
        let remainingMeals = try await mealStore.fetchMeals(in: everything)
        #expect(remainingMeals.count == meals.count)
        #expect(remainingMeals.map(\.name) == meals.map(\.name))
    }

    // MARK: - Free-tier daily save limit

    private func mealsLoggedToday(_ count: Int) -> [Meal] {
        (0..<count).map { Meal(name: "M\($0)", grams: 100, kcal: 100, createdAt: Date()) }
    }

    private func estimatedViewModel(store: any MealStore, isPro: Bool) async -> AddMealViewModel {
        let estimator = TestCalorieEstimator()
        estimator.calories = 200
        let vm = AddMealViewModel(
            mealStore: store,
            calorieEstimator: estimator,
            entitlements: StaticEntitlement(isPro: isPro)
        )
        vm.name = "Snack"
        vm.amount = "100"
        await vm.estimate()
        return vm
    }

    @Test func freeUserBlockedAtDailyLimit() async throws {
        let store = InMemoryMealStore(meals: mealsLoggedToday(FreeTierLimits.dailyMealLimit))
        let vm = await estimatedViewModel(store: store, isPro: false)

        let outcome = await vm.save()

        #expect(outcome == .blockedByLimit)
        // The meal was not persisted.
        let count = try await store.fetchMeals(in: anyInterval()).count
        #expect(count == FreeTierLimits.dailyMealLimit)
    }

    @Test func freeUserUnderDailyLimitSaves() async throws {
        let store = InMemoryMealStore(meals: mealsLoggedToday(FreeTierLimits.dailyMealLimit - 1))
        let vm = await estimatedViewModel(store: store, isPro: false)

        let outcome = await vm.save()

        #expect(outcome == .saved)
        let count = try await store.fetchMeals(in: anyInterval()).count
        #expect(count == FreeTierLimits.dailyMealLimit)
    }

    @Test func proUserNotBlockedAtDailyLimit() async throws {
        let store = InMemoryMealStore(meals: mealsLoggedToday(FreeTierLimits.dailyMealLimit))
        let vm = await estimatedViewModel(store: store, isPro: true)

        let outcome = await vm.save()

        #expect(outcome == .saved)
        let count = try await store.fetchMeals(in: anyInterval()).count
        #expect(count == FreeTierLimits.dailyMealLimit + 1)
    }
}

private func fixedCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
}

private func fixedDate(day: Int, hour: Int, calendar: Calendar) -> Date {
    calendar.date(from: DateComponents(
        year: 2026,
        month: 9,
        day: day,
        hour: hour,
        minute: 0,
        second: 0
    ))!
}

private func anyInterval() -> DateInterval {
    let now = Date()
    let calendar = Calendar.current
    return calendar.dateInterval(of: .day, for: now)
        ?? DateInterval(start: now, duration: 86400)
}
