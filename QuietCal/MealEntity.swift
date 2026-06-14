import Foundation
import SwiftData

@Model
final class MealEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var grams: Int
    var kcal: Int
    var time: String
    var createdAt: Date

    init(id: UUID, name: String, grams: Int, kcal: Int, time: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.grams = grams
        self.kcal = kcal
        self.time = time
        self.createdAt = createdAt
    }

    convenience init(meal: Meal, createdAt: Date = Date()) {
        self.init(
            id: meal.id,
            name: meal.name,
            grams: meal.grams,
            kcal: meal.kcal,
            time: meal.time,
            createdAt: createdAt
        )
    }

    var asMeal: Meal {
        Meal(id: id, name: name, grams: grams, kcal: kcal, time: time)
    }
}
