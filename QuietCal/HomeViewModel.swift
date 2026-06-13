import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let mealStore: MealStore
    private let calorieEstimator: CalorieEstimating

    var target = 2000
    var meals: [Meal] = []

    init(mealStore: MealStore, calorieEstimator: CalorieEstimating) {
        self.mealStore = mealStore
        self.calorieEstimator = calorieEstimator
    }

    func load() async {
        do {
            meals = try await mealStore.fetchMeals()
        } catch {
            meals = []
        }
    }

    func makeAddMealViewModel() -> AddMealViewModel {
        AddMealViewModel(mealStore: mealStore, calorieEstimator: calorieEstimator)
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
