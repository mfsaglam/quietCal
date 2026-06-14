import Foundation

struct Meal: Identifiable, Sendable {
    let id: UUID
    let name: String
    let grams: Int
    let kcal: Int
    let createdAt: Date

    init(id: UUID = UUID(), name: String, grams: Int, kcal: Int, createdAt: Date) {
        self.id = id
        self.name = name
        self.grams = grams
        self.kcal = kcal
        self.createdAt = createdAt
    }

    var timeString: String {
        createdAt.formatted(
            .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)
        )
    }
}
