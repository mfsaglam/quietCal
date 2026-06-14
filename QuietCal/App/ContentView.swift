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

    init(modelContainer: ModelContainer) {
        let mealStore = SwiftDataMealStore(modelContainer: modelContainer)
        _homeViewModel = State(initialValue: HomeViewModel(
            mealStore: mealStore,
            calorieEstimator: StubCalorieEstimator(),
            settingsStore: UserDefaultsSettingsStore()
        ))
    }

    var body: some View {
        HomeView(viewModel: homeViewModel)
    }
}

#Preview {
    ContentView(modelContainer: try! ModelContainer(
        for: MealEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ))
}
