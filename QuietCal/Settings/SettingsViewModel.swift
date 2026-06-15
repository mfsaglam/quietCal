import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let store: SettingsStore
    private let mealStore: MealStore

    var target: Int = 2000

    init(store: SettingsStore, mealStore: MealStore) {
        self.store = store
        self.mealStore = mealStore
    }

    func load() async {
        if let loaded = try? await store.loadTarget() {
            target = loaded
        }
    }

    func updateTarget(_ newTarget: Int) {
        target = newTarget
        Task { try? await store.saveTarget(newTarget) }
    }

    func resetToday() async {
        let today = Calendar.current.dateInterval(of: .day, for: Date())
            ?? DateInterval(start: Date(), duration: 0)
        try? await mealStore.deleteMeals(in: today)
    }

    func clearAll() async {
        try? await mealStore.deleteAll()
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
