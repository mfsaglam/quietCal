import Foundation
import Observation

@MainActor
@Observable
final class AddMealViewModel: Identifiable {
    enum FieldState { case empty, estimating, estimated, failed }

    let id = UUID()

    private let mealStore: MealStore
    private let calorieEstimator: CalorieEstimating

    var name: String = ""
    var amount: String = ""
    var unit: WeightUnit
    var estimatedCalories: Int?
    var isEstimating: Bool = false
    var errorMessage: String?

    init(
        mealStore: MealStore,
        calorieEstimator: CalorieEstimating,
        defaultUnit: WeightUnit = .g
    ) {
        self.mealStore = mealStore
        self.calorieEstimator = calorieEstimator
        self.unit = defaultUnit
    }

    var estimationSource: CalorieEstimationSource {
        calorieEstimator.source
    }

    var state: FieldState {
        if isEstimating { return .estimating }
        if errorMessage != nil { return .failed }
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
            errorMessage = nil
            return
        }
        let requestName = trimmedName
        let requestGrams = gramsValue
        isEstimating = true
        errorMessage = nil
        defer { isEstimating = false }
        do {
            let kcal = try await calorieEstimator.estimate(name: requestName, grams: requestGrams)
            guard requestName == trimmedName, requestGrams == gramsValue else { return }
            estimatedCalories = kcal
        } catch is CancellationError {
            // keep previous estimate
        } catch {
            guard requestName == trimmedName, requestGrams == gramsValue else { return }
            estimatedCalories = nil
            errorMessage = "Couldn't estimate this meal. Check the name and amount, then try again."
        }
    }

    func retry() async {
        estimatedCalories = nil
        errorMessage = nil
        await estimate()
    }

    func save() async {
        guard canSave, let kcal = estimatedCalories else { return }
        let meal = Meal(
            name: trimmedName,
            grams: gramsValue,
            kcal: kcal,
            createdAt: Date()
        )
        try? await mealStore.save(meal)
    }
}
