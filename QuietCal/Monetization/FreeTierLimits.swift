import Foundation

/// Central definition of what the free tier allows, so the gates stay
/// consistent across the app and are easy to tune in one place. Everything not
/// constrained here is available to every user; QuietCal Pro lifts these limits.
enum FreeTierLimits {
    /// Maximum number of meals a free user can *save* per calendar day. There is
    /// deliberately no limit on AI estimation — only on logging — so the core
    /// experience stays usable while still giving Pro a clear, recurring value.
    static let dailyMealLimit = 20

    /// How many days of history a free user can browse. The week chart always
    /// shows the trailing 7 days; the "Earlier" log beyond that is Pro-only.
    static let freeHistoryDays = 7
}
