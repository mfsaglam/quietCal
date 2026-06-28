import Foundation
import StoreKit
import Observation

/// Single source of truth for the user's QuietCal Pro entitlement, backed by
/// StoreKit 2. It derives `isPro` from `Transaction.currentEntitlements` (which
/// already excludes expired and revoked transactions) and keeps it live by
/// listening to `Transaction.updates` for purchases, renewals, and changes made
/// on other devices.
///
/// Created once at app launch and injected into the SwiftUI environment so any
/// view can observe `isPro`, and passed to view models that need to enforce the
/// free-tier limits.
@MainActor
@Observable
final class StoreKitEntitlementStore: EntitlementProviding {
    /// Whether the user currently has an active Pro entitlement.
    private(set) var isPro: Bool = false

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {}

    /// Builds a store with a fixed entitlement for SwiftUI previews, avoiding any
    /// StoreKit calls. Not for use at runtime.
    init(previewIsPro: Bool) {
        self.isPro = previewIsPro
    }

    /// Begins observing transaction updates and refreshes the current entitlement.
    /// Safe to call more than once; the update listener is only started once.
    func start() {
        if updatesTask == nil {
            updatesTask = Task { [weak self] in
                for await update in Transaction.updates {
                    if case .verified(let transaction) = update {
                        await transaction.finish()
                    }
                    await self?.refresh()
                }
            }
        }
        Task { await refresh() }
    }

    /// Recomputes `isPro` from the user's current entitlements.
    func refresh() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if ProProduct.allProductIDs.contains(transaction.productID) {
                entitled = true
                break
            }
        }
        isPro = entitled
    }

    /// Restores purchases by syncing with the App Store, then refreshes. Surfaced
    /// from the paywall and Settings so users on a new device can recover Pro.
    func restore() async {
        try? await AppStore.sync()
        await refresh()
    }
}
