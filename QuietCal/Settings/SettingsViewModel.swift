import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let store: SettingsStore

    var target: Int = 2000

    init(store: SettingsStore) {
        self.store = store
    }

    func load() async {
        if let loaded = try? await store.loadTarget() {
            target = loaded
        }
    }

    func updateTarget(_ newTarget: Int) {
        target = newTarget
        Task { try? await store.saveTarget(newTarget) }
    }

    var formattedTarget: String {
        "\(target.formatted()) kcal"
    }
}
