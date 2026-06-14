import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let mealStore: MealStore
    private let calorieEstimator: CalorieEstimating
    private let settingsStore: SettingsStore

    var target = 2000
    var meals: [Meal] = []

    init(
        mealStore: MealStore,
        calorieEstimator: CalorieEstimating,
        settingsStore: SettingsStore
    ) {
        self.mealStore = mealStore
        self.calorieEstimator = calorieEstimator
        self.settingsStore = settingsStore
    }

    func load() async {
        if let loadedTarget = try? await settingsStore.loadTarget() {
            target = loadedTarget
        }
        let today = Calendar.current.dateInterval(of: .day, for: Date())
            ?? DateInterval(start: Date(), duration: 0)
        do {
            meals = try await mealStore.fetchMeals(in: today)
        } catch {
            meals = []
        }
    }

    func delete(_ meal: Meal) async {
        meals.removeAll { $0.id == meal.id }
        try? await mealStore.delete(meal)
    }

    func makeAddMealViewModel() -> AddMealViewModel {
        AddMealViewModel(mealStore: mealStore, calorieEstimator: calorieEstimator)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(store: settingsStore)
    }

    var eaten: Int { meals.reduce(0) { $0 + $1.kcal } }
    var remaining: Int { target - eaten }
    var progress: Double { min(Double(eaten) / Double(target), 1.0) }
    var isOverTarget: Bool { eaten > target }
    var overageProgress: Double {
        guard isOverTarget else { return 0 }
        return min(Double(eaten - target) / Double(target), 1.0)
    }
    var dateLabel: String {
        let date = Date()
        let weekday = date.formatted(.dateTime.weekday(.wide)).uppercased()
        let month = date.formatted(.dateTime.month(.abbreviated)).uppercased()
        let day = date.formatted(.dateTime.day())
        return "\(weekday) · \(month) \(day)"
    }
}
