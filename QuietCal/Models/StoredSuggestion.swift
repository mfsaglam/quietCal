import Foundation

nonisolated enum MealPeriod: String, CaseIterable, Sendable {
    case breakfast
    case lunch
    case afternoon
    case dinner
    case lateNight

    init(hour: Int) {
        switch hour {
        case 5..<11: self = .breakfast
        case 11..<15: self = .lunch
        case 15..<18: self = .afternoon
        case 18..<22: self = .dinner
        default: self = .lateNight
        }
    }

    init(date: Date, calendar: Calendar) {
        self.init(hour: calendar.component(.hour, from: date))
    }

    var label: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .afternoon: return "Afternoon"
        case .dinner: return "Dinner"
        case .lateNight: return "Late Night"
        }
    }
}

/// A unique quick-log suggestion. Repeated logs update the relevant period's
/// usage metadata instead of inserting duplicate records.
nonisolated struct StoredSuggestion: Identifiable, Equatable, Sendable {
    let id: UUID
    let key: String
    var name: String
    let grams: Int
    var kcal: Int

    var breakfastCount: Int
    var breakfastLastUsedAt: Date?
    var lunchCount: Int
    var lunchLastUsedAt: Date?
    var afternoonCount: Int
    var afternoonLastUsedAt: Date?
    var dinnerCount: Int
    var dinnerLastUsedAt: Date?
    var lateNightCount: Int
    var lateNightLastUsedAt: Date?

    init(meal: Meal, period: MealPeriod) {
        id = UUID()
        key = Self.key(name: meal.name, grams: meal.grams)
        name = meal.name.trimmingCharacters(in: .whitespacesAndNewlines)
        grams = meal.grams
        kcal = meal.kcal
        breakfastCount = 0
        breakfastLastUsedAt = nil
        lunchCount = 0
        lunchLastUsedAt = nil
        afternoonCount = 0
        afternoonLastUsedAt = nil
        dinnerCount = 0
        dinnerLastUsedAt = nil
        lateNightCount = 0
        lateNightLastUsedAt = nil
        record(meal: meal, period: period)
    }

    init(
        id: UUID,
        key: String,
        name: String,
        grams: Int,
        kcal: Int,
        breakfastCount: Int,
        breakfastLastUsedAt: Date?,
        lunchCount: Int,
        lunchLastUsedAt: Date?,
        afternoonCount: Int,
        afternoonLastUsedAt: Date?,
        dinnerCount: Int,
        dinnerLastUsedAt: Date?,
        lateNightCount: Int,
        lateNightLastUsedAt: Date?
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.grams = grams
        self.kcal = kcal
        self.breakfastCount = breakfastCount
        self.breakfastLastUsedAt = breakfastLastUsedAt
        self.lunchCount = lunchCount
        self.lunchLastUsedAt = lunchLastUsedAt
        self.afternoonCount = afternoonCount
        self.afternoonLastUsedAt = afternoonLastUsedAt
        self.dinnerCount = dinnerCount
        self.dinnerLastUsedAt = dinnerLastUsedAt
        self.lateNightCount = lateNightCount
        self.lateNightLastUsedAt = lateNightLastUsedAt
    }

    static func key(name: String, grams: Int) -> String {
        "\(name.normalizedMealName)\u{1F}\(grams)"
    }

    mutating func record(meal: Meal, period: MealPeriod) {
        name = meal.name.trimmingCharacters(in: .whitespacesAndNewlines)
        kcal = meal.kcal
        switch period {
        case .breakfast:
            breakfastCount += 1
            breakfastLastUsedAt = meal.createdAt
        case .lunch:
            lunchCount += 1
            lunchLastUsedAt = meal.createdAt
        case .afternoon:
            afternoonCount += 1
            afternoonLastUsedAt = meal.createdAt
        case .dinner:
            dinnerCount += 1
            dinnerLastUsedAt = meal.createdAt
        case .lateNight:
            lateNightCount += 1
            lateNightLastUsedAt = meal.createdAt
        }
    }

    func count(for period: MealPeriod) -> Int {
        switch period {
        case .breakfast: breakfastCount
        case .lunch: lunchCount
        case .afternoon: afternoonCount
        case .dinner: dinnerCount
        case .lateNight: lateNightCount
        }
    }

    func lastUsedAt(for period: MealPeriod) -> Date? {
        switch period {
        case .breakfast: breakfastLastUsedAt
        case .lunch: lunchLastUsedAt
        case .afternoon: afternoonLastUsedAt
        case .dinner: dinnerLastUsedAt
        case .lateNight: lateNightLastUsedAt
        }
    }
}
