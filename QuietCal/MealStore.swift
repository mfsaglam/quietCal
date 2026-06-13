import Foundation

protocol MealStore: Sendable {
    func fetchMeals() async throws -> [Meal]
    func save(_ meal: Meal) async throws
}
