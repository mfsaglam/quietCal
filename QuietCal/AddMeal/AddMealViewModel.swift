import Foundation
import Observation

@MainActor
@Observable
final class AddMealViewModel: Identifiable {
    enum FieldState { case empty, estimating, estimated, failed }

    /// The result of attempting to save a meal, so the view can react: dismiss
    /// on success, or present the paywall when a free user hits the daily limit.
    enum SaveOutcome: Equatable { case saved, blockedByLimit, notReady }

    let id = UUID()

    private let mealStore: MealStore
    private let calorieEstimator: CalorieEstimating
    private let reviewPrompt: ReviewPromptController
    private let entitlements: any EntitlementProviding

    var name: String = ""
    var amount: String = ""
    var unit: WeightUnit
    var estimatedCalories: Int?
    var isEstimating: Bool = false
    var errorMessage: String?

    init(
        mealStore: MealStore,
        calorieEstimator: CalorieEstimating,
        defaultUnit: WeightUnit = .g,
        reviewPrompt: ReviewPromptController = ReviewPromptController(),
        entitlements: any EntitlementProviding = StaticEntitlement(isPro: true)
    ) {
        self.mealStore = mealStore
        self.calorieEstimator = calorieEstimator
        self.unit = defaultUnit
        self.reviewPrompt = reviewPrompt
        self.entitlements = entitlements
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

    @discardableResult
    func save() async -> SaveOutcome {
        guard canSave, let kcal = estimatedCalories else { return .notReady }
        if !entitlements.isPro, await reachedDailyLimit() {
            return .blockedByLimit
        }
        let meal = Meal(
            name: trimmedName,
            grams: gramsValue,
            kcal: kcal,
            createdAt: Date()
        )
        try? await mealStore.save(meal)
        reviewPrompt.recordMealLogged()
        AppGroup.reloadWidgets()
        return .saved
    }

    /// Whether the user has already logged the free tier's daily allowance of
    /// meals. Only consulted for non-Pro users.
    private func reachedDailyLimit() async -> Bool {
        let today = Calendar.current.dateInterval(of: .day, for: Date())
            ?? DateInterval(start: Date(), duration: 0)
        let count = (try? await mealStore.fetchMeals(in: today).count) ?? 0
        return count >= FreeTierLimits.dailyMealLimit
    }
}
