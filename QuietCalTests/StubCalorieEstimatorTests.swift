import Testing
import Foundation
@testable import QuietCal

@Suite("StubCalorieEstimator")
struct StubCalorieEstimatorTests {

    @Test func returnsKcalProportionalToGrams() async throws {
        let estimator = StubCalorieEstimator(delay: .zero, caloriesPerGram: 2.5)
        let kcal = try await estimator.estimate(name: "Anything", grams: 100)
        #expect(kcal == 250)
    }

    @Test func ignoresName() async throws {
        let estimator = StubCalorieEstimator(delay: .zero, caloriesPerGram: 1.0)
        let kcalA = try await estimator.estimate(name: "Apple", grams: 100)
        let kcalB = try await estimator.estimate(name: "Burger", grams: 100)
        #expect(kcalA == kcalB)
    }

    @Test func zeroGramsReturnsZeroKcal() async throws {
        let estimator = StubCalorieEstimator(delay: .zero, caloriesPerGram: 1.5)
        let kcal = try await estimator.estimate(name: "Anything", grams: 0)
        #expect(kcal == 0)
    }

    @Test func truncatesToInt() async throws {
        let estimator = StubCalorieEstimator(delay: .zero, caloriesPerGram: 1.5)
        // 13 * 1.5 = 19.5 → Int truncates to 19
        let kcal = try await estimator.estimate(name: "X", grams: 13)
        #expect(kcal == 19)
    }
}
