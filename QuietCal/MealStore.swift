import Foundation

protocol MealStore: Sendable {
    func fetchMeals() async throws -> [Meal]
}
