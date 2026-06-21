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
    @AppStorage(UserDefaultsSettingsStore.themeKey, store: AppGroup.sharedDefaults) private var themeRawValue: String = Theme.system.rawValue

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
    }

    private var theme: Theme {
        Theme(rawValue: themeRawValue) ?? .system
    }

    var body: some View {
        HomeView(viewModel: homeViewModel)
            .preferredColorScheme(theme.colorScheme)
    }
}

#Preview {
    ContentView(modelContainer: try! ModelContainer(
        for: MealEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ))
}
