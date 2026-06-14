import Foundation

actor InMemorySettingsStore: SettingsStore {
    private var target: Int

    init(target: Int = 2000) {
        self.target = target
    }

    func loadTarget() async throws -> Int {
        target
    }

    func saveTarget(_ target: Int) async throws {
        self.target = target
    }
}
