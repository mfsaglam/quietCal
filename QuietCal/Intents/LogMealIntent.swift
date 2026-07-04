import AppIntents
import Foundation

/// Errors surfaced to Siri / Shortcuts when a meal can't be logged.
enum LogMealError: Error, CustomLocalizedStringResourceConvertible {
    case invalidInput
    case estimationFailed

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .invalidInput:
            "Please provide a food name and an amount greater than zero."
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

    @Parameter(title: "Food", requestValueDialog: "What did you eat?")
    var food: String

    @Parameter(title: "Amount (grams)", requestValueDialog: "How many grams?")
    var grams: Double

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$grams) grams of \(\.$food)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let name = food.trimmingCharacters(in: .whitespacesAndNewlines)
        let gramsInt = Int(grams.rounded())
        guard !name.isEmpty, gramsInt > 0 else {
            throw LogMealError.invalidInput
        }

        let kcal: Int
        do {
            kcal = try await Self.makeEstimator().estimate(name: name, grams: gramsInt)
        } catch {
            throw LogMealError.estimationFailed
        }

        let store = SwiftDataMealStore(modelContainer: try AppGroup.makeModelContainer())
        let meal = Meal(name: name, grams: gramsInt, kcal: kcal, createdAt: Date())
        try await store.save(meal)
        AppGroup.reloadWidgets()

        return .result(
            dialog: "Logged \(name) — about \(kcal) calories."
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
