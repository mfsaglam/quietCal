import Foundation
import Observation

struct MealSuggestion: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let grams: Int
    let kcal: Int
    let occurrenceCount: Int
    let lastLoggedAt: Date
}

@MainActor
@Observable
final class AddMealViewModel: Identifiable {
    enum FieldState { case empty, estimating, estimated, failed }

    /// The result of attempting to save a meal, so the view can react: dismiss
    /// on success, or present the paywall when a free user hits the daily limit.
    enum SaveOutcome: Equatable { case saved, blockedByLimit, notReady }

    let id = UUID()

    private let mealStore: MealStore
    private let suggestionStore: SuggestionStore
    private let calorieEstimator: CalorieEstimating
    private let reviewPrompt: ReviewPromptController
    private let entitlements: any EntitlementProviding
    private let calendar: Calendar
    private let now: () -> Date

    var name: String = "" {
        didSet { if name != oldValue { invalidateEstimate() } }
    }
    var amount: String = "" {
        didSet { if amount != oldValue { invalidateEstimate() } }
    }
    var unit: WeightUnit {
        didSet { if unit != oldValue { invalidateEstimate() } }
    }

    private var estimateRequestID = UUID()
    var estimatedIngredients: [EstimatedIngredient] = []
    var estimatedCalories: Int?
    var estimatedConfidence: EstimateConfidence?
    var isEstimating: Bool = false
    var errorMessage: String?
    private(set) var suggestions: [MealSuggestion] = []

    init(
        mealStore: MealStore,
        suggestionStore: SuggestionStore = InMemorySuggestionStore(),
        calorieEstimator: CalorieEstimating,
        defaultUnit: WeightUnit = .g,
        reviewPrompt: ReviewPromptController? = nil,
        entitlements: any EntitlementProviding = StaticEntitlement(isPro: true),
        calendar: Calendar = .autoupdatingCurrent,
        now: @escaping () -> Date = Date.init
    ) {
        self.mealStore = mealStore
        self.suggestionStore = suggestionStore
        self.calorieEstimator = calorieEstimator
        self.unit = defaultUnit
        self.reviewPrompt = reviewPrompt ?? ReviewPromptController()
        self.entitlements = entitlements
        self.calendar = calendar
        self.now = now
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

    var shouldShowSuggestions: Bool {
        trimmedName.isEmpty && !suggestions.isEmpty
    }

    var suggestionPeriodLabel: String {
        MealPeriod(date: now(), calendar: calendar).label
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var amountValue: Int { Int(amount) ?? 0 }

    private var gramsValue: Int {
        Int(Double(amountValue) * unit.gramsMultiplier)
    }

    private func invalidateEstimate() {
        estimateRequestID = UUID()
        isEstimating = false
        estimatedCalories = nil
        estimatedConfidence = nil
        estimatedIngredients = []
        errorMessage = nil
    }

    func estimate() async {
        invalidateEstimate()
        let requestID = estimateRequestID
        guard shouldEstimate else {
            estimatedCalories = nil
            estimatedConfidence = nil
            errorMessage = nil
            return
        }
        let requestName = trimmedName
        let requestGrams = gramsValue
        isEstimating = true
        errorMessage = nil
        defer { if requestID == estimateRequestID { isEstimating = false } }
        do {
            let estimate = try await calorieEstimator.estimate(name: requestName, grams: requestGrams)
            guard requestID == estimateRequestID, !Task.isCancelled else { return }
            estimatedCalories = estimate.calories
            estimatedConfidence = estimate.confidence
            estimatedIngredients = estimate.ingredients
        } catch is CancellationError {
            // A cancelled request must not restore an outdated breakdown.
        } catch {
            guard requestID == estimateRequestID, !Task.isCancelled else { return }
            estimatedCalories = nil
            estimatedConfidence = nil
            errorMessage = L10n.string("add_meal.error.estimation_failed.message")
        }
    }

    func retry() async {
        estimatedCalories = nil
        estimatedConfidence = nil
        errorMessage = nil
        await estimate()
    }

    /// Loads the user's most common meals for the current local time of day.
    /// Suggestions are derived entirely on-device from the last 90 days.
    func loadSuggestions() async {
        let currentDate = now()
        guard let lookbackStart = calendar.date(byAdding: .day, value: -90, to: currentDate) else {
            suggestions = []
            return
        }

        do {
            let period = MealPeriod(date: currentDate, calendar: calendar)
            let storedSuggestions = try await suggestionStore.fetchSuggestions(
                for: period,
                usedSince: lookbackStart,
                limit: 5
            )
            suggestions = storedSuggestions.map { stored in
                MealSuggestion(
                    id: stored.id,
                    name: stored.name,
                    grams: stored.grams,
                    kcal: stored.kcal,
                    occurrenceCount: stored.count(for: period),
                    lastLoggedAt: stored.lastUsedAt(for: period) ?? .distantPast
                )
            }
        } catch {
            suggestions = []
        }
    }

    /// Copies only the suggestion's name into the editable form. The amount is
    /// deliberately cleared so entering a new amount follows the normal AI flow.
    func useSuggestionName(_ suggestion: MealSuggestion) {
        name = suggestion.name
        amount = ""
    }

    /// Removes every matching quick-log record.
    func deleteSuggestion(_ suggestion: MealSuggestion) async {
        do {
            try await suggestionStore.delete(id: suggestion.id)
            suggestions.removeAll { $0.id == suggestion.id }
        } catch {
            // Keep the suggestion visible when persistence fails.
        }
    }

    /// Repeats a previous meal exactly, without asking the calorie estimator to
    /// recalculate it. A fresh ID and timestamp make this a new log entry.
    @discardableResult
    func logSuggestion(_ suggestion: MealSuggestion) async -> SaveOutcome {
        if !entitlements.isPro, await reachedDailyLimit() {
            return .blockedByLimit
        }
        let meal = Meal(
            name: suggestion.name,
            grams: suggestion.grams,
            kcal: suggestion.kcal,
            createdAt: now()
        )
        return await persist(meal)
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
            createdAt: now()
        )
        return await persist(meal)
    }

    private func persist(_ meal: Meal) async -> SaveOutcome {
        do {
            try await mealStore.save(meal)
        } catch {
            return .notReady
        }
        let period = MealPeriod(date: meal.createdAt, calendar: calendar)
        try? await suggestionStore.record(meal, period: period)
        reviewPrompt.recordMealLogged()
        AppGroup.reloadWidgets()
        return .saved
    }

    /// Whether the user has already logged the free tier's daily allowance of
    /// meals. Only consulted for non-Pro users.
    private func reachedDailyLimit() async -> Bool {
        let currentDate = now()
        let today = calendar.dateInterval(of: .day, for: currentDate)
            ?? DateInterval(start: currentDate, duration: 0)
        let count = (try? await mealStore.fetchMeals(in: today).count) ?? 0
        return count >= FreeTierLimits.dailyMealLimit
    }

}
