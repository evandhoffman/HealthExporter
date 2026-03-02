import HealthKit

class CSVGenerator {

    static let csvHeader = "Date,Metric,Value,Unit,Source"

    private static func makeDateFormatter(for option: DateFormatOption) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = option.dateFormat
        if option.isUTC {
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return formatter
    }

    /// Wraps a value in double quotes if it contains commas or quotes (RFC 4180).
    private static func csvEscape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    // MARK: - Append methods (memory-efficient, sort in-place, write directly to string)

    static func appendWeightRows(to csv: inout String, samples: inout [HKQuantitySample], unit: WeightUnit, dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) {
        let dateFormatter = makeDateFormatter(for: dateFormat)
        samples.sort { sortOrder == .ascending ? $0.startDate < $1.startDate : $0.startDate > $1.startDate }
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let (value, unitString) = convertWeight(weightKg, to: unit)
            let source = csvEscape(sample.sourceRevision.source.name)
            csv.append("\(date),Weight,\(String(format: "%.2f", value)),\(unitString),\(source)\n")
        }
    }

    static func appendStepsRows(to csv: inout String, samples: inout [HKQuantitySample], dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) {
        let dateFormatter = makeDateFormatter(for: dateFormat)
        samples.sort { sortOrder == .ascending ? $0.startDate < $1.startDate : $0.startDate > $1.startDate }
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            let source = csvEscape(sample.sourceRevision.source.name)
            csv.append("\(date),Steps,\(Int(steps)),steps,\(source)\n")
        }
    }

    static func appendGlucoseRows(to csv: inout String, samples: inout [GlucoseSampleMgDl], dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) {
        let dateFormatter = makeDateFormatter(for: dateFormat)
        samples.sort { sortOrder == .ascending ? $0.startDate < $1.startDate : $0.startDate > $1.startDate }
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let source = csvEscape(sample.source)
            csv.append("\(date),Blood Glucose,\(String(format: "%.0f", sample.value)),mg/dL,\(source)\n")
        }
    }

    static func appendA1CRows(to csv: inout String, samples: inout [A1CSample], dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) {
        let dateFormatter = makeDateFormatter(for: dateFormat)
        samples.sort { sortOrder == .ascending ? $0.effectiveDateTime < $1.effectiveDateTime : $0.effectiveDateTime > $1.effectiveDateTime }
        for sample in samples {
            let date = dateFormatter.string(from: sample.effectiveDateTime)
            let source = csvEscape(sample.source)
            csv.append("\(date),Hemoglobin A1C,\(String(format: "%.2f", sample.value)),\(sample.unit),\(source)\n")
        }
    }

    // MARK: - Legacy convenience methods (used by tests and single-metric exports)

    static func generateWeightCSV(from samples: [HKQuantitySample], unit: WeightUnit, dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) -> String {
        var csv = csvHeader + "\n"
        var mutableSamples = samples
        appendWeightRows(to: &csv, samples: &mutableSamples, unit: unit, dateFormat: dateFormat, sortOrder: sortOrder)
        return csv
    }

    static func generateStepsCSV(from samples: [HKQuantitySample], dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) -> String {
        var csv = csvHeader + "\n"
        var mutableSamples = samples
        appendStepsRows(to: &csv, samples: &mutableSamples, dateFormat: dateFormat, sortOrder: sortOrder)
        return csv
    }

    static func generateCombinedCSV(weightSamples: [HKQuantitySample]?, stepsSamples: [HKQuantitySample]?, glucoseSamples: [GlucoseSampleMgDl]?, a1cSamples: [A1CSample]?, weightUnit: WeightUnit, dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) -> String {
        var csv = csvHeader + "\n"

        if var samples = weightSamples {
            appendWeightRows(to: &csv, samples: &samples, unit: weightUnit, dateFormat: dateFormat, sortOrder: sortOrder)
        }

        if var samples = stepsSamples {
            appendStepsRows(to: &csv, samples: &samples, dateFormat: dateFormat, sortOrder: sortOrder)
        }

        if var samples = glucoseSamples {
            appendGlucoseRows(to: &csv, samples: &samples, dateFormat: dateFormat, sortOrder: sortOrder)
        }

        if var samples = a1cSamples {
            appendA1CRows(to: &csv, samples: &samples, dateFormat: dateFormat, sortOrder: sortOrder)
        }

        return csv
    }

    private static func convertWeight(_ weightKg: Double, to unit: WeightUnit) -> (Double, String) {
        switch unit {
        case .kilograms:
            return (weightKg, "kg")
        case .pounds:
            let weightLbs = weightKg * 2.2046226218
            return (weightLbs, "lbs")
        }
    }
}
