import HealthKit

class CSVGenerator {
    static func generateWeightCSV(from samples: [HKQuantitySample]) -> String {
        var csv = "Date,Weight (kg)\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        for sample in samples {
            let date = dateFormatter.string(from: sample.startDate)
            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            csv += "\(date),\(weight)\n"
        }
        return csv
    }
}