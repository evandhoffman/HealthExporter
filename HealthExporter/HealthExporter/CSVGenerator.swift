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
    
    static func generateWeightCSV(from samples: [HKQuantitySample], unit: WeightUnit) -> String {
        var csv = "Date,ISO8601,Metric,Value,Unit\n"
        
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let iso8601 = iso8601Formatter.string(from: sample.startDate)
            let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let (value, unitString) = convertWeight(weightKg, to: unit)
            csv += "\(date),\(iso8601),Weight,\(String(format: "%.2f", value)),\(unitString)\n"
        }
        return csv
    }
    
    static func generateStepsCSV(from samples: [HKQuantitySample]) -> String {
        var csv = "Date,ISO8601,Metric,Value,Unit\n"
        
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let iso8601 = iso8601Formatter.string(from: sample.startDate)
            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            csv += "\(date),\(iso8601),Steps,\(Int(steps)),steps\n"
        }
        return csv
    }
    
    static func generateCombinedCSV(weightSamples: [HKQuantitySample]?, stepsSamples: [HKQuantitySample]?, glucoseSamples: [GlucoseSampleMgDl]?, weightUnit: WeightUnit) -> String {
        var lines: [String] = ["Date,ISO8601,Metric,Value,Unit"]
        
        if let weightSamples = weightSamples {
            lines.reserveCapacity(lines.capacity + weightSamples.count)
            for sample in weightSamples {
                let date = dateFormatter.string(from: sample.startDate)
                let iso8601 = iso8601Formatter.string(from: sample.startDate)
                let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                let (value, unitString) = convertWeight(weightKg, to: weightUnit)
                lines.append("\(date),\(iso8601),Weight,\(String(format: "%.2f", value)),\(unitString)")
            }
        }
        
        if let stepsSamples = stepsSamples {
            lines.reserveCapacity(lines.capacity + stepsSamples.count)
            for sample in stepsSamples {
                let date = dateFormatter.string(from: sample.startDate)
                let iso8601 = iso8601Formatter.string(from: sample.startDate)
                let steps = sample.quantity.doubleValue(for: HKUnit.count())
                lines.append("\(date),\(iso8601),Steps,\(Int(steps)),steps")
            }
        }

        if let glucoseSamples = glucoseSamples {
            lines.reserveCapacity(lines.capacity + glucoseSamples.count)
            for sample in glucoseSamples {
                let date = dateFormatter.string(from: sample.startDate)
                let iso8601 = iso8601Formatter.string(from: sample.startDate)
                lines.append("\(date),\(iso8601),Blood Glucose,\(String(format: "%.0f", sample.value)),mg/dL")
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