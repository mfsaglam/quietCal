import Foundation

protocol SettingsStore: Sendable {
    func loadTarget() async throws -> Int
    func saveTarget(_ target: Int) async throws
    func loadTheme() async throws -> Theme
    func saveTheme(_ theme: Theme) async throws
    func loadWeightUnit() async throws -> WeightUnit
    func saveWeightUnit(_ unit: WeightUnit) async throws
}
