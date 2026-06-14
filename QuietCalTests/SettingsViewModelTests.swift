import Testing
import Foundation
@testable import QuietCal

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    @Test func initialTargetBeforeLoad() {
        let vm = SettingsViewModel(store: InMemorySettingsStore(target: 2400))
        #expect(vm.target == 2000)
    }

    @Test func loadReadsTargetFromStore() async {
        let vm = SettingsViewModel(store: InMemorySettingsStore(target: 2400))
        await vm.load()
        #expect(vm.target == 2400)
    }

    @Test func updateTargetSetsLocally() {
        let vm = SettingsViewModel(store: InMemorySettingsStore())
        vm.updateTarget(2400)
        #expect(vm.target == 2400)
    }

    @Test func updateTargetPersistsToStore() async throws {
        let store = InMemorySettingsStore()
        let vm = SettingsViewModel(store: store)

        vm.updateTarget(2400)

        // give the fire-and-forget Task a chance to write
        try? await Task.sleep(for: .milliseconds(100))

        let persisted = try await store.loadTarget()
        #expect(persisted == 2400)
    }

    @Test func updateTargetOverwritesPreviousValue() async throws {
        let store = InMemorySettingsStore()
        let vm = SettingsViewModel(store: store)

        vm.updateTarget(2400)
        vm.updateTarget(1800)

        try? await Task.sleep(for: .milliseconds(100))

        let persisted = try await store.loadTarget()
        #expect(persisted == 1800)
    }

    @Test func formattedTargetIncludesValueAndUnit() {
        let vm = SettingsViewModel(store: InMemorySettingsStore())
        vm.target = 2000
        let formatted = vm.formattedTarget
        #expect(formatted.contains("kcal"))
        #expect(!formatted.isEmpty)
    }
}
