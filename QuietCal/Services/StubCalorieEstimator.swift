import Foundation

struct StubCalorieEstimator: CalorieEstimating {
    let source: CalorieEstimationSource = .stub
    var delay: Duration = .milliseconds(1500)
    var caloriesPerGram: Double = 1.5

    func estimate(name: String, grams: Int) async throws -> CalorieEstimate {
        try await Task.sleep(for: delay)
        return CalorieEstimate(
            calories: Int(Double(grams) * caloriesPerGram),
            confidence: .medium
        )
    }
}
