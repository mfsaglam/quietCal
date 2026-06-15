import Foundation
import SwiftData

@ModelActor
actor SwiftDataMealStore: MealStore {
    func fetchMeals(in interval: DateInterval) async throws -> [Meal] {
        let start = interval.start
        let end = interval.end
        let descriptor = FetchDescriptor<MealEntity>(
            predicate: #Predicate { $0.createdAt >= start && $0.createdAt < end },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor).map(\.asMeal)
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

    func deleteMeals(in interval: DateInterval) async throws {
        let start = interval.start
        let end = interval.end
        try modelContext.delete(
            model: MealEntity.self,
            where: #Predicate { $0.createdAt >= start && $0.createdAt < end }
        )
        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: MealEntity.self)
        try modelContext.save()
    }
}
