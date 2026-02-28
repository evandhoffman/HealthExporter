import XCTest
@testable import HealthExporter

final class SettingsManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        clearUserDefaults()
    }

    override func tearDown() {
        clearUserDefaults()
        super.tearDown()
    }

    private func clearUserDefaults() {
        let keys = ["temperatureUnit", "weightUnit", "distanceSpeedUnit",
                    "exportWeight", "exportSteps", "exportGlucose", "exportA1C"]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }

    // MARK: - Default values

    func testDefaultTemperatureUnit_isCelsius() {
        let settings = SettingsManager()
        XCTAssertEqual(settings.temperatureUnit, .celsius)
    }

    func testDefaultWeightUnit_isKilograms() {
        let settings = SettingsManager()
        XCTAssertEqual(settings.weightUnit, .kilograms)
    }

    func testDefaultDistanceSpeedUnit_isMetric() {
        let settings = SettingsManager()
        XCTAssertEqual(settings.distanceSpeedUnit, .metric)
    }

    func testDefaultExportWeight_isTrue() {
        let settings = SettingsManager()
        XCTAssertTrue(settings.exportWeight)
    }

    func testDefaultExportSteps_isTrue() {
        let settings = SettingsManager()
        XCTAssertTrue(settings.exportSteps)
    }

    func testDefaultExportGlucose_isFalse() {
        let settings = SettingsManager()
        XCTAssertFalse(settings.exportGlucose)
    }

    func testDefaultExportA1C_isFalse() {
        let settings = SettingsManager()
        XCTAssertFalse(settings.exportA1C)
    }

    // MARK: - Persistence (didSet saves to UserDefaults)

    func testSetWeightUnit_persistsToPounds() {
        let settings = SettingsManager()
        settings.weightUnit = .pounds
        XCTAssertEqual(UserDefaults.standard.string(forKey: "weightUnit"), WeightUnit.pounds.rawValue)
    }

    func testSetTemperatureUnit_persistsToFahrenheit() {
        let settings = SettingsManager()
        settings.temperatureUnit = .fahrenheit
        XCTAssertEqual(
            UserDefaults.standard.string(forKey: "temperatureUnit"),
            TemperatureUnit.fahrenheit.rawValue
        )
    }

    func testSetDistanceSpeedUnit_persistsToImperial() {
        let settings = SettingsManager()
        settings.distanceSpeedUnit = .imperial
        XCTAssertEqual(
            UserDefaults.standard.string(forKey: "distanceSpeedUnit"),
            DistanceSpeedUnit.imperial.rawValue
        )
    }

    func testSetExportWeight_persistsFalse() {
        let settings = SettingsManager()
        settings.exportWeight = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "exportWeight"))
    }

    func testSetExportGlucose_persistsTrue() {
        let settings = SettingsManager()
        settings.exportGlucose = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "exportGlucose"))
    }

    // MARK: - Loading persisted values

    func testLoad_weightUnit_fromUserDefaults() {
        UserDefaults.standard.set(WeightUnit.pounds.rawValue, forKey: "weightUnit")
        let settings = SettingsManager()
        XCTAssertEqual(settings.weightUnit, .pounds)
    }

    func testLoad_temperatureUnit_fromUserDefaults() {
        UserDefaults.standard.set(TemperatureUnit.fahrenheit.rawValue, forKey: "temperatureUnit")
        let settings = SettingsManager()
        XCTAssertEqual(settings.temperatureUnit, .fahrenheit)
    }

    func testLoad_distanceSpeedUnit_fromUserDefaults() {
        UserDefaults.standard.set(DistanceSpeedUnit.imperial.rawValue, forKey: "distanceSpeedUnit")
        let settings = SettingsManager()
        XCTAssertEqual(settings.distanceSpeedUnit, .imperial)
    }

    func testLoad_exportGlucose_true_fromUserDefaults() {
        UserDefaults.standard.set(true, forKey: "exportGlucose")
        let settings = SettingsManager()
        XCTAssertTrue(settings.exportGlucose)
    }

    func testLoad_invalidWeightUnit_fallsBackToDefault() {
        UserDefaults.standard.set("invalid_unit_value", forKey: "weightUnit")
        let settings = SettingsManager()
        XCTAssertEqual(settings.weightUnit, .kilograms,
            "Invalid stored value should fall back to default (kilograms)")
    }

    func testLoad_invalidTemperatureUnit_fallsBackToDefault() {
        UserDefaults.standard.set("invalid", forKey: "temperatureUnit")
        let settings = SettingsManager()
        XCTAssertEqual(settings.temperatureUnit, .celsius,
            "Invalid stored value should fall back to default (celsius)")
    }

    // MARK: - A1C availability enforcement

    func testExportA1C_forcedFalse_whenA1CUnavailable() {
        // Store true in UserDefaults, but SettingsManager should override to false
        // when A1C is not available (BuildConfig.hasPaidDeveloperAccount == false)
        UserDefaults.standard.set(true, forKey: "exportA1C")
        let settings = SettingsManager()
        if !HealthMetrics.a1c.isAvailable {
            XCTAssertFalse(settings.exportA1C,
                "exportA1C must be false when A1C feature is unavailable, regardless of stored value")
        }
    }
}
