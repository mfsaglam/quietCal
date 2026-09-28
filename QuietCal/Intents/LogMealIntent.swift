import AppIntents
import Foundation

/// Errors surfaced to Siri / Shortcuts when a meal can't be logged.
enum LogMealError: Error, CustomLocalizedStringResourceConvertible {
    case invalidInput
    case estimationFailed

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .invalidInput:
            "Please tell me what you ate."
        case .estimationFailed:
            "Couldn't estimate the calories for that meal. Try again."
        }
    }
}

/// Testable intent workflow. Estimation and validation complete before the
/// first write, so a failed or invalid estimate can never create a partial meal.
struct LogMealIntentService: Sendable {
    let estimator: any CalorieEstimating
    let mealStore: any MealStore
    let suggestionStore: (any SuggestionStore)?
    var now: @Sendable () -> Date = Date.init

    func log(phrase rawPhrase: String) async throws -> Meal {
        let phrase = rawPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phrase.isEmpty else {
            throw LogMealError.invalidInput
        }

        let estimate: MealEstimate
        do {
            estimate = try await estimator.estimate(phrase: phrase)
        } catch {
            throw LogMealError.estimationFailed
        }

        let foodName = estimate.foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !foodName.isEmpty, estimate.grams > 0, estimate.calories > 0 else {
            throw LogMealError.estimationFailed
        }

        let meal = Meal(
            name: foodName,
            grams: estimate.grams,
            kcal: estimate.calories,
            createdAt: now()
        )
        try await mealStore.save(meal)
        if let suggestionStore {
            let period = MealPeriod(date: meal.createdAt, calendar: .autoupdatingCurrent)
            try? await suggestionStore.record(meal, period: period)
        }
        return meal
    }
}

/// Logs a meal to QuietCal from Siri, Shortcuts, or Spotlight. Runs in the
/// background without opening the app: it estimates calories on-device and
/// writes straight to the shared App Group store, then refreshes the widget.
struct LogMealIntent: AppIntent {
    static let title: LocalizedStringResource = "Log a Meal"
    static let description = IntentDescription(
        "Estimates the calories for a food and logs it to QuietCal."
    )

    /// Keep the interaction hands-free — no need to bring the app to the front.
    static let openAppWhenRun = false

    /// A single natural-language phrase — "200 grams of grilled chicken",
    /// "8 oz salmon", "a cup of rice". One parameter means Siri asks at most one
    /// follow-up question, and the food, amount and unit are all inferred from
    /// what the user says rather than prompted for separately.
    @Parameter(title: "Meal", requestValueDialog: "What did you eat?")
    var meal: String

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$meal)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let modelContainer = try await AppGroup.makeModelContainer()
        let store = SwiftDataMealStore(modelContainer: modelContainer)
        var suggestionStore: (any SuggestionStore)?
        if let suggestionContainer = try? await AppGroup.makeSuggestionModelContainer() {
            suggestionStore = SwiftDataSuggestionStore(modelContainer: suggestionContainer)
        }
        let service = LogMealIntentService(
            estimator: Self.makeEstimator(),
            mealStore: store,
            suggestionStore: suggestionStore
        )
        let mealEntry = try await service.log(phrase: meal)
        await AppGroup.reloadWidgets()

        return .result(
            dialog: "Logged \(mealEntry.name) — about \(mealEntry.kcal) calories."
        )
    }

    /// Uses the same package-owned fallback architecture as Add Meal.
    static func makeEstimator() -> any CalorieEstimating {
        PackageCalorieEstimator()
    }
}
