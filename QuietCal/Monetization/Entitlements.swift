import Foundation

/// A read-only view of whether the user currently has QuietCal Pro. View models
/// depend on this abstraction rather than `StoreKitEntitlementStore` directly so
/// they stay testable and free of any StoreKit import.
@MainActor
protocol EntitlementProviding: AnyObject {
    /// `true` when the user has an active Pro entitlement.
    var isPro: Bool { get }
}

/// A fixed entitlement value for previews and unit tests. Defaults to Pro so
/// existing tests and previews exercise the unrestricted experience unless they
/// explicitly opt into the free tier with `StaticEntitlement(isPro: false)`.
///
/// Deliberately non-isolated and immutable so it can be used as a default
/// initializer argument in synchronous contexts; its immutable `isPro` safely
/// satisfies the `@MainActor` protocol requirement.
final class StaticEntitlement: EntitlementProviding, Sendable {
    nonisolated let isPro: Bool

    nonisolated init(isPro: Bool) {
        self.isPro = isPro
    }
}
