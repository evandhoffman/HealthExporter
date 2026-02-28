import XCTest
@testable import HealthExporter

final class DateRangeOptionTests: XCTestCase {

    func testAllCasesCount() {
        XCTAssertEqual(DateRangeOption.allCases.count, 4)
    }

    func testAllCasesExist() {
        let cases = DateRangeOption.allCases
        XCTAssertTrue(cases.contains(.lastXDays))
        XCTAssertTrue(cases.contains(.lastXRecords))
        XCTAssertTrue(cases.contains(.specificDateRange))
        XCTAssertTrue(cases.contains(.allRecords))
    }

    func testRawValues() {
        XCTAssertEqual(DateRangeOption.lastXDays.rawValue, "Last X Days")
        XCTAssertEqual(DateRangeOption.lastXRecords.rawValue, "Last X Records")
        XCTAssertEqual(DateRangeOption.specificDateRange.rawValue, "Specific Date Range")
        XCTAssertEqual(DateRangeOption.allRecords.rawValue, "All Records")
    }

    func testDisplayNameMatchesRawValue() {
        for option in DateRangeOption.allCases {
            XCTAssertEqual(option.displayName, option.rawValue,
                "\(option) displayName should equal its rawValue")
        }
    }

    func testInitFromValidRawValue() {
        XCTAssertEqual(DateRangeOption(rawValue: "Last X Days"), .lastXDays)
        XCTAssertEqual(DateRangeOption(rawValue: "Last X Records"), .lastXRecords)
        XCTAssertEqual(DateRangeOption(rawValue: "Specific Date Range"), .specificDateRange)
        XCTAssertEqual(DateRangeOption(rawValue: "All Records"), .allRecords)
    }

    func testInitFromInvalidRawValue_returnsNil() {
        XCTAssertNil(DateRangeOption(rawValue: "Invalid"))
        XCTAssertNil(DateRangeOption(rawValue: ""))
        XCTAssertNil(DateRangeOption(rawValue: "last x days")) // case-sensitive
    }
}
