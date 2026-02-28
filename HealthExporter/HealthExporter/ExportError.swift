import Foundation

enum ExportError: LocalizedError {
    case healthKitNotAvailable
    case healthKitAuthorizationFailed(underlying: Error?)
    case noDataFound
    case fileWriteFailed(underlying: Error?)
    case invalidDateRange

    var errorDescription: String? {
        switch self {
        case .healthKitNotAvailable:
            return "HealthKit is not available on this device."
        case .healthKitAuthorizationFailed(let underlying):
            if let underlying = underlying {
                return "HealthKit authorization failed: \(underlying.localizedDescription)"
            }
            return "HealthKit authorization was denied."
        case .noDataFound:
            return "No data found for the selected metrics and date range."
        case .fileWriteFailed(let underlying):
            if let underlying = underlying {
                return "Failed to save the CSV file: \(underlying.localizedDescription)"
            }
            return "Failed to save the CSV file."
        case .invalidDateRange:
            return "The selected date range is invalid."
        }
    }
}
