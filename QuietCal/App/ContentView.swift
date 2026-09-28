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

    init(
        modelContainer: ModelContainer,
        suggestionModelContainer: ModelContainer,
        calorieEstimator: any CalorieEstimating = PackageCalorieEstimator()
    ) {
        let mealStore = SwiftDataMealStore(modelContainer: modelContainer)
        let suggestionStore = SwiftDataSuggestionStore(modelContainer: suggestionModelContainer)
        let entitlements = StoreKitEntitlementStore()
        _entitlements = State(initialValue: entitlements)
        _homeViewModel = State(initialValue: HomeViewModel(
            mealStore: mealStore,
            suggestionStore: suggestionStore,
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
        mainContent
        .preferredColorScheme(theme.colorScheme)
        .task { entitlements.start() }
        .sheet(isPresented: $showOnboardingPaywall) {
            PaywallView()
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
            HomeView(viewModel: homeViewModel, entitlements: entitlements)
        }
    }
}

#Preview {
    ContentView(
        modelContainer: try! ModelContainer(
            for: MealEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        suggestionModelContainer: try! ModelContainer(
            for: SuggestionEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    )
}
