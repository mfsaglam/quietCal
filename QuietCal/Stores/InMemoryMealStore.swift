import Foundation

actor InMemoryMealStore: MealStore {
    private var meals: [Meal]

    init(meals: [Meal] = .sample) {
        self.meals = meals
    }

    func fetchMeals(in interval: DateInterval) async throws -> [Meal] {
        meals
            .filter { $0.createdAt >= interval.start && $0.createdAt < interval.end }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func save(_ meal: Meal) async throws {
        meals.append(meal)
    }

    func delete(_ meal: Meal) async throws {
        meals.removeAll { $0.id == meal.id }
    }
}

private func todayAt(_ hour: Int, _ minute: Int) -> Date {
    Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
}

extension Array where Element == Meal {
    static var sample: [Meal] {
        [
            Meal(name: "Oatmeal with berries", grams: 220, kcal: 310, createdAt: todayAt(8, 15)),
            Meal(name: "Chicken salad", grams: 340, kcal: 520, createdAt: todayAt(12, 45)),
            Meal(name: "Apple", grams: 180, kcal: 95, createdAt: todayAt(15, 20)),
            Meal(name: "Coffee with milk", grams: 240, kcal: 80, createdAt: todayAt(16, 10)),
        ]
    }

    static var overTarget: [Meal] {
        [
            Meal(name: "Breakfast burrito", grams: 320, kcal: 580, createdAt: todayAt(8, 30)),
            Meal(name: "Pasta carbonara", grams: 410, kcal: 720, createdAt: todayAt(13, 0)),
            Meal(name: "Cheeseburger", grams: 280, kcal: 650, createdAt: todayAt(19, 15)),
            Meal(name: "Ice cream", grams: 150, kcal: 380, createdAt: todayAt(21, 0)),
            Meal(name: "Coffee with milk", grams: 240, kcal: 80, createdAt: todayAt(21, 30)),
        ]
    }

    static var onTarget: [Meal] {
        [
            Meal(name: "Oatmeal with berries", grams: 220, kcal: 310, createdAt: todayAt(8, 15)),
            Meal(name: "Chicken bowl", grams: 380, kcal: 650, createdAt: todayAt(12, 45)),
            Meal(name: "Greek yogurt", grams: 170, kcal: 180, createdAt: todayAt(15, 30)),
            Meal(name: "Salmon with rice", grams: 360, kcal: 720, createdAt: todayAt(19, 30)),
            Meal(name: "Tea with honey", grams: 220, kcal: 140, createdAt: todayAt(21, 15)),
        ]
    }

    static var empty: [Meal] { [] }
}
