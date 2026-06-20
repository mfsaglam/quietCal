import Foundation

/// Identifies which engine produced a calorie estimate, for display in the UI.
enum CalorieEstimationSource {
    case appleIntelligence
    case stub

    var label: String {
        switch self {
        case .appleIntelligence: "Estimated by Apple Intelligence"
        case .stub: "Estimated by Stub Estimator"
        }
    }
}

protocol CalorieEstimating: Sendable {
    var source: CalorieEstimationSource { get }
    func estimate(name: String, grams: Int) async throws -> Int
}
