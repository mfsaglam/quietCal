//
//  ContentView.swift
//  QuietCal
//
//  Created by Saglam, Fatih on 27.04.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var homeViewModel: HomeViewModel
    @State private var onboardingViewModel: OnboardingViewModel
    @AppStorage(UserDefaultsSettingsStore.themeKey, store: AppGroup.sharedDefaults) private var themeRawValue: String = Theme.system.rawValue
    @AppStorage(AppGroup.onboardingCompletedKey, store: AppGroup.sharedDefaults) private var onboardingCompleted = false

    /// Captured once at launch so that resetting the onboarding flag from
    /// Settings only takes effect on the next launch rather than interrupting
    /// the current session.
    @State private var showOnboarding: Bool

    /// Source of truth for QuietCal Pro, shared with every view via the
    /// environment and with view models that enforce the free-tier limits.
    @State private var entitlements: StoreKitEntitlementStore

    /// Presents the paywall once, right after onboarding finishes, for users who
    /// aren't already subscribed.
    @State private var showOnboardingPaywall = false

    /// Whether on-device calorie estimation can run. Re-checked whenever the
    /// app becomes active so recoverable states (Apple Intelligence enabled in
    /// Settings, or the model finishing its download) are picked up live.
    private let availabilityProvider: ModelAvailabilityProviding
    @State private var availability: ModelAvailability

    @Environment(\.scenePhase) private var scenePhase

    init(modelContainer: ModelContainer) {
        let mealStore = SwiftDataMealStore(modelContainer: modelContainer)
        #if targetEnvironment(simulator)
        let calorieEstimator: CalorieEstimating = StubCalorieEstimator()
        let availabilityProvider: ModelAvailabilityProviding = AlwaysAvailableModelProvider()
        #else
        let calorieEstimator: CalorieEstimating = AppleIntelligenceCalorieEstimator()
        let availabilityProvider: ModelAvailabilityProviding = SystemModelAvailabilityProvider()
        #endif
        self.availabilityProvider = availabilityProvider
        _availability = State(initialValue: availabilityProvider.availability)
        let entitlements = StoreKitEntitlementStore()
        _entitlements = State(initialValue: entitlements)
        _homeViewModel = State(initialValue: HomeViewModel(
            mealStore: mealStore,
            calorieEstimator: calorieEstimator,
            settingsStore: UserDefaultsSettingsStore(),
            entitlements: entitlements
        ))
        _onboardingViewModel = State(initialValue: OnboardingViewModel(
            settingsStore: UserDefaultsSettingsStore()
        ))
        let completed = AppGroup.sharedDefaults.bool(forKey: AppGroup.onboardingCompletedKey)
        _showOnboarding = State(initialValue: !completed)
    }

    private var theme: Theme {
        Theme(rawValue: themeRawValue) ?? .system
    }

    var body: some View {
        Group {
            if availability.isAvailable {
                mainContent
            } else {
                ModelUnavailableView(availability: availability) {
                    availability = availabilityProvider.availability
                }
            }
        }
        .preferredColorScheme(theme.colorScheme)
        .environment(entitlements)
        .task { entitlements.start() }
        .sheet(isPresented: $showOnboardingPaywall) {
            PaywallView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                availability = availabilityProvider.availability
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if showOnboarding {
            OnboardingView(viewModel: onboardingViewModel) {
                onboardingCompleted = true
                showOnboarding = false
                if !entitlements.isPro {
                    showOnboardingPaywall = true
                }
            }
        } else {
            HomeView(viewModel: homeViewModel)
        }
    }
}

#Preview {
    ContentView(modelContainer: try! ModelContainer(
        for: MealEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ))
}
