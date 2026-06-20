import Foundation

struct UserDefaultsSettingsStore: SettingsStore {
    static let targetKey = AppGroup.targetKey
    static let themeKey = AppGroup.themeKey
    static let weightUnitKey = AppGroup.weightUnitKey
    private static let defaultTarget = AppGroup.defaultTarget

    private let defaults: UserDefaults

    init(defaults: UserDefaults = AppGroup.sharedDefaults) {
        self.defaults = defaults
    }

    func loadTarget() async throws -> Int {
        let value = defaults.integer(forKey: Self.targetKey)
        return value > 0 ? value : Self.defaultTarget
    }

    func saveTarget(_ target: Int) async throws {
        defaults.set(target, forKey: Self.targetKey)
    }

    func loadTheme() async throws -> Theme {
        let raw = defaults.string(forKey: Self.themeKey) ?? Theme.system.rawValue
        return Theme(rawValue: raw) ?? .system
    }

    func saveTheme(_ theme: Theme) async throws {
        defaults.set(theme.rawValue, forKey: Self.themeKey)
    }

    func loadWeightUnit() async throws -> WeightUnit {
        let raw = defaults.string(forKey: Self.weightUnitKey) ?? WeightUnit.g.rawValue
        return WeightUnit(rawValue: raw) ?? .g
    }

    func saveWeightUnit(_ unit: WeightUnit) async throws {
        defaults.set(unit.rawValue, forKey: Self.weightUnitKey)
    }
}
