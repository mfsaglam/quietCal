import Foundation
import SwiftData

@ModelActor
actor SwiftDataMealStore: MealStore {
    func fetchMeals() async throws -> [Meal] {
        let descriptor = FetchDescriptor<MealEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let entities = try modelContext.fetch(descriptor)
        return entities.map(\.asMeal)
    }

    func save(_ meal: Meal) async throws {
        modelContext.insert(MealEntity(meal: meal))
        try modelContext.save()
    }

    func delete(_ meal: Meal) async throws {
        let id = meal.id
        let descriptor = FetchDescriptor<MealEntity>(
            predicate: #Predicate { $0.id == id }
        )
        for entity in try modelContext.fetch(descriptor) {
            modelContext.delete(entity)
        }
        try modelContext.save()
    }
}
