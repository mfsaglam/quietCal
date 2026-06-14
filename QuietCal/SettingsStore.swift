import Foundation

protocol SettingsStore: Sendable {
    func loadTarget() async throws -> Int
    func saveTarget(_ target: Int) async throws
}
