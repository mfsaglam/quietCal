import Foundation
import Testing
@testable import QuietCal

@Suite("LogMealIntent")
struct LogMealIntentTests {
    @Test func successfulEstimateSavesCompleteMeal() async throws {
        let store = InMemoryMealStore(meals: [])
        let estimator = TestCalorieEstimator()
        estimator.calories = 350
        let service = LogMealIntentService(
            estimator: estimator,
            mealStore: store,
            suggestionStore: nil,
            now: { Date(timeIntervalSince1970: 1_000) }
        )

        let meal = try await service.log(phrase: "200 grams of salad")

        #expect(meal.name == "salad")
        #expect(meal.grams == 200)
        #expect(meal.kcal == 350)
        let saved = try await store.fetchMeals(
            in: DateInterval(start: .distantPast, end: .distantFuture)
        )
        #expect(saved.count == 1)
    }

    @Test func failedEstimateDoesNotSaveMeal() async throws {
        let store = InMemoryMealStore(meals: [])
        let estimator = TestCalorieEstimator()
        estimator.error = TestEstimatorError()
        let service = LogMealIntentService(
            estimator: estimator,
            mealStore: store,
            suggestionStore: nil
        )

        do {
            _ = try await service.log(phrase: "200 grams of unknown food")
            Issue.record("Expected estimation failure")
        } catch let error as LogMealError {
            if case .estimationFailed = error {
                // Expected localized App Intent failure.
            } else {
                Issue.record("Unexpected intent error: \(error)")
            }
        }

        let saved = try await store.fetchMeals(
            in: DateInterval(start: .distantPast, end: .distantFuture)
        )
        #expect(saved.isEmpty)
    }
}
