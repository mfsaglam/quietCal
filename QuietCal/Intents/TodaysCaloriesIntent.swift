import AppIntents
import Foundation

/// Reports today's logged calorie total. A read-only companion to
/// `LogMealIntent`, useful for "How many calories have I logged?" queries.
struct TodaysCaloriesIntent: AppIntent {
    static let title: LocalizedStringResource = "Today's Calories"
    static let description = IntentDescription(
        "Tells you how many calories you've logged in QuietCal today."
    )

    static let openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = SwiftDataMealStore(modelContainer: try AppGroup.makeModelContainer())
        let today = Calendar.current.dateInterval(of: .day, for: Date())
            ?? DateInterval(start: Date(), duration: 0)
        let meals = try await store.fetchMeals(in: today)
        let total = meals.reduce(0) { $0 + $1.kcal }

        let dialog: IntentDialog = meals.isEmpty
            ? "You haven't logged any meals today yet."
            : "You've logged \(total) calories today across \(meals.count) meals."
        return .result(dialog: dialog)
    }
}
