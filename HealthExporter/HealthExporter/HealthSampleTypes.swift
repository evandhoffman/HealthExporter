import HealthKit

// MARK: - A1C Sample Type
struct A1CSamplePct {
    let startDate: Date
    let value: Double // Percentage value (e.g., 6.8 for 6.8%)
    
    init?(from sample: HKQuantitySample) {
        self.startDate = sample.startDate
        let percentValue = sample.quantity.doubleValue(for: HKUnit.percent())
        // A1C values are typically 4-15%, reject values > 20% (likely mg/dL misinterpreted)
        guard percentValue > 0 && percentValue <= 20 else {
            return nil
        }
        self.value = percentValue
    }
}

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
