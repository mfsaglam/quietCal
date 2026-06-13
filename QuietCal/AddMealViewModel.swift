import Foundation
import Observation

@MainActor
@Observable
final class AddMealViewModel {
    enum FieldState { case empty, estimating, estimated }

    enum Unit: String, CaseIterable, Identifiable, Hashable {
        case g, oz, lb

        var id: String { rawValue }
        var label: String { rawValue }

        var gramsMultiplier: Double {
            switch self {
            case .g: return 1
            case .oz: return 28.3495
            case .lb: return 453.592
            }
        }
    }

    private let mealStore: MealStore
    private let calorieEstimator: CalorieEstimating

    var name: String = ""
    var amount: String = ""
    var unit: Unit = .g
    var estimatedCalories: Int?
    var isEstimating: Bool = false

    init(mealStore: MealStore, calorieEstimator: CalorieEstimating) {
        self.mealStore = mealStore
        self.calorieEstimator = calorieEstimator
    }

    var state: FieldState {
        if isEstimating { return .estimating }
        if estimatedCalories != nil { return .estimated }
        return .empty
    }

    var canSave: Bool {
        state == .estimated && !trimmedName.isEmpty && gramsValue > 0
    }

    var shouldEstimate: Bool {
        !trimmedName.isEmpty && gramsValue > 0
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var amountValue: Int { Int(amount) ?? 0 }

    private var gramsValue: Int {
        Int(Double(amountValue) * unit.gramsMultiplier)
    }

    func estimate() async {
        guard shouldEstimate else {
            estimatedCalories = nil
            return
        }
        let requestName = trimmedName
        let requestGrams = gramsValue
        isEstimating = true
        defer { isEstimating = false }
        do {
            let kcal = try await calorieEstimator.estimate(name: requestName, grams: requestGrams)
            guard requestName == trimmedName, requestGrams == gramsValue else { return }
            estimatedCalories = kcal
        } catch is CancellationError {
            // keep previous estimate
        } catch {
            estimatedCalories = nil
        }
    }

    func save() async {
        guard canSave, let kcal = estimatedCalories else { return }
        let meal = Meal(
            name: trimmedName,
            grams: gramsValue,
            kcal: kcal,
            time: Self.currentTimeString()
        )
        try? await mealStore.save(meal)
    }

    private static func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}
