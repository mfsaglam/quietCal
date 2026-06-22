import Foundation

/// Single source of truth for the user-facing app name and version. Use these
/// instead of hard-coding the name in views, so the brand stays consistent.
///
/// Note: internal identifiers (bundle IDs, the App Group, the `quietcal://`
/// URL scheme, type names) are intentionally NOT derived from here — changing
/// them would break signing and the app↔widget data link.
enum AppInfo {
    /// The display name shown to users throughout the UI.
    static let name = "QuietCal"

    /// Marketing version (e.g. "1.0"), read from the bundle so it tracks
    /// `MARKETING_VERSION` automatically.
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    /// Name and version combined for footers, e.g. "QuietCal · v1.0".
    static var nameAndVersion: String {
        version.isEmpty ? name : "\(name) · v\(version)"
    }
}
