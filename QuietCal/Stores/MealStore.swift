import Foundation

protocol MealStore: Sendable {
    func fetchMeals(in interval: DateInterval) async throws -> [Meal]
    func save(_ meal: Meal) async throws
    func delete(_ meal: Meal) async throws
    func deleteMeals(in interval: DateInterval) async throws
    func deleteAll() async throws
}
