import Foundation
import Observation

@Observable
final class HomeViewModel {
    var target = 2000
    var meals: [Meal] = [
        Meal(name: "Oatmeal with berries", grams: 220, kcal: 310, time: "08:15"),
        Meal(name: "Chicken salad", grams: 340, kcal: 520, time: "12:45"),
        Meal(name: "Apple", grams: 180, kcal: 95, time: "15:20"),
        Meal(name: "Coffee with milk", grams: 240, kcal: 80, time: "16:10"),
    ]

    var eaten: Int { meals.reduce(0) { $0 + $1.kcal } }
    var remaining: Int { target - eaten }
    var progress: Double { min(Double(eaten) / Double(target), 1.0) }
    var isOverTarget: Bool { eaten > target }
    var dateLabel: String { "THURSDAY · APR 18" }
}
