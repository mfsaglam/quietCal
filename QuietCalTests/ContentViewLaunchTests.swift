import SwiftData
import Testing
@testable import QuietCal

@Suite("ContentView launch")
@MainActor
struct ContentViewLaunchTests {
    @Test func constructsWithoutAnyModelAvailabilityGate() throws {
        let mealContainer = try ModelContainer(
            for: MealEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let suggestionContainer = try ModelContainer(
            for: SuggestionEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        _ = ContentView(
            modelContainer: mealContainer,
            suggestionModelContainer: suggestionContainer,
            calorieEstimator: TestCalorieEstimator()
        )
    }
}
