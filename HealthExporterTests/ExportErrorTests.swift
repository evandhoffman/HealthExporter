import XCTest
@testable import HealthExporter

final class ExportErrorTests: XCTestCase {

    // MARK: - healthKitAuthorizationFailed

    func testAuthorizationFailed_withoutUnderlyingError() {
        let error = ExportError.healthKitAuthorizationFailed(underlying: nil)
        XCTAssertEqual(error.errorDescription, "HealthKit authorization was denied.")
    }

    func testAuthorizationFailed_withUnderlyingError() {
        let underlying = NSError(domain: "HKErrorDomain", code: 5, userInfo: [
            NSLocalizedDescriptionKey: "Access denied"
        ])
        let error = ExportError.healthKitAuthorizationFailed(underlying: underlying)
        XCTAssertEqual(error.errorDescription, "HealthKit authorization failed: Access denied")
    }

    // MARK: - healthKitQueryFailed

    func testQueryFailed_withoutUnderlyingError() {
        let error = ExportError.healthKitQueryFailed(metric: "Hemoglobin A1C", underlying: nil)
        XCTAssertEqual(error.errorDescription, "Failed to fetch Hemoglobin A1C data.")
    }

    func testQueryFailed_withUnderlyingError() {
        let underlying = NSError(domain: "HKErrorDomain", code: 6, userInfo: [
            NSLocalizedDescriptionKey: "Unavailable"
        ])
        let error = ExportError.healthKitQueryFailed(metric: "Weight", underlying: underlying)
        XCTAssertEqual(error.errorDescription, "Failed to fetch Weight data: Unavailable")
    }

    // MARK: - noDataFound

    func testNoDataFound() {
        let error = ExportError.noDataFound
        XCTAssertEqual(error.errorDescription,
            "No data found for the selected metrics and date range.")
    }

    // MARK: - fileWriteFailed

    func testFileWriteFailed_withoutUnderlyingError() {
        let error = ExportError.fileWriteFailed(underlying: nil)
        XCTAssertEqual(error.errorDescription, "Failed to save the CSV file.")
    }

    func testFileWriteFailed_withUnderlyingError() {
        let underlying = NSError(domain: NSCocoaErrorDomain, code: 4, userInfo: [
            NSLocalizedDescriptionKey: "Disk full"
        ])
        let error = ExportError.fileWriteFailed(underlying: underlying)
        XCTAssertEqual(error.errorDescription, "Failed to save the CSV file: Disk full")
    }

    // MARK: - LocalizedError conformance

    func testConformsToLocalizedError() {
        let error: LocalizedError = ExportError.noDataFound
        XCTAssertNotNil(error.errorDescription)
    }
}
