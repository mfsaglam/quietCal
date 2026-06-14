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
}
