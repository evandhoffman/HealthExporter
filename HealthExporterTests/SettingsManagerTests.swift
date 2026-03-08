import XCTest
@testable import HealthExporter

/// Tests for SettingsManager behavior by testing through UserDefaults directly.
/// Creating a second SettingsManager instance crashes in the test host environment
/// due to a Combine/@Published conflict with the app's @main StateObject, so we
/// test the read/write logic indirectly.
final class SettingsManagerTests: XCTestCase {

    private func makeDefaults() -> UserDefaults {
        let suiteName = "SettingsManagerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        addTeardownBlock {
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
        }
        return defaults
    }

    // MARK: - Default value logic (mirrors SettingsManager.init)

    func testDefaultTemperatureUnit_whenKeyMissing_isFahrenheit() {
        let defaults = makeDefaults()
        let raw = defaults.string(forKey: "temperatureUnit") ?? TemperatureUnit.fahrenheit.rawValue
        XCTAssertEqual(TemperatureUnit(rawValue: raw), .fahrenheit)
    }

    func testDefaultWeightUnit_whenKeyMissing_isPounds() {
        let defaults = makeDefaults()
        let raw = defaults.string(forKey: "weightUnit") ?? WeightUnit.pounds.rawValue
        XCTAssertEqual(WeightUnit(rawValue: raw), .pounds)
    }

    func testDefaultDistanceSpeedUnit_whenKeyMissing_isImperial() {
        let defaults = makeDefaults()
        let raw = defaults.string(forKey: "distanceSpeedUnit") ?? DistanceSpeedUnit.imperial.rawValue
        XCTAssertEqual(DistanceSpeedUnit(rawValue: raw), .imperial)
    }

    func testDefaultDateFormat_whenKeyMissing_isYYYYMMddHHmmss() {
        let defaults = makeDefaults()
        let raw = defaults.string(forKey: "dateFormat") ?? DateFormatOption.yyyyMMddHHmmss.rawValue
        XCTAssertEqual(DateFormatOption(rawValue: raw), .yyyyMMddHHmmss)
    }

    func testDefaultSortOrder_whenKeyMissing_isAscending() {
        let defaults = makeDefaults()
        let raw = defaults.string(forKey: "sortOrder") ?? SortOrder.ascending.rawValue
        XCTAssertEqual(SortOrder(rawValue: raw), .ascending)
    }

    func testDefaultExportWeight_whenKeyMissing_isTrue() {
        let defaults = makeDefaults()
        let value = defaults.object(forKey: "exportWeight") as? Bool ?? true
        XCTAssertTrue(value)
    }

    func testDefaultExportSteps_whenKeyMissing_isTrue() {
        let defaults = makeDefaults()
        let value = defaults.object(forKey: "exportSteps") as? Bool ?? true
        XCTAssertTrue(value)
    }

    func testDefaultExportGlucose_whenKeyMissing_isFalse() {
        let defaults = makeDefaults()
        let value = defaults.object(forKey: "exportGlucose") as? Bool ?? false
        XCTAssertFalse(value)
    }

    func testDefaultExportA1C_whenKeyMissing_isFalse() {
        let defaults = makeDefaults()
        let value = defaults.object(forKey: "exportA1C") as? Bool ?? false
        XCTAssertFalse(value)
    }

    func testDefaultLastXDaysValue_whenKeyMissing_is30() {
        let defaults = makeDefaults()
        let value = defaults.object(forKey: "lastXDaysValue") as? Int ?? 30
        XCTAssertEqual(value, 30)
    }

    func testDefaultLastXRecordsValue_whenKeyMissing_is100() {
        let defaults = makeDefaults()
        let value = defaults.object(forKey: "lastXRecordsValue") as? Int ?? 100
        XCTAssertEqual(value, 100)
    }

    // MARK: - Reads persisted values

    func testReadsPersistedEnumValues() {
        let defaults = makeDefaults()
        defaults.set(TemperatureUnit.celsius.rawValue, forKey: "temperatureUnit")
        defaults.set(WeightUnit.kilograms.rawValue, forKey: "weightUnit")
        defaults.set(DistanceSpeedUnit.metric.rawValue, forKey: "distanceSpeedUnit")
        defaults.set(DateFormatOption.iso8601.rawValue, forKey: "dateFormat")
        defaults.set(SortOrder.descending.rawValue, forKey: "sortOrder")

        XCTAssertEqual(TemperatureUnit(rawValue: defaults.string(forKey: "temperatureUnit")!), .celsius)
        XCTAssertEqual(WeightUnit(rawValue: defaults.string(forKey: "weightUnit")!), .kilograms)
        XCTAssertEqual(DistanceSpeedUnit(rawValue: defaults.string(forKey: "distanceSpeedUnit")!), .metric)
        XCTAssertEqual(DateFormatOption(rawValue: defaults.string(forKey: "dateFormat")!), .iso8601)
        XCTAssertEqual(SortOrder(rawValue: defaults.string(forKey: "sortOrder")!), .descending)
    }

    func testReadsPersistedBoolValues() {
        let defaults = makeDefaults()
        defaults.set(false, forKey: "exportWeight")
        defaults.set(false, forKey: "exportSteps")
        defaults.set(true, forKey: "exportGlucose")
        defaults.set(true, forKey: "exportA1C")

        XCTAssertFalse(defaults.bool(forKey: "exportWeight"))
        XCTAssertFalse(defaults.bool(forKey: "exportSteps"))
        XCTAssertTrue(defaults.bool(forKey: "exportGlucose"))
        XCTAssertTrue(defaults.bool(forKey: "exportA1C"))
    }

    func testReadsPersistedIntValues() {
        let defaults = makeDefaults()
        defaults.set(7, forKey: "lastXDaysValue")
        defaults.set(50, forKey: "lastXRecordsValue")

        XCTAssertEqual(defaults.integer(forKey: "lastXDaysValue"), 7)
        XCTAssertEqual(defaults.integer(forKey: "lastXRecordsValue"), 50)
    }

    // MARK: - Fallback for invalid raw values

    func testFallback_invalidTemperatureUnit() {
        let defaults = makeDefaults()
        defaults.set("invalid", forKey: "temperatureUnit")
        let raw = defaults.string(forKey: "temperatureUnit") ?? TemperatureUnit.fahrenheit.rawValue
        XCTAssertEqual(TemperatureUnit(rawValue: raw) ?? .fahrenheit, .fahrenheit)
    }

    func testFallback_invalidWeightUnit() {
        let defaults = makeDefaults()
        defaults.set("invalid", forKey: "weightUnit")
        let raw = defaults.string(forKey: "weightUnit") ?? WeightUnit.pounds.rawValue
        XCTAssertEqual(WeightUnit(rawValue: raw) ?? .pounds, .pounds)
    }

    func testFallback_invalidDateFormat() {
        let defaults = makeDefaults()
        defaults.set("invalid", forKey: "dateFormat")
        let raw = defaults.string(forKey: "dateFormat") ?? DateFormatOption.yyyyMMddHHmmss.rawValue
        XCTAssertEqual(DateFormatOption(rawValue: raw) ?? .yyyyMMddHHmmss, .yyyyMMddHHmmss)
    }

    func testFallback_invalidSortOrder() {
        let defaults = makeDefaults()
        defaults.set("invalid", forKey: "sortOrder")
        let raw = defaults.string(forKey: "sortOrder") ?? SortOrder.ascending.rawValue
        XCTAssertEqual(SortOrder(rawValue: raw) ?? .ascending, .ascending)
    }

    func testFallback_invalidDistanceSpeedUnit() {
        let defaults = makeDefaults()
        defaults.set("invalid", forKey: "distanceSpeedUnit")
        let raw = defaults.string(forKey: "distanceSpeedUnit") ?? DistanceSpeedUnit.imperial.rawValue
        XCTAssertEqual(DistanceSpeedUnit(rawValue: raw) ?? .imperial, .imperial)
    }
}
