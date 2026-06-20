import Testing
import Foundation
@testable import QuietCal

@Suite("AddMealViewModel")
@MainActor
struct AddMealViewModelTests {

    private func makeViewModel(
        store: any MealStore = InMemoryMealStore(meals: []),
        estimator: TestCalorieEstimator = TestCalorieEstimator(),
        defaultUnit: WeightUnit = .g
    ) -> AddMealViewModel {
        AddMealViewModel(
            mealStore: store,
            calorieEstimator: estimator,
            defaultUnit: defaultUnit
        )
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
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        let vm = makeViewModel(store: store, estimator: estimator)
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
}

private func anyInterval() -> DateInterval {
    let now = Date()
    let calendar = Calendar.current
    return calendar.dateInterval(of: .day, for: now)
        ?? DateInterval(start: now, duration: 86400)
}
