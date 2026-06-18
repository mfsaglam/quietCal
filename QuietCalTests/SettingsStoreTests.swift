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

    // MARK: - Theme

    @Test(arguments: Kind.allCases)
    func emptyStoreReturnsSystemTheme(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        let theme = try await store.loadTheme()
        #expect(theme == .system)
    }

    @Test(arguments: Kind.allCases)
    func savedThemeIsReturnedOnLoad(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        try await store.saveTheme(.dark)
        let loaded = try await store.loadTheme()
        #expect(loaded == .dark)
    }

    @Test(arguments: Kind.allCases)
    func saveThemeOverwritesPreviousValue(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        try await store.saveTheme(.dark)
        try await store.saveTheme(.light)
        let loaded = try await store.loadTheme()
        #expect(loaded == .light)
    }

    @Test
    func userDefaultsPersistsThemeAcrossInstances() async throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let first = UserDefaultsSettingsStore(defaults: defaults)
        try await first.saveTheme(.dark)

        let second = UserDefaultsSettingsStore(defaults: defaults)
        let loaded = try await second.loadTheme()
        #expect(loaded == .dark)
    }

    // MARK: - Weight unit

    @Test(arguments: Kind.allCases)
    func emptyStoreReturnsGramsAsDefaultUnit(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        let unit = try await store.loadWeightUnit()
        #expect(unit == .g)
    }

    @Test(arguments: Kind.allCases)
    func savedWeightUnitIsReturnedOnLoad(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        try await store.saveWeightUnit(.oz)
        let loaded = try await store.loadWeightUnit()
        #expect(loaded == .oz)
    }

    @Test(arguments: Kind.allCases)
    func saveWeightUnitOverwritesPreviousValue(_ kind: Kind) async throws {
        let (store, cleanup) = makeStore(kind)
        defer { cleanup() }

        try await store.saveWeightUnit(.oz)
        try await store.saveWeightUnit(.lb)
        let loaded = try await store.loadWeightUnit()
        #expect(loaded == .lb)
    }

    @Test
    func userDefaultsPersistsWeightUnitAcrossInstances() async throws {
        let suite = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let first = UserDefaultsSettingsStore(defaults: defaults)
        try await first.saveWeightUnit(.lb)

        let second = UserDefaultsSettingsStore(defaults: defaults)
        let loaded = try await second.loadWeightUnit()
        #expect(loaded == .lb)
    }
}
