import Foundation
import SwiftData

extension AppGroup {
    /// Builds the independent store used by quick-log suggestions. This file is
    /// app-only; the widget continues to know only about the real Meal store.
    static func makeSuggestionModelContainer() throws -> ModelContainer {
        guard let containerURL else { throw StorageError.missingContainer }
        let configuration = ModelConfiguration(
            url: containerURL.appending(path: "QuietCalSuggestions.store")
        )
        return try ModelContainer(
            for: SuggestionEntity.self,
            configurations: configuration
        )
    }
}
