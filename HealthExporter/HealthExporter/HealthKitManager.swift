import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"]))
            return
        }
        
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        
        // Clinical Records for Hemoglobin A1C (HKClinicalTypeIdentifierLabResultRecord)
        // NOTE: Requires 'NSHealthClinicalHealthRecordsShareUsageDescription' in Info.plist
        // and 'Clinical Health Records' capability enabled in Xcode signing & capabilities
        var typesToRead: Set<HKObjectType> = [weightType, stepsType, glucoseType]
        if #available(iOS 15.0, *) {
            if let clinicalType = HKObjectType.clinicalType(forIdentifier: .labResultRecord) {
                typesToRead.insert(clinicalType)
            }
        }
        
        let typesToWrite: Set<HKSampleType> = [weightType, stepsType, glucoseType]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func fetchWeightData(dateRange: (startDate: Date, endDate: Date)? = nil, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        
        var predicate: NSPredicate? = nil
        if let dateRange = dateRange {
            // Create predicate for date range (inclusive)
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: dateRange.startDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dateRange.endDate))!
            predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            completion(samples as? [HKQuantitySample], error)
        }
        healthStore.execute(query)
    }
    
    func fetchStepsData(dateRange: (startDate: Date, endDate: Date)? = nil, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        var predicate: NSPredicate? = nil
        if let dateRange = dateRange {
            // Create predicate for date range (inclusive)
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: dateRange.startDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dateRange.endDate))!
            predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            completion(samples as? [HKQuantitySample], error)
        }
        healthStore.execute(query)
    }
    
    func fetchBloodGlucoseData(dateRange: (startDate: Date, endDate: Date)? = nil, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        
        var predicate: NSPredicate? = nil
        if let dateRange = dateRange {
            // Create predicate for date range (inclusive)
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: dateRange.startDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dateRange.endDate))!
            predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: glucoseType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            completion(samples as? [HKQuantitySample], error)
        }
        healthStore.execute(query)
    }
    
    func fetchBloodGlucoseDataTyped(dateRange: (startDate: Date, endDate: Date)? = nil, completion: @escaping ([GlucoseSampleMgDl]?, Error?) -> Void) {
        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        
        var predicate: NSPredicate? = nil
        if let dateRange = dateRange {
            // Create predicate for date range (inclusive)
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: dateRange.startDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dateRange.endDate))!
            predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: glucoseType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            // Debug: Print raw sample data
            if let samples = samples as? [HKQuantitySample] {
                print("=== Glucose Fetch - Total samples: \(samples.count) ===")
                for (index, sample) in samples.prefix(5).enumerated() {
                    print("Sample \(index):")
                    print("  Date: \(sample.startDate)")
                    print("  Quantity: \(sample.quantity)")
                    print("  Type: \(sample.quantityType)")
                    
                    // Try both units
                    let percentUnit = HKUnit.percent()
                    let mgDlUnit = HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
                    
                    if sample.quantity.is(compatibleWith: percentUnit) {
                        let percentValue = sample.quantity.doubleValue(for: percentUnit)
                        print("  As percent: \(percentValue)%")
                    }
                    
                    if sample.quantity.is(compatibleWith: mgDlUnit) {
                        let mgDlValue = sample.quantity.doubleValue(for: mgDlUnit)
                        print("  As mg/dL: \(mgDlValue)")
                    }
                }
            }
            
            let glucoseSamples = (samples as? [HKQuantitySample])?.compactMap { GlucoseSampleMgDl(from: $0) }
            print("Glucose samples after filtering: \(glucoseSamples?.count ?? 0)")
            completion(glucoseSamples, error)
        }
        healthStore.execute(query)
    }
    
    func fetchA1CData(dateRange: (startDate: Date, endDate: Date)? = nil, completion: @escaping ([A1CSample]?, Error?) -> Void) {
        // Requires iOS 15.0+ for clinical records
        guard #available(iOS 15.0, *) else {
            completion(nil, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Clinical Records require iOS 15.0 or later"]))
            return
        }
        
        guard let clinicalType = HKObjectType.clinicalType(forIdentifier: .labResultRecord) else {
            completion(nil, NSError(domain: "HealthKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "Clinical Lab Result type not available"]))
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: clinicalType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, records, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            let a1cSamples = (records as? [HKClinicalRecord])?.compactMap { record -> A1CSample? in
                let sample = A1CSample(from: record)
                
                // Apply date range filtering if provided
                if let dateRange = dateRange, let sample = sample {
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: dateRange.startDate)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dateRange.endDate))!
                    if sample.effectiveDateTime >= startOfDay && sample.effectiveDateTime < endOfDay {
                        return sample
                    }
                    return nil
                }
                
                return sample
            } ?? []
            
            completion(a1cSamples, nil)
        }
        healthStore.execute(query)
    }
    
    #if targetEnvironment(simulator)
    func generateTestData(completion: @escaping (Bool, Error?) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        
        var samples: [HKSample] = []
        let calendar = Calendar.current
        
        // Generate 30 days of test data
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            
            // Weight sample (80-95 kg)
            let weightValue = Double.random(in: 80.0...95.0)
            let weightSample = HKQuantitySample(
                type: weightType,
                quantity: HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weightValue),
                start: date,
                end: date
            )
            samples.append(weightSample)
            
            // Steps sample (3000-12000 steps)
            let stepsValue = Double.random(in: 3000.0...12000.0)
            let stepsSample = HKQuantitySample(
                type: stepsType,
                quantity: HKQuantity(unit: HKUnit.count(), doubleValue: stepsValue),
                start: date,
                end: date
            )
            samples.append(stepsSample)
        }
        
        // Generate glucose test data
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            
            // Blood glucose sample (70-180 mg/dL)
            let glucoseValue = Double.random(in: 70.0...180.0)
            let glucoseUnit = HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
            let metadata: [String: Any] = [HKMetadataKeyWasUserEntered: false]
            let glucoseSample = HKQuantitySample(
                type: glucoseType,
                quantity: HKQuantity(unit: glucoseUnit, doubleValue: glucoseValue),
                start: date,
                end: date,
                metadata: metadata
            )
            samples.append(glucoseSample)
        }
        
        healthStore.save(samples) { success, error in
            completion(success, error)
        }
    }
    #endif
}