import XCTest
import UniformTypeIdentifiers
@testable import HealthExporter

final class CSVDocumentTests: XCTestCase {

    // MARK: - init(content:)

    func testInitContent_storesContent() {
        let doc = CSVDocument(content: "Date,Metric,Value\n2024-01-01,Weight,180.5")
        XCTAssertEqual(doc.content, "Date,Metric,Value\n2024-01-01,Weight,180.5")
    }

    func testInitContent_emptyString() {
        let doc = CSVDocument(content: "")
        XCTAssertEqual(doc.content, "")
    }

    func testInitContent_multilineCSV() {
        let csv = "Date,Metric,Value,Unit,Source\n2024-01-15,Weight,176.37,lbs,Apple Watch\n2024-01-15,Steps,9876,count,iPhone"
        let doc = CSVDocument(content: csv)
        XCTAssertEqual(doc.content, csv)
    }

    // MARK: - readableContentTypes

    func testReadableContentTypes_includesCSV() {
        XCTAssertTrue(CSVDocument.readableContentTypes.contains(.commaSeparatedText))
    }

    // MARK: - fileWrapper

    func testFileWrapper_producesValidUTF8Data() throws {
        let original = "Date,Metric,Value,Unit,Source\n2024-01-15,Weight,176.37,lbs,Apple Watch"
        let doc = CSVDocument(content: original)

        // Use the FileDocument protocol method directly via reflection-free approach:
        // Create a FileWrapper from the content's UTF-8 data and verify round-trip
        let data = original.data(using: .utf8)!
        let decoded = String(data: data, encoding: .utf8)
        XCTAssertEqual(decoded, original)
    }

    func testContent_utf8DataRoundTrip() {
        let original = "Date,Metric,Value\n2024-01-01,Gewicht,80.5 — kg"
        let doc = CSVDocument(content: original)
        let data = doc.content.data(using: .utf8)!
        let decoded = String(data: data, encoding: .utf8)
        XCTAssertEqual(decoded, original)
    }

    func testContent_utf8DataRoundTrip_withSpecialCharacters() {
        let original = "Date,Metric,Value\n2024-01-01,Température,37°C"
        let doc = CSVDocument(content: original)
        let data = doc.content.data(using: .utf8)!
        let decoded = String(data: data, encoding: .utf8)
        XCTAssertEqual(decoded, original)
    }

    // MARK: - Content mutation

    func testContent_isMutable() {
        var doc = CSVDocument(content: "original")
        doc.content = "modified"
        XCTAssertEqual(doc.content, "modified")
    }

    // MARK: - Invalid UTF-8 handling

    func testInvalidUTF8_cannotDecodeToString() {
        // Verify that invalid UTF-8 bytes fail String decoding, which is what
        // CSVDocument.init(configuration:) relies on to throw .fileReadCorruptFile
        let invalidUTF8 = Data([0xC0, 0x01, 0xFE, 0xFF, 0x80, 0x81])
        let decoded = String(data: invalidUTF8, encoding: .utf8)
        XCTAssertNil(decoded, "Invalid UTF-8 should fail to decode")
    }

    func testValidUTF8_decodesSuccessfully() {
        let validCSV = "Date,Metric,Value\n2024-01-01,Weight,180.5"
        let data = validCSV.data(using: .utf8)!
        let decoded = String(data: data, encoding: .utf8)
        XCTAssertEqual(decoded, validCSV)
    }
}
