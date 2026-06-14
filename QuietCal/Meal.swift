import Foundation

struct Meal: Identifiable, Sendable {
    let id: UUID
    let name: String
    let grams: Int
    let kcal: Int
    let time: String

    init(id: UUID = UUID(), name: String, grams: Int, kcal: Int, time: String) {
        self.id = id
        self.name = name
        self.grams = grams
        self.kcal = kcal
        self.time = time
    }
}
