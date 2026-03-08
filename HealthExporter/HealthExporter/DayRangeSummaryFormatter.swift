import Foundation

struct DayRangeSummaryFormatter {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()

    static func summaryText(forDays days: Int, relativeTo referenceDate: Date, calendar: Calendar = .current) -> String {
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: referenceDate) else {
            return ""
        }

        return "\(dateFormatter.string(from: startDate)) to today"
    }
}
