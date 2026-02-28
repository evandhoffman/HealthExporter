import HealthKit
import os

private let logger = Logger(subsystem: "com.HealthExporter", category: "HealthSampleTypes")

// MARK: - Glucose Sample Type
struct GlucoseSampleMgDl {
    let startDate: Date
    let value: Double // mg/dL value (e.g., 145.0 for 145 mg/dL)

    init?(from sample: HKQuantitySample) {
        let glucoseUnit = HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
        let mgDlValue = sample.quantity.doubleValue(for: glucoseUnit)
        // Blood glucose values are typically 20-600 mg/dL, reject values < 20 (likely % misinterpreted)
        guard mgDlValue >= 20 else {
            logger.debug("Filtered glucose value \(mgDlValue, privacy: .private) mg/dL (below 20 threshold) from \(sample.startDate, privacy: .private)")
            return nil
        }
        self.startDate = sample.startDate
        self.value = mgDlValue
    }
}

// MARK: - LOINC Code Constants
/// Common LOINC codes for lab results
struct LOINCCode {
    static let hemoglobinA1C = "4548-4"
    // Add future LOINC codes here:
    // static let totalCholesterol = "2093-3"
    // static let hdlCholesterol = "2085-9"
    // static let ldlCholesterol = "2089-1"
    // static let triglycerides = "2571-8"
}

// MARK: - FHIR Lab Result Helper
/// Helper struct for extracting lab result data from FHIR resources
struct FHIRLabResultParser {
    /// Extracts lab result data from a clinical record for a specific LOINC code
    /// - Parameters:
    ///   - clinicalRecord: The HKClinicalRecord containing FHIR data
    ///   - loincCode: The LOINC code to search for (e.g., "4548-4" for Hemoglobin A1C)
    /// - Returns: Tuple of (effectiveDateTime, value, unit) if found, nil otherwise
    static func extractLabResult(from clinicalRecord: HKClinicalRecord, loincCode: String) -> (effectiveDateTime: Date, value: Double, unit: String)? {
        guard let fhirResource = clinicalRecord.fhirResource else {
            return nil
        }
        
        let fhirData = fhirResource.data
        guard let jsonObject = try? JSONSerialization.jsonObject(with: fhirData, options: []),
              let json = jsonObject as? [String: Any] else {
            return nil
        }
        
        // Check if this is a lab result with the specified LOINC code
        guard let code = json["code"] as? [String: Any],
              let coding = code["coding"] as? [[String: Any]],
              coding.contains(where: { ($0["system"] as? String) == "http://loinc.org" && ($0["code"] as? String) == loincCode }) else {
            return nil
        }
        
        // Extract effective date time
        guard let effectiveDateTimeStr = json["effectiveDateTime"] as? String else {
            return nil
        }
        
        // Parse ISO 8601 datetime
        let iso8601Formatter = ISO8601DateFormatter()
        guard let effectiveDateTime = iso8601Formatter.date(from: effectiveDateTimeStr) else {
            return nil
        }
        
        // Extract value from valueQuantity
        guard let valueQuantity = json["valueQuantity"] as? [String: Any],
              let value = valueQuantity["value"] as? NSNumber,
              let unit = valueQuantity["unit"] as? String else {
            return nil
        }
        
        return (effectiveDateTime, value.doubleValue, unit)
    }
}

// MARK: - Hemoglobin A1C Sample Type
struct A1CSample {
    let effectiveDateTime: Date
    let value: Double // A1C value as percentage (e.g., 7.5 for 7.5%)
    let unit: String // Unit from FHIR (typically "%")
    
    /// Memberwise initializer for use in tests and previews.
    init(effectiveDateTime: Date, value: Double, unit: String) {
        self.effectiveDateTime = effectiveDateTime
        self.value = value
        self.unit = unit
    }

    /// Creates an A1C sample from a clinical record FHIR resource
    /// Looks for LOINC code 4548-4 (Hemoglobin A1C)
    /// Extracts effectiveDateTime, valueQuantity.value, and valueQuantity.unit
    init?(from clinicalRecord: HKClinicalRecord) {
        guard let result = FHIRLabResultParser.extractLabResult(from: clinicalRecord, loincCode: LOINCCode.hemoglobinA1C) else {
            return nil
        }
        
        self.effectiveDateTime = result.effectiveDateTime
        self.value = result.value
        self.unit = result.unit
    }
}
