import Foundation
import SwiftData

@Model
final class MealEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var grams: Int
    var kcal: Int
    var createdAt: Date

    init(id: UUID, name: String, grams: Int, kcal: Int, createdAt: Date) {
        self.id = id
        self.name = name
        self.grams = grams
        self.kcal = kcal
        self.createdAt = createdAt
    }

    convenience init(meal: Meal) {
        self.init(
            id: meal.id,
            name: meal.name,
            grams: meal.grams,
            kcal: meal.kcal,
            createdAt: meal.createdAt
        )
    }

    var asMeal: Meal {
        Meal(id: id, name: name, grams: grams, kcal: kcal, createdAt: createdAt)
    }
}
