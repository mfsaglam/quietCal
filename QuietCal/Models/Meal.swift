import Foundation

nonisolated struct Meal: Identifiable, Sendable {
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

extension String {
    /// A stable key for matching meal names entered with different casing,
    /// whitespace, accents, or character widths.
    nonisolated var normalizedMealName: String {
        trimmingCharacters(in: .whitespacesAndNewlines).folding(
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
    }
}
