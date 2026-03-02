import HealthKit

class CSVGenerator {

    private static let csvHeader = "Date,Metric,Value,Unit,Source"

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

    static func generateWeightCSV(from samples: [HKQuantitySample], unit: WeightUnit, dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) -> String {
        let dateFormatter = makeDateFormatter(for: dateFormat)
        let sorted = samples.sorted { sortOrder == .ascending ? $0.startDate < $1.startDate : $0.startDate > $1.startDate }
        var lines: [String] = [csvHeader]
        lines.reserveCapacity(sorted.count + 1)
        for sample in sorted {
            let date = dateFormatter.string(from: sample.startDate)
            let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let (value, unitString) = convertWeight(weightKg, to: unit)
            let source = csvEscape(sample.sourceRevision.source.name)
            lines.append("\(date),Weight,\(String(format: "%.2f", value)),\(unitString),\(source)")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    static func generateStepsCSV(from samples: [HKQuantitySample], dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) -> String {
        let dateFormatter = makeDateFormatter(for: dateFormat)
        let sorted = samples.sorted { sortOrder == .ascending ? $0.startDate < $1.startDate : $0.startDate > $1.startDate }
        var lines: [String] = [csvHeader]
        lines.reserveCapacity(sorted.count + 1)
        for sample in sorted {
            let date = dateFormatter.string(from: sample.startDate)
            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            let source = csvEscape(sample.sourceRevision.source.name)
            lines.append("\(date),Steps,\(Int(steps)),steps,\(source)")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    static func generateCombinedCSV(weightSamples: [HKQuantitySample]?, stepsSamples: [HKQuantitySample]?, glucoseSamples: [GlucoseSampleMgDl]?, a1cSamples: [A1CSample]?, weightUnit: WeightUnit, dateFormat: DateFormatOption = .yyyyMMddHHmmss, sortOrder: SortOrder = .ascending) -> String {
        let dateFormatter = makeDateFormatter(for: dateFormat)
        let ascending = sortOrder == .ascending
        var lines: [String] = [csvHeader]

        if let weightSamples = weightSamples {
            let sorted = weightSamples.sorted { ascending ? $0.startDate < $1.startDate : $0.startDate > $1.startDate }
            lines.reserveCapacity(lines.capacity + sorted.count)
            for sample in sorted {
                let date = dateFormatter.string(from: sample.startDate)
                let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                let (value, unitString) = convertWeight(weightKg, to: weightUnit)
                let source = csvEscape(sample.sourceRevision.source.name)
                lines.append("\(date),Weight,\(String(format: "%.2f", value)),\(unitString),\(source)")
            }
        }

        if let stepsSamples = stepsSamples {
            let sorted = stepsSamples.sorted { ascending ? $0.startDate < $1.startDate : $0.startDate > $1.startDate }
            lines.reserveCapacity(lines.capacity + sorted.count)
            for sample in sorted {
                let date = dateFormatter.string(from: sample.startDate)
                let steps = sample.quantity.doubleValue(for: HKUnit.count())
                let source = csvEscape(sample.sourceRevision.source.name)
                lines.append("\(date),Steps,\(Int(steps)),steps,\(source)")
            }
        }

        if let glucoseSamples = glucoseSamples {
            let sorted = glucoseSamples.sorted { ascending ? $0.startDate < $1.startDate : $0.startDate > $1.startDate }
            lines.reserveCapacity(lines.capacity + sorted.count)
            for sample in sorted {
                let date = dateFormatter.string(from: sample.startDate)
                let source = csvEscape(sample.source)
                lines.append("\(date),Blood Glucose,\(String(format: "%.0f", sample.value)),mg/dL,\(source)")
            }
        }

        if let a1cSamples = a1cSamples {
            let sorted = a1cSamples.sorted { ascending ? $0.effectiveDateTime < $1.effectiveDateTime : $0.effectiveDateTime > $1.effectiveDateTime }
            lines.reserveCapacity(lines.capacity + sorted.count)
            for sample in sorted {
                let date = dateFormatter.string(from: sample.effectiveDateTime)
                let source = csvEscape(sample.source)
                lines.append("\(date),Hemoglobin A1C,\(String(format: "%.2f", sample.value)),\(sample.unit),\(source)")
            }
        }

        return lines.joined(separator: "\n") + "\n"
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
