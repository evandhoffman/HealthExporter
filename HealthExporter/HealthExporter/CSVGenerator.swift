import HealthKit

class CSVGenerator {
    static func generateWeightCSV(from samples: [HKQuantitySample], unit: WeightUnit) -> String {
        var csv = "Date,Metric,Value,Unit\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let (value, unitString) = convertWeight(weightKg, to: unit)
            csv += "\(date),Weight,\(String(format: "%.2f", value)),\(unitString)\n"
        }
        return csv
    }
    
    static func generateStepsCSV(from samples: [HKQuantitySample]) -> String {
        var csv = "Date,Metric,Value,Unit\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let steps = sample.quantity.doubleValue(for: HKUnit.count())
            csv += "\(date),Steps,\(Int(steps)),steps\n"
        }
        return csv
    }
    
    static func generateCombinedCSV(weightSamples: [HKQuantitySample]?, stepsSamples: [HKQuantitySample]?, weightUnit: WeightUnit) -> String {
        var csv = "Date,Metric,Value,Unit\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        if let weightSamples = weightSamples {
            for sample in weightSamples {
                let date = dateFormatter.string(from: sample.startDate)
                let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                let (value, unitString) = convertWeight(weightKg, to: weightUnit)
                csv += "\(date),Weight,\(String(format: "%.2f", value)),\(unitString)\n"
            }
        }
        
        if let stepsSamples = stepsSamples {
            for sample in stepsSamples {
                let date = dateFormatter.string(from: sample.startDate)
                let steps = sample.quantity.doubleValue(for: HKUnit.count())
                csv += "\(date),Steps,\(Int(steps)),steps\n"
            }
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