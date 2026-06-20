import Foundation
import Observation

@MainActor
@Observable
final class AddMealViewModel: Identifiable {
    enum FieldState { case empty, estimating, estimated }

    let id = UUID()

    private let mealStore: MealStore
    private let calorieEstimator: CalorieEstimating

    var name: String = ""
    var amount: String = ""
    var unit: WeightUnit
    var estimatedCalories: Int?
    var isEstimating: Bool = false

    init(
        mealStore: MealStore,
        calorieEstimator: CalorieEstimating,
        defaultUnit: WeightUnit = .g
    ) {
        self.mealStore = mealStore
        self.calorieEstimator = calorieEstimator
        self.unit = defaultUnit
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
            createdAt: Date()
        )
        try? await mealStore.save(meal)
    }
}
