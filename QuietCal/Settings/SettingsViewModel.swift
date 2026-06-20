import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let store: SettingsStore
    private let mealStore: MealStore

    var target: Int = 2000
    var theme: Theme = .system
    var weightUnit: WeightUnit = .g

    init(store: SettingsStore, mealStore: MealStore) {
        self.store = store
        self.mealStore = mealStore
    }

    func load() async {
        if let loaded = try? await store.loadTarget() {
            target = loaded
        }
        if let loaded = try? await store.loadTheme() {
            theme = loaded
        }
        if let loaded = try? await store.loadWeightUnit() {
            weightUnit = loaded
        }
    }

    func updateTarget(_ newTarget: Int) {
        target = newTarget
        Task {
            try? await store.saveTarget(newTarget)
            AppGroup.reloadWidgets()
        }
    }

    func updateTheme(_ newTheme: Theme) {
        theme = newTheme
        Task { try? await store.saveTheme(newTheme) }
    }

    func updateWeightUnit(_ newUnit: WeightUnit) {
        weightUnit = newUnit
        Task { try? await store.saveWeightUnit(newUnit) }
    }

    func resetToday() async {
        let today = Calendar.current.dateInterval(of: .day, for: Date())
            ?? DateInterval(start: Date(), duration: 0)
        try? await mealStore.deleteMeals(in: today)
        AppGroup.reloadWidgets()
    }

    func clearAll() async {
        try? await mealStore.deleteAll()
        AppGroup.reloadWidgets()
    }

    func generateCSV() async -> String {
        let interval = DateInterval(start: .distantPast, end: .distantFuture)
        let meals = (try? await mealStore.fetchMeals(in: interval)) ?? []
        return meals.csvString
    }

    var formattedTarget: String {
        "\(target.formatted()) kcal"
    }
}
