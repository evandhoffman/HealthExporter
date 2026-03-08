import XCTest
@testable import HealthExporter

final class A1CSampleTests: XCTestCase {

    private var referenceDate: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: "2024-06-15T10:30:00Z")!
    }

    // MARK: - Memberwise initializer

    func testMemberwiseInit_preservesAllValues() {
        let sample = A1CSample(
            effectiveDateTime: referenceDate,
            value: 7.5,
            unit: "%",
            source: "MyClinic"
        )
        XCTAssertEqual(sample.effectiveDateTime, referenceDate)
        XCTAssertEqual(sample.value, 7.5, accuracy: 0.001)
        XCTAssertEqual(sample.unit, "%")
        XCTAssertEqual(sample.source, "MyClinic")
    }

    func testMemberwiseInit_defaultSource_isEmpty() {
        let sample = A1CSample(effectiveDateTime: referenceDate, value: 6.1, unit: "%")
        XCTAssertEqual(sample.source, "")
    }

    func testMemberwiseInit_variousValues() {
        let low = A1CSample(effectiveDateTime: referenceDate, value: 4.0, unit: "%")
        XCTAssertEqual(low.value, 4.0, accuracy: 0.001)

        let high = A1CSample(effectiveDateTime: referenceDate, value: 14.0, unit: "mmol/mol")
        XCTAssertEqual(high.value, 14.0, accuracy: 0.001)
        XCTAssertEqual(high.unit, "mmol/mol")
    }
}
