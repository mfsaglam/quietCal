import Foundation

/// Identifiers for the QuietCal Pro auto-renewable subscription. These must
/// match the product IDs and subscription group configured in App Store Connect
/// (and the local `QuietCal.storekit` configuration used for testing).
enum ProProduct {
    /// The subscription group reference name shared by all Pro plans. A user can
    /// only be subscribed to one plan in the group at a time, and can freely
    /// switch between them.
    static let subscriptionGroupID = "QuietCalPro"

    /// Monthly auto-renewable subscription.
    static let monthly = "com.mfsaglam.quietcal.pro.monthly"

    /// Yearly auto-renewable subscription (better value, surfaced as the default).
    static let yearly = "com.mfsaglam.quietcal.pro.yearly"

    /// Every product ID that grants Pro access. Used both to merchandise the
    /// paywall and to decide whether a current entitlement counts as Pro.
    static let allProductIDs: [String] = [yearly, monthly]
}
