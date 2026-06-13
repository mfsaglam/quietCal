import Foundation

actor InMemoryMealStore: MealStore {
    private var meals: [Meal]

    init(meals: [Meal] = .sample) {
        self.meals = meals
    }

    func fetchMeals() async throws -> [Meal] {
        meals
    }

    func save(_ meal: Meal) async throws {
        meals.append(meal)
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

    static var overTarget: [Meal] {
        [
            Meal(name: "Breakfast burrito", grams: 320, kcal: 580, time: "08:30"),
            Meal(name: "Pasta carbonara", grams: 410, kcal: 720, time: "13:00"),
            Meal(name: "Cheeseburger", grams: 280, kcal: 650, time: "19:15"),
            Meal(name: "Ice cream", grams: 150, kcal: 380, time: "21:00"),
            Meal(name: "Coffee with milk", grams: 240, kcal: 80, time: "21:30"),
        ]
    }

    static var onTarget: [Meal] {
        [
            Meal(name: "Oatmeal with berries", grams: 220, kcal: 310, time: "08:15"),
            Meal(name: "Chicken bowl", grams: 380, kcal: 650, time: "12:45"),
            Meal(name: "Greek yogurt", grams: 170, kcal: 180, time: "15:30"),
            Meal(name: "Salmon with rice", grams: 360, kcal: 720, time: "19:30"),
            Meal(name: "Tea with honey", grams: 220, kcal: 140, time: "21:15"),
        ]
    }

    static var empty: [Meal] { [] }
}
