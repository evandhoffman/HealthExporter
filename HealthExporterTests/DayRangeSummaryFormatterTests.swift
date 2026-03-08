import XCTest
@testable import HealthExporter

final class DayRangeSummaryFormatterTests: XCTestCase {

    private var referenceDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 20
        components.hour = 10
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    func testSummaryText_formatsSevenDayRangeRelativeToToday() {
        let calendar = Calendar(identifier: .gregorian)

        let summary = DayRangeSummaryFormatter.summaryText(forDays: 7, relativeTo: referenceDate, calendar: calendar)

        XCTAssertEqual(summary, "March 13, 2026 to today")
    }

    func testSummaryText_formatsOneDayRange() {
        let calendar = Calendar(identifier: .gregorian)

        let summary = DayRangeSummaryFormatter.summaryText(forDays: 1, relativeTo: referenceDate, calendar: calendar)

        XCTAssertEqual(summary, "March 19, 2026 to today")
    }
}
