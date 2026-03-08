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
