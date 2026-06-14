import Foundation
@testable import QuietCal

final class TestCalorieEstimator: CalorieEstimating, @unchecked Sendable {
    var calories: Int = 200
    var error: Error?
    var delay: Duration = .zero

    private(set) var callCount = 0
    private(set) var lastName: String?
    private(set) var lastGrams: Int?

    func estimate(name: String, grams: Int) async throws -> Int {
        callCount += 1
        lastName = name
        lastGrams = grams
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if let error {
            throw error
        }
        return calories
    }
}

struct TestEstimatorError: Error, Equatable { }
