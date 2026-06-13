import Foundation

final class InMemoryMealStore: MealStore {
    private let meals: [Meal]

    init(meals: [Meal] = .sample) {
        self.meals = meals
    }

    func fetchMeals() async throws -> [Meal] {
        meals
    }
}

extension Array where Element == Meal {
    static var sample: [Meal] {
        [
            Meal(name: "Oatmeal with berries", grams: 220, kcal: 310, time: "08:15"),
            Meal(name: "Chicken salad", grams: 340, kcal: 520, time: "12:45"),
            Meal(name: "Apple", grams: 180, kcal: 95, time: "15:20"),
            Meal(name: "Coffee with milk", grams: 240, kcal: 80, time: "16:10"),
        ]
    }
}
