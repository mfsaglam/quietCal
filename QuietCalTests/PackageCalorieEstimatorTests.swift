import Testing
@testable import QuietCal

@Suite("PackageCalorieEstimator")
struct PackageCalorieEstimatorTests {
    @Test func localDatabaseEstimateSucceedsWithoutModelAvailability() async throws {
        let result = try await PackageCalorieEstimator().estimate(name: "apple", grams: 100)

        #expect(result.calories == 52)
        #expect(result.source == .localDatabase)
        #expect(result.confidence == .high)
    }
}
