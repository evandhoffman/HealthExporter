import HealthKit

// MARK: - A1C Sample Type
struct A1CSamplePct {
    let startDate: Date
    let value: Double // Percentage value (e.g., 6.8 for 6.8%)
    
    init(from sample: HKQuantitySample) {
        self.startDate = sample.startDate
        self.value = sample.quantity.doubleValue(for: HKUnit.percent())
    }
}

// MARK: - Glucose Sample Type
struct GlucoseSampleMgDl {
    let startDate: Date
    let value: Double // mg/dL value (e.g., 145.0 for 145 mg/dL)
    
    init(from sample: HKQuantitySample) {
        self.startDate = sample.startDate
        let glucoseUnit = HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
        self.value = sample.quantity.doubleValue(for: glucoseUnit)
    }
}
