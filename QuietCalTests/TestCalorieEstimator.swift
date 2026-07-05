import Foundation
@testable import QuietCal

final class TestCalorieEstimator: CalorieEstimating, @unchecked Sendable {
    var source: CalorieEstimationSource = .stub
    var calories: Int = 200
    var confidence: EstimateConfidence = .medium
    var error: Error?
    var delay: Duration = .zero

    private(set) var callCount = 0
    private(set) var lastName: String?
    private(set) var lastGrams: Int?

    func estimate(name: String, grams: Int) async throws -> CalorieEstimate {
        callCount += 1
        lastName = name
        lastGrams = grams
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if let error {
            throw error
        }
        return CalorieEstimate(calories: calories, confidence: confidence)
    }
}

struct TestEstimatorError: Error, Equatable { }
