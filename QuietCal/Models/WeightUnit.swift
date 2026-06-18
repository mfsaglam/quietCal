import Foundation

nonisolated enum WeightUnit: String, CaseIterable, Identifiable, Hashable, Sendable {
    case g
    case oz
    case lb

    var id: String { rawValue }

    var label: String { rawValue }

    var settingsLabel: String {
        switch self {
        case .g: return "Grams"
        case .oz: return "Ounces"
        case .lb: return "Pounds"
        }
    }

    var gramsMultiplier: Double {
        switch self {
        case .g: return 1
        case .oz: return 28.3495
        case .lb: return 453.592
        }
    }
}
