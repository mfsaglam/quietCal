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
        let phrase = meal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phrase.isEmpty else {
            throw LogMealError.invalidInput
        }

        let estimate: MealEstimate
        do {
            estimate = try await Self.makeEstimator().estimate(phrase: phrase)
        } catch {
            throw LogMealError.estimationFailed
        }

        let store = SwiftDataMealStore(modelContainer: try AppGroup.makeModelContainer())
        let mealEntry = Meal(
            name: estimate.foodName,
            grams: estimate.grams,
            kcal: estimate.calories,
            createdAt: Date()
        )
        try await store.save(mealEntry)
        AppGroup.reloadWidgets()

        return .result(
            dialog: "Logged \(estimate.foodName) — about \(estimate.calories) calories."
        )
    }

    /// Mirrors ContentView's estimator selection: the stub on the simulator
    /// (Apple Intelligence isn't available there), the real model on device.
    private static func makeEstimator() -> CalorieEstimating {
        #if targetEnvironment(simulator)
        StubCalorieEstimator()
        #else
        AppleIntelligenceCalorieEstimator()
        #endif
    }
}
