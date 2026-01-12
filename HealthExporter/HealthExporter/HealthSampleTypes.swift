import HealthKit

// MARK: - A1C Sample Type
struct A1CSamplePct {
    let startDate: Date
    let value: Double // Percentage value (e.g., 6.8 for 6.8%)
    
    init?(from sample: HKQuantitySample) {
        // Only accept samples that are compatible with percent unit
        guard sample.quantity.is(compatibleWith: HKUnit.percent()) else {
            return nil
        }
        self.startDate = sample.startDate
        self.value = sample.quantity.doubleValue(for: HKUnit.percent())
    }
}

// MARK: - Glucose Sample Type
struct GlucoseSampleMgDl {
    let startDate: Date
    let value: Double // mg/dL value (e.g., 145.0 for 145 mg/dL)
    
    init?(from sample: HKQuantitySample) {
        let glucoseUnit = HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
        // Only accept samples that are compatible with mg/dL unit
        guard sample.quantity.is(compatibleWith: glucoseUnit) else {
            return nil
        }
        self.startDate = sample.startDate
        self.value = sample.quantity.doubleValue(for: glucoseUnit)
    }
}
