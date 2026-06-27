import Foundation

/// Decides when to ask the user for an App Store review, following Apple's
/// guidance: only after a positive milestone, and never more than once per app
/// version. StoreKit itself enforces the system-wide budget (a maximum of three
/// prompts per 365 days, and it silently does nothing if the user has reviewed
/// this version or disabled review requests). This type only governs *our*
/// eligibility — the actual prompt is presented from SwiftUI via the
/// `\.requestReview` environment action.
struct ReviewPromptController {
    /// Lifetime number of meals a user must log before we consider asking. Kept
    /// deliberately conservative so the prompt lands once someone is invested.
    static let mealMilestone = 10

    private let defaults: UserDefaults
    private let currentVersion: String

    init(
        defaults: UserDefaults = AppGroup.sharedDefaults,
        currentVersion: String = AppInfo.version
    ) {
        self.defaults = defaults
        self.currentVersion = currentVersion
    }

    /// Lifetime count of meals the user has successfully logged.
    var mealsLoggedCount: Int {
        defaults.integer(forKey: AppGroup.mealsLoggedCountKey)
    }

    /// Increments the lifetime meal counter. Call once per successful save.
    func recordMealLogged() {
        defaults.set(mealsLoggedCount + 1, forKey: AppGroup.mealsLoggedCountKey)
    }

    /// `true` when the user has reached the milestone and we haven't already
    /// prompted for the current app version.
    func shouldRequestReview() -> Bool {
        guard mealsLoggedCount >= Self.mealMilestone else { return false }
        let lastVersion = defaults.string(forKey: AppGroup.lastReviewPromptVersionKey)
        return lastVersion != currentVersion
    }

    /// Records that we prompted for the current app version, so we don't ask
    /// again until the user updates to a newer version.
    func markPrompted() {
        defaults.set(currentVersion, forKey: AppGroup.lastReviewPromptVersionKey)
    }
}
