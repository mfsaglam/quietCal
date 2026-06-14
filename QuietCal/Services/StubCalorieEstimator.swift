import Foundation

struct StubCalorieEstimator: CalorieEstimating {
    var delay: Duration = .milliseconds(1500)
    var caloriesPerGram: Double = 1.5

    func estimate(name: String, grams: Int) async throws -> Int {
        try await Task.sleep(for: delay)
        return Int(Double(grams) * caloriesPerGram)
    }
}
