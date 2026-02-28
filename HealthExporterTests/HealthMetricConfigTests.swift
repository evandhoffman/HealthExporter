import XCTest
@testable import HealthExporter

final class HealthMetricConfigTests: XCTestCase {

    // MARK: - HealthMetricConfig.isAvailable

    func testIsAvailable_whenNotRequiringPaidAccount_isAlwaysTrue() {
        let config = HealthMetricConfig(name: "Free Metric", requiresPaidAccount: false)
        XCTAssertTrue(config.isAvailable)
    }

    func testIsAvailable_whenRequiringPaidAccount_matchesBuildConfig() {
        let config = HealthMetricConfig(name: "Paid Metric", requiresPaidAccount: true)
        // isAvailable should be true only when BuildConfig.hasPaidDeveloperAccount is true
        XCTAssertEqual(config.isAvailable, BuildConfig.hasPaidDeveloperAccount)
    }

    // MARK: - HealthMetrics static properties

    func testWeight_doesNotRequirePaidAccount() {
        XCTAssertFalse(HealthMetrics.weight.requiresPaidAccount)
        XCTAssertEqual(HealthMetrics.weight.name, "Weight")
        XCTAssertTrue(HealthMetrics.weight.isAvailable)
    }

    func testSteps_doesNotRequirePaidAccount() {
        XCTAssertFalse(HealthMetrics.steps.requiresPaidAccount)
        XCTAssertEqual(HealthMetrics.steps.name, "Steps")
        XCTAssertTrue(HealthMetrics.steps.isAvailable)
    }

    func testGlucose_doesNotRequirePaidAccount() {
        XCTAssertFalse(HealthMetrics.glucose.requiresPaidAccount)
        XCTAssertEqual(HealthMetrics.glucose.name, "Blood Glucose")
        XCTAssertTrue(HealthMetrics.glucose.isAvailable)
    }

    func testA1C_requiresPaidAccount() {
        XCTAssertTrue(HealthMetrics.a1c.requiresPaidAccount)
        XCTAssertEqual(HealthMetrics.a1c.name, "Hemoglobin A1C")
    }

    func testA1C_isAvailability_matchesBuildConfig() {
        XCTAssertEqual(HealthMetrics.a1c.isAvailable, BuildConfig.hasPaidDeveloperAccount)
    }

    func testA1C_isUnavailable_whenFreeAccount() {
        // With BuildConfig.hasPaidDeveloperAccount = false (the default), A1C should be unavailable
        if !BuildConfig.hasPaidDeveloperAccount {
            XCTAssertFalse(HealthMetrics.a1c.isAvailable,
                "A1C should be unavailable when hasPaidDeveloperAccount is false")
        }
    }

    // MARK: - LOINCCode constants

    func testLOINCCode_hemoglobinA1C_isCorrect() {
        XCTAssertEqual(LOINCCode.hemoglobinA1C, "4548-4",
            "LOINC code for Hemoglobin A1C should be 4548-4")
    }
}
