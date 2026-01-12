import HealthKit

// MARK: - Glucose Sample Type
struct GlucoseSampleMgDl {
    let startDate: Date
    let value: Double // mg/dL value (e.g., 145.0 for 145 mg/dL)
    
    init?(from sample: HKQuantitySample) {
        let glucoseUnit = HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
        let mgDlValue = sample.quantity.doubleValue(for: glucoseUnit)
        // Blood glucose values are typically 20-600 mg/dL, reject values < 20 (likely % misinterpreted)
        guard mgDlValue >= 20 else {
            return nil
        }
        self.startDate = sample.startDate
        self.value = mgDlValue
    }
}
