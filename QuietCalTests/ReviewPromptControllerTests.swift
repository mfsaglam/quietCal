import Testing
import Foundation
@testable import QuietCal

@Suite("ReviewPromptController")
struct ReviewPromptControllerTests {

    /// A throwaway in-memory UserDefaults suite so tests never touch the real
    /// app-group store. Index keeps each test isolated from the others.
    private func makeDefaults(_ name: String) -> UserDefaults {
        let suite = "ReviewPromptControllerTests.\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    @Test func belowMilestoneDoesNotPrompt() {
        let defaults = makeDefaults(#function)
        let controller = ReviewPromptController(defaults: defaults, currentVersion: "1.0")

        for _ in 0..<(ReviewPromptController.mealMilestone - 1) {
            controller.recordMealLogged()
        }

        #expect(controller.shouldRequestReview() == false)
    }

    @Test func atMilestonePrompts() {
        let defaults = makeDefaults(#function)
        let controller = ReviewPromptController(defaults: defaults, currentVersion: "1.0")

        for _ in 0..<ReviewPromptController.mealMilestone {
            controller.recordMealLogged()
        }

        #expect(controller.shouldRequestReview())
    }

    @Test func doesNotRePromptForSameVersion() {
        let defaults = makeDefaults(#function)
        let controller = ReviewPromptController(defaults: defaults, currentVersion: "1.0")

        for _ in 0..<ReviewPromptController.mealMilestone {
            controller.recordMealLogged()
        }
        #expect(controller.shouldRequestReview())

        controller.markPrompted()
        #expect(controller.shouldRequestReview() == false)
    }

    @Test func promptsAgainAfterVersionBump() {
        let defaults = makeDefaults(#function)
        let v1 = ReviewPromptController(defaults: defaults, currentVersion: "1.0")

        for _ in 0..<ReviewPromptController.mealMilestone {
            v1.recordMealLogged()
        }
        v1.markPrompted()
        #expect(v1.shouldRequestReview() == false)

        // New app version, same device/data: eligible again (StoreKit still caps it).
        let v2 = ReviewPromptController(defaults: defaults, currentVersion: "1.1")
        #expect(v2.shouldRequestReview())
    }
}
