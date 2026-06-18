import Foundation

actor InMemorySettingsStore: SettingsStore {
    private var target: Int
    private var theme: Theme
    private var weightUnit: WeightUnit

    init(target: Int = 2000, theme: Theme = .system, weightUnit: WeightUnit = .g) {
        self.target = target
        self.theme = theme
        self.weightUnit = weightUnit
    }

    func loadTarget() async throws -> Int {
        target
    }

    func saveTarget(_ target: Int) async throws {
        self.target = target
    }

    func loadTheme() async throws -> Theme {
        theme
    }

    func saveTheme(_ theme: Theme) async throws {
        self.theme = theme
    }

    func loadWeightUnit() async throws -> WeightUnit {
        weightUnit
    }

    func saveWeightUnit(_ unit: WeightUnit) async throws {
        weightUnit = unit
    }
}
