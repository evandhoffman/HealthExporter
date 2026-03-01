import HealthKit

class CSVGenerator {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let csvHeader = "Date,ISO8601,Metric,Value,Unit,Source"

    /// Wraps a value in double quotes if it contains commas or quotes (RFC 4180).
    private static func csvEscape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }
    
    static func generateWeightCSV(from samples: [HKQuantitySample], unit: WeightUnit) -> String {
        let sorted = samples.sorted { $0.startDate < $1.startDate }
        var lines: [String] = [csvHeader]
        lines.reserveCapacity(sorted.count + 1)
        for sample in sorted {
            let date = dateFormatter.string(from: sample.startDate)
            let iso8601 = iso8601Formatter.string(from: sample.startDate)
            let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let (value, unitString) = convertWeight(weightKg, to: unit)
            let source = csvEscape(sample.sourceRevision.source.name)
            lines.append("\(date),\(iso8601),Weight,\(String(format: "%.2f", value)),\(unitString),\(source)")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    static func generateStepsCSV(from samples: [HKQuantitySample]) -> String {
        let sorted = samples.sorted { $0.startDate < $1.startDate }
        var lines: [String] = [csvHeader]
        lines.reserveCapacity(sorted.count + 1)
        for sample in sorted {
            let date = dateFormatter.string(from: sample.startDate)
            let iso8601 = iso8601Formatter.string(from: sample.startDate)
            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            let source = csvEscape(sample.sourceRevision.source.name)
            lines.append("\(date),\(iso8601),Steps,\(Int(steps)),steps,\(source)")
        }
        return lines.joined(separator: "\n") + "\n"
    }
    
    static func generateCombinedCSV(weightSamples: [HKQuantitySample]?, stepsSamples: [HKQuantitySample]?, glucoseSamples: [GlucoseSampleMgDl]?, a1cSamples: [A1CSample]?, weightUnit: WeightUnit) -> String {
        var lines: [String] = [csvHeader]

        if let weightSamples = weightSamples {
            let sorted = weightSamples.sorted { $0.startDate < $1.startDate }
            lines.reserveCapacity(lines.capacity + sorted.count)
            for sample in sorted {
                let date = dateFormatter.string(from: sample.startDate)
                let iso8601 = iso8601Formatter.string(from: sample.startDate)
                let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                let (value, unitString) = convertWeight(weightKg, to: weightUnit)
                let source = csvEscape(sample.sourceRevision.source.name)
                lines.append("\(date),\(iso8601),Weight,\(String(format: "%.2f", value)),\(unitString),\(source)")
            }
        }

        if let stepsSamples = stepsSamples {
            let sorted = stepsSamples.sorted { $0.startDate < $1.startDate }
            lines.reserveCapacity(lines.capacity + sorted.count)
            for sample in sorted {
                let date = dateFormatter.string(from: sample.startDate)
                let iso8601 = iso8601Formatter.string(from: sample.startDate)
                let steps = sample.quantity.doubleValue(for: HKUnit.count())
                let source = csvEscape(sample.sourceRevision.source.name)
                lines.append("\(date),\(iso8601),Steps,\(Int(steps)),steps,\(source)")
            }
        }

        if let glucoseSamples = glucoseSamples {
            let sorted = glucoseSamples.sorted { $0.startDate < $1.startDate }
            lines.reserveCapacity(lines.capacity + sorted.count)
            for sample in sorted {
                let date = dateFormatter.string(from: sample.startDate)
                let iso8601 = iso8601Formatter.string(from: sample.startDate)
                let source = csvEscape(sample.source)
                lines.append("\(date),\(iso8601),Blood Glucose,\(String(format: "%.0f", sample.value)),mg/dL,\(source)")
            }
        }

        if let a1cSamples = a1cSamples {
            let sorted = a1cSamples.sorted { $0.effectiveDateTime < $1.effectiveDateTime }
            lines.reserveCapacity(lines.capacity + sorted.count)
            for sample in sorted {
                let date = dateFormatter.string(from: sample.effectiveDateTime)
                let iso8601 = iso8601Formatter.string(from: sample.effectiveDateTime)
                let source = csvEscape(sample.source)
                lines.append("\(date),\(iso8601),Hemoglobin A1C,\(String(format: "%.2f", sample.value)),\(sample.unit),\(source)")
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