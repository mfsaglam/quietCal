import Foundation
import SwiftData
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Shared storage configuration so the app and its widget extension read and
/// write the same SwiftData store and settings via an App Group container.
enum AppGroup {
    /// The App Group identifier shared by the app and widget targets.
    static let identifier = "group.mfsaglam.QuietCal"

    /// File name of the SwiftData store inside the shared container.
    private static let storeName = "QuietCal.store"

    enum StorageError: Error {
        case missingContainer
    }

    // MARK: - Settings keys

    static let targetKey = "settings.target"
    static let themeKey = "settings.theme"
    static let weightUnitKey = "settings.weightUnit"
    static let onboardingCompletedKey = "settings.onboardingCompleted"
    static let mealsLoggedCountKey = "settings.mealsLoggedCount"
    static let lastReviewPromptVersionKey = "settings.lastReviewPromptVersion"
    static let defaultTarget = 2000

    // MARK: - Shared containers

    /// UserDefaults backed by the shared App Group suite. Falls back to
    /// `.standard` if the suite cannot be created (e.g. misconfigured group).
    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }

    /// URL of the shared App Group container directory, or `nil` if the App
    /// Group capability is missing. Callers must handle the `nil` case — the
    /// widget extension must never crash while building its timeline.
    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    /// Builds a `ModelContainer` whose store lives in the shared App Group
    /// container, so both the app and the widget operate on the same data.
    static func makeModelContainer() throws -> ModelContainer {
        guard let containerURL else { throw StorageError.missingContainer }
        let configuration = ModelConfiguration(
            url: containerURL.appending(path: storeName)
        )
        return try ModelContainer(for: MealEntity.self, configurations: configuration)
    }

    // MARK: - Widget refresh

    /// Asks WidgetKit to rebuild the widget timelines. Call after any change to
    /// meals or the calorie target so the widget reflects the latest data.
    static func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
