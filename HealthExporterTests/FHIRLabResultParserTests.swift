import XCTest
@testable import HealthExporter

final class FHIRLabResultParserTests: XCTestCase {

    // MARK: - Helpers

    private func makeFHIRJSON(
        loincCode: String = "4548-4",
        system: String = "http://loinc.org",
        effectiveDateTime: String = "2024-06-15T10:30:00Z",
        value: Any = 7.2,
        unit: String = "%"
    ) -> Data {
        let json: [String: Any] = [
            "resourceType": "Observation",
            "code": [
                "coding": [
                    ["system": system, "code": loincCode, "display": "Hemoglobin A1c"]
                ]
            ],
            "effectiveDateTime": effectiveDateTime,
            "valueQuantity": [
                "value": value,
                "unit": unit
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func makeFHIRJSONWithout(_ keyToOmit: String) -> Data {
        var json: [String: Any] = [
            "resourceType": "Observation",
            "code": [
                "coding": [
                    ["system": "http://loinc.org", "code": "4548-4", "display": "Hemoglobin A1c"]
                ]
            ],
            "effectiveDateTime": "2024-06-15T10:30:00Z",
            "valueQuantity": [
                "value": 7.2,
                "unit": "%"
            ]
        ]
        json.removeValue(forKey: keyToOmit)
        return try! JSONSerialization.data(withJSONObject: json)
    }

    // MARK: - Matching LOINC code

    func testMatchingLOINCCode_returnsResult() {
        let data = makeFHIRJSON(loincCode: "4548-4")
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")

        XCTAssertNotNil(result)
        XCTAssertEqual(result!.value, 7.2, accuracy: 0.001)
        XCTAssertEqual(result?.unit, "%")
    }

    func testMatchingLOINCCode_parsesDateCorrectly() {
        let data = makeFHIRJSON(effectiveDateTime: "2024-06-15T10:30:00Z")
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")

        XCTAssertNotNil(result)
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: result!.effectiveDateTime)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 10)
        XCTAssertEqual(components.minute, 30)
    }

    // MARK: - Non-matching LOINC code

    func testNonMatchingLOINCCode_returnsNil() {
        let data = makeFHIRJSON(loincCode: "4548-4")
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "2093-3")
        XCTAssertNil(result)
    }

    func testWrongSystem_returnsNil() {
        let data = makeFHIRJSON(system: "http://snomed.org")
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    // MARK: - Invalid/missing JSON

    func testInvalidJSON_returnsNil() {
        let data = "not json".data(using: .utf8)!
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    func testEmptyData_returnsNil() {
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: Data(), loincCode: "4548-4")
        XCTAssertNil(result)
    }

    func testEmptyJSONObject_returnsNil() {
        let data = try! JSONSerialization.data(withJSONObject: [:] as [String: Any])
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    // MARK: - Missing required fields

    func testMissingCodeField_returnsNil() {
        let data = makeFHIRJSONWithout("code")
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    func testMissingEffectiveDateTime_returnsNil() {
        let data = makeFHIRJSONWithout("effectiveDateTime")
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    func testMissingValueQuantity_returnsNil() {
        let data = makeFHIRJSONWithout("valueQuantity")
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    // MARK: - Invalid field values

    func testInvalidDateTimeFormat_returnsNil() {
        let data = makeFHIRJSON(effectiveDateTime: "June 15, 2024")
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    func testMissingValueInValueQuantity_returnsNil() {
        let json: [String: Any] = [
            "resourceType": "Observation",
            "code": ["coding": [["system": "http://loinc.org", "code": "4548-4"]]],
            "effectiveDateTime": "2024-06-15T10:30:00Z",
            "valueQuantity": ["unit": "%"]  // missing "value"
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    func testMissingUnitInValueQuantity_returnsNil() {
        let json: [String: Any] = [
            "resourceType": "Observation",
            "code": ["coding": [["system": "http://loinc.org", "code": "4548-4"]]],
            "effectiveDateTime": "2024-06-15T10:30:00Z",
            "valueQuantity": ["value": 7.2]  // missing "unit"
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    // MARK: - Empty coding array

    func testEmptyCodingArray_returnsNil() {
        let json: [String: Any] = [
            "resourceType": "Observation",
            "code": ["coding": []],
            "effectiveDateTime": "2024-06-15T10:30:00Z",
            "valueQuantity": ["value": 7.2, "unit": "%"]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")
        XCTAssertNil(result)
    }

    // MARK: - Multiple codings (one matching)

    func testMultipleCodings_oneMatchingLOINC_returnsResult() {
        let json: [String: Any] = [
            "resourceType": "Observation",
            "code": [
                "coding": [
                    ["system": "http://snomed.org", "code": "12345"],
                    ["system": "http://loinc.org", "code": "4548-4", "display": "Hemoglobin A1c"]
                ]
            ],
            "effectiveDateTime": "2024-06-15T10:30:00Z",
            "valueQuantity": ["value": 6.8, "unit": "%"]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let result = FHIRLabResultParser.extractLabResult(fromFHIRData: data, loincCode: "4548-4")

        XCTAssertNotNil(result)
        XCTAssertEqual(result!.value, 6.8, accuracy: 0.001)
    }
}
