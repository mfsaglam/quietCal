import Testing
import Foundation
@testable import QuietCal

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    private func makeViewModel(
        settings: any SettingsStore = InMemorySettingsStore(),
        meals: any MealStore = InMemoryMealStore(meals: [])
    ) -> SettingsViewModel {
        SettingsViewModel(store: settings, mealStore: meals)
    }

    @Test func initialTargetBeforeLoad() {
        let vm = makeViewModel(settings: InMemorySettingsStore(target: 2400))
        #expect(vm.target == 2000)
    }

    @Test func loadReadsTargetFromStore() async {
        let vm = makeViewModel(settings: InMemorySettingsStore(target: 2400))
        await vm.load()
        #expect(vm.target == 2400)
    }

    @Test func updateTargetSetsLocally() {
        let vm = makeViewModel()
        vm.updateTarget(2400)
        #expect(vm.target == 2400)
    }

    @Test func updateTargetPersistsToStore() async throws {
        let store = InMemorySettingsStore()
        let vm = makeViewModel(settings: store)

        vm.updateTarget(2400)
        try? await Task.sleep(for: .milliseconds(100))

        let persisted = try await store.loadTarget()
        #expect(persisted == 2400)
    }

    @Test func updateTargetOverwritesPreviousValue() async throws {
        let store = InMemorySettingsStore()
        let vm = makeViewModel(settings: store)

        vm.updateTarget(2400)
        vm.updateTarget(1800)
        try? await Task.sleep(for: .milliseconds(100))

        let persisted = try await store.loadTarget()
        #expect(persisted == 1800)
    }

    @Test func formattedTargetIncludesValueAndUnit() {
        let vm = makeViewModel()
        vm.target = 2000
        let formatted = vm.formattedTarget
        #expect(formatted.contains("kcal"))
        #expect(!formatted.isEmpty)
    }

    // MARK: - Reset today / clear all

    @Test func resetTodayDeletesOnlyTodaysMeals() async throws {
        let yesterday = Date().addingTimeInterval(-86400)
        let now = Date()
        let store = InMemoryMealStore(meals: [
            Meal(name: "Yesterday", grams: 100, kcal: 100, createdAt: yesterday),
            Meal(name: "Today", grams: 100, kcal: 200, createdAt: now)
        ])
        let vm = makeViewModel(meals: store)

        await vm.resetToday()

        let allInterval = DateInterval(start: .distantPast, end: .distantFuture)
        let remaining = try await store.fetchMeals(in: allInterval)
        #expect(remaining.map(\.name) == ["Yesterday"])
    }

    @Test func clearAllDeletesEveryMeal() async throws {
        let store = InMemoryMealStore(meals: [
            Meal(name: "A", grams: 100, kcal: 100,
                 createdAt: Date().addingTimeInterval(-86400)),
            Meal(name: "B", grams: 100, kcal: 200, createdAt: Date())
        ])
        let vm = makeViewModel(meals: store)

        await vm.clearAll()

        let allInterval = DateInterval(start: .distantPast, end: .distantFuture)
        let remaining = try await store.fetchMeals(in: allInterval)
        #expect(remaining.isEmpty)
    }

    // MARK: - CSV

    @Test func generateCSVProducesHeaderEvenWhenEmpty() async {
        let vm = makeViewModel(meals: InMemoryMealStore(meals: []))
        let csv = await vm.generateCSV()
        #expect(csv == "date,time,name,grams,kcal")
    }

    @Test func generateCSVIncludesEveryMeal() async {
        let store = InMemoryMealStore(meals: [
            Meal(name: "A", grams: 100, kcal: 100,
                 createdAt: Date().addingTimeInterval(-86400)),
            Meal(name: "B", grams: 200, kcal: 300, createdAt: Date())
        ])
        let vm = makeViewModel(meals: store)
        let csv = await vm.generateCSV()
        let lines = csv.split(separator: "\n")
        #expect(lines.count == 3) // header + 2 rows
        #expect(lines[1].contains("A,100,100") || lines[1].contains("B,200,300"))
    }

    // MARK: - Theme

    @Test func initialThemeBeforeLoad() {
        let vm = makeViewModel(settings: InMemorySettingsStore(theme: .dark))
        #expect(vm.theme == .system)
    }

    @Test func loadReadsThemeFromStore() async {
        let vm = makeViewModel(settings: InMemorySettingsStore(theme: .dark))
        await vm.load()
        #expect(vm.theme == .dark)
    }

    @Test func updateThemeSetsLocally() {
        let vm = makeViewModel()
        vm.updateTheme(.light)
        #expect(vm.theme == .light)
    }

    @Test func updateThemePersistsToStore() async throws {
        let store = InMemorySettingsStore()
        let vm = makeViewModel(settings: store)

        vm.updateTheme(.dark)
        try? await Task.sleep(for: .milliseconds(100))

        let persisted = try await store.loadTheme()
        #expect(persisted == .dark)
    }

    // MARK: - Weight unit

    @Test func initialWeightUnitBeforeLoad() {
        let vm = makeViewModel(settings: InMemorySettingsStore(weightUnit: .lb))
        #expect(vm.weightUnit == .g)
    }

    @Test func loadReadsWeightUnitFromStore() async {
        let vm = makeViewModel(settings: InMemorySettingsStore(weightUnit: .oz))
        await vm.load()
        #expect(vm.weightUnit == .oz)
    }

    @Test func updateWeightUnitSetsLocally() {
        let vm = makeViewModel()
        vm.updateWeightUnit(.lb)
        #expect(vm.weightUnit == .lb)
    }

    @Test func updateWeightUnitPersistsToStore() async throws {
        let store = InMemorySettingsStore()
        let vm = makeViewModel(settings: store)

        vm.updateWeightUnit(.oz)
        try? await Task.sleep(for: .milliseconds(100))

        let persisted = try await store.loadWeightUnit()
        #expect(persisted == .oz)
    }
}
