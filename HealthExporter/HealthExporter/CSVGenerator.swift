import HealthKit

class CSVGenerator {
    static func generateWeightCSV(from samples: [HKQuantitySample]) -> String {
        var csv = "Date,Metric,Value,Unit\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            csv += "\(date),Weight,\(weight),kg\n"
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
    
    static func generateCombinedCSV(weightSamples: [HKQuantitySample]?, stepsSamples: [HKQuantitySample]?) -> String {
        var csv = "Date,Metric,Value,Unit\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        if let weightSamples = weightSamples {
            for sample in weightSamples {
                let date = dateFormatter.string(from: sample.startDate)
                let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                csv += "\(date),Weight,\(weight),kg\n"
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
}