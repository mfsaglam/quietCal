import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let mealStore: MealStore

    var target = 2000
    var meals: [Meal] = []

    init(mealStore: MealStore) {
        self.mealStore = mealStore
    }

    func load() async {
        do {
            meals = try await mealStore.fetchMeals()
        } catch {
            meals = []
        }
    }

    var eaten: Int { meals.reduce(0) { $0 + $1.kcal } }
    var remaining: Int { target - eaten }
    var progress: Double { min(Double(eaten) / Double(target), 1.0) }
    var isOverTarget: Bool { eaten > target }
    var dateLabel: String {
        let date = Date()
        let weekday = date.formatted(.dateTime.weekday(.wide)).uppercased()
        let month = date.formatted(.dateTime.month(.abbreviated)).uppercased()
        let day = date.formatted(.dateTime.day())
        return "\(weekday) · \(month) \(day)"
    }
}
