import Foundation

struct UserDefaultsSettingsStore: SettingsStore {
    private static let targetKey = "settings.target"
    private static let defaultTarget = 2000

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadTarget() async throws -> Int {
        let value = defaults.integer(forKey: Self.targetKey)
        return value > 0 ? value : Self.defaultTarget
    }

    func saveTarget(_ target: Int) async throws {
        defaults.set(target, forKey: Self.targetKey)
    }
}
