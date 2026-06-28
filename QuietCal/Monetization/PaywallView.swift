import SwiftUI
import StoreKit

/// The QuietCal Pro paywall, presented as a sheet from Settings, the History
/// upsell, a blocked save, and at the end of onboarding. Merchandising and the
/// purchase/restore flow are handled by `SubscriptionStoreView`; this view adds
/// the marketing header and the feature list, and dismisses itself once the
/// purchase grants Pro.
struct PaywallView: View {
    @Environment(StoreKitEntitlementStore.self) private var entitlements
    @Environment(\.dismiss) private var dismiss

    private static let features: [(icon: String, title: String, detail: String)] = [
        ("infinity", "Unlimited logging", "Log as many meals a day as you like — free stops at \(FreeTierLimits.dailyMealLimit)."),
        ("calendar", "Full history", "Browse every day you've tracked, not just the last \(FreeTierLimits.freeHistoryDays)."),
        ("square.and.arrow.up", "Export your data", "Download all your meals as a CSV, anytime."),
        ("paintbrush", "Light & dark themes", "Pick the look you like instead of just System.")
    ]

    var body: some View {
        SubscriptionStoreView(productIDs: ProProduct.allProductIDs) {
            marketingContent
        }
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStoreControlStyle(.prominentPicker)
        .storeButton(.visible, for: .restorePurchases)
        .storeButton(.visible, for: .cancellation)
        .onInAppPurchaseCompletion { _, result in
            if case .success(.success) = result {
                await entitlements.refresh()
            }
        }
        .onChange(of: entitlements.isPro) { _, isPro in
            if isPro { dismiss() }
        }
    }

    private var marketingContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text("QUIETCAL")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Text("QuietCal Pro")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Keep tracking, quietly — without limits.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(Self.features, id: \.title) { feature in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 30, height: 30)
                            .background(Color.primary.opacity(0.07), in: Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text(feature.detail)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    PaywallView()
        .environment(StoreKitEntitlementStore(previewIsPro: false))
}
