import Testing
import Foundation
@testable import QuietCal

@Suite("SettingsStore")
struct SettingsStoreTests {

    enum Kind: String, CaseIterable, Sendable, CustomStringConvertible {
        case inMemory
        case userDefaults

        var description: String { rawValue }
    }

    private func makeStore(_ kind: Kind) -> (any SettingsStore, () -> Void) {
        switch kind {
        case .inMemory:
            return (InMemorySettingsStore(), {})
        case .userDefaults:
            let suite = "test.\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            return (
                UserDefaultsSettingsStore(defaults: defaults),
                { defaults.removePersistentDomain(forName: suite) }
            )
        }
    }

    @Test(arguments: Kind.allCases)
    func emptyStoreReturnsDefaultTarget(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        let target = try await store.loadTarget()
        #expect(target == 2000)
    }

    @Test(arguments: Kind.allCases)
    func savedTargetIsReturnedOnLoad(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        try await store.saveTarget(2400)
        let loaded = try await store.loadTarget()
        #expect(loaded == 2400)
    }

    @Test(arguments: Kind.allCases)
    func saveOverwritesPreviousValue(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        try await store.saveTarget(2400)
        try await store.saveTarget(1800)
        let loaded = try await store.loadTarget()
        #expect(loaded == 1800)
    }

    @Test
    func userDefaultsPersistsAcrossInstances() async throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let firstStore = UserDefaultsSettingsStore(defaults: defaults)
        try await firstStore.saveTarget(2500)

        let secondStore = UserDefaultsSettingsStore(defaults: defaults)
        let loaded = try await secondStore.loadTarget()
        #expect(loaded == 2500)
    }

    @Test
    func inMemoryDoesNotPersistAcrossInstances() async throws {
        let firstStore = InMemorySettingsStore()
        try await firstStore.saveTarget(2500)

        let secondStore = InMemorySettingsStore()
        let loaded = try await secondStore.loadTarget()
        #expect(loaded == 2000)
    }
}
