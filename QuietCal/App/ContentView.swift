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

    init(modelContainer: ModelContainer) {
        let mealStore = SwiftDataMealStore(modelContainer: modelContainer)
        #if targetEnvironment(simulator)
        let calorieEstimator: CalorieEstimating = StubCalorieEstimator()
        #else
        let calorieEstimator: CalorieEstimating = AppleIntelligenceCalorieEstimator()
        #endif
        _homeViewModel = State(initialValue: HomeViewModel(
            mealStore: mealStore,
            calorieEstimator: calorieEstimator,
            settingsStore: UserDefaultsSettingsStore()
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
            if showOnboarding {
                OnboardingView(viewModel: onboardingViewModel) {
                    onboardingCompleted = true
                    showOnboarding = false
                }
            } else {
                HomeView(viewModel: homeViewModel)
            }
        }
        .preferredColorScheme(theme.colorScheme)
    }
}

#Preview {
    ContentView(modelContainer: try! ModelContainer(
        for: MealEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ))
}
