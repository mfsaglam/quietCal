import AppIntents

/// Preconfigured App Shortcuts, so the intents get Siri trigger phrases and
/// appear in Spotlight and the Shortcuts app without any user setup.
///
/// Every phrase must contain `\(.applicationName)`. The system matches
/// semantically similar phrases too, so this list is a starting point.
struct QuietCalShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogMealIntent(),
            phrases: [
                "Log a meal in \(.applicationName)",
                "Add a meal to \(.applicationName)",
                "Log food in \(.applicationName)"
            ],
            shortTitle: "Log a Meal",
            systemImageName: "fork.knife"
        )
        AppShortcut(
            intent: TodaysCaloriesIntent(),
            phrases: [
                "How many calories have I logged in \(.applicationName)",
                "Check my calories in \(.applicationName)"
            ],
            shortTitle: "Today's Calories",
            systemImageName: "flame"
        )
    }
}
