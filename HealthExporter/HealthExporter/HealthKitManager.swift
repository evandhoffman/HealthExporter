import HealthKit
import os

/// Pure helpers extracted from HealthKitManager for testability.
enum HealthKitQueryHelpers {

    /// The set of HealthKit types to request read access for.
    static func readTypes(includeA1C: Bool) -> Set<HKObjectType> {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!

        var types: Set<HKObjectType> = [weightType, stepsType, glucoseType]

        if includeA1C,
           let clinicalType = HKObjectType.clinicalType(forIdentifier: .labResultRecord) {
            types.insert(clinicalType)
        }

        return types
    }

    /// Builds an inclusive start-of-day to end-of-day+1 date range, suitable for
    /// `HKQuery.predicateForSamples`. Returns nil if the calendar math fails.
    static func dayAlignedRange(
        from dateRange: (startDate: Date, endDate: Date),
        calendar: Calendar = .current
    ) -> (start: Date, end: Date)? {
        let startOfDay = calendar.startOfDay(for: dateRange.startDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dateRange.endDate)) else {
            return nil
        }
        return (startOfDay, endOfDay)
    }

    /// Filters A1C samples by date range (start-of-day inclusive, end-of-day+1 exclusive).
    static func filterA1CSamplesByDateRange(
        _ samples: [A1CSample],
        dateRange: (startDate: Date, endDate: Date),
        calendar: Calendar = .current
    ) -> [A1CSample] {
        guard let aligned = dayAlignedRange(from: dateRange, calendar: calendar) else {
            return []
        }
        return samples.filter { $0.effectiveDateTime >= aligned.start && $0.effectiveDateTime < aligned.end }
    }

    /// Generates a contiguous set of daily weight samples for simulator testing.
    static func generateWeightTestSamples(
        days: Int = 60,
        referenceDate: Date = Date(),
        calendar: Calendar = .current,
        valueGenerator: (Int) -> Double = { _ in Double.random(in: 80.0...95.0) }
    ) -> [HKQuantitySample] {
        guard days > 0 else { return [] }

        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let unit = HKUnit.gramUnit(with: .kilo)

        return (0..<days).compactMap { index in
            let offset = (days - 1) - index
            guard let date = calendar.date(byAdding: .day, value: -offset, to: referenceDate) else {
                return nil
            }

            let value = valueGenerator(index)
            return HKQuantitySample(
                type: weightType,
                quantity: HKQuantity(unit: unit, doubleValue: value),
                start: date,
                end: date
            )
        }
    }
}

class HealthKitManager {
    let healthStore = HKHealthStore()
    private static let logger = Logger(subsystem: "com.HealthExporter", category: "HealthKit")
    
    func requestAuthorization(includeA1C: Bool = false, completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"]))
            return
        }

        let typesToRead = HealthKitQueryHelpers.readTypes(includeA1C: includeA1C)

        healthStore.requestAuthorization(toShare: Set(), read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func fetchWeightData(dateRange: (startDate: Date, endDate: Date)? = nil, limit: Int = HKObjectQueryNoLimit, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!

        var predicate: NSPredicate? = nil
        if let dateRange = dateRange {
            guard let aligned = HealthKitQueryHelpers.dayAlignedRange(from: dateRange) else {
                completion(nil, nil)
                return
            }
            predicate = HKQuery.predicateForSamples(withStart: aligned.start, end: aligned.end, options: .strictStartDate)
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            completion(samples as? [HKQuantitySample], error)
        }
        healthStore.execute(query)
    }

    func fetchStepsData(dateRange: (startDate: Date, endDate: Date)? = nil, limit: Int = HKObjectQueryNoLimit, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        var predicate: NSPredicate? = nil
        if let dateRange = dateRange {
            guard let aligned = HealthKitQueryHelpers.dayAlignedRange(from: dateRange) else {
                completion(nil, nil)
                return
            }
            predicate = HKQuery.predicateForSamples(withStart: aligned.start, end: aligned.end, options: .strictStartDate)
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            completion(samples as? [HKQuantitySample], error)
        }
        healthStore.execute(query)
    }

    func fetchBloodGlucoseDataTyped(dateRange: (startDate: Date, endDate: Date)? = nil, limit: Int = HKObjectQueryNoLimit, completion: @escaping ([GlucoseSampleMgDl]?, Error?) -> Void) {
        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!

        var predicate: NSPredicate? = nil
        if let dateRange = dateRange {
            guard let aligned = HealthKitQueryHelpers.dayAlignedRange(from: dateRange) else {
                completion(nil, nil)
                return
            }
            predicate = HKQuery.predicateForSamples(withStart: aligned.start, end: aligned.end, options: .strictStartDate)
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: glucoseType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            let rawSamples = samples as? [HKQuantitySample]
            Self.logger.debug("Glucose fetch returned \(rawSamples?.count ?? 0) raw samples")
            let glucoseSamples = rawSamples?.compactMap { GlucoseSampleMgDl(from: $0) }
            Self.logger.debug("Glucose samples after filtering: \(glucoseSamples?.count ?? 0)")
            completion(glucoseSamples, error)
        }
        healthStore.execute(query)
    }
    
    func fetchA1CData(dateRange: (startDate: Date, endDate: Date)? = nil, limit: Int = HKObjectQueryNoLimit, completion: @escaping ([A1CSample]?, Error?) -> Void) {
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
        let query = HKSampleQuery(sampleType: clinicalType, predicate: nil, limit: limit, sortDescriptors: [sortDescriptor]) { _, records, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            var a1cSamples = (records as? [HKClinicalRecord])?.compactMap { A1CSample(from: $0) } ?? []

            // Apply date range filtering if provided
            if let dateRange = dateRange {
                a1cSamples = HealthKitQueryHelpers.filterA1CSamplesByDateRange(a1cSamples, dateRange: dateRange)
            }
            
            completion(a1cSamples, nil)
        }
        healthStore.execute(query)
    }
    
    #if targetEnvironment(simulator)
    func generateTestData(completion: @escaping (Bool, Error?) -> Void) {
        let samples = HealthKitQueryHelpers.generateWeightTestSamples(days: 60)

        healthStore.save(samples) { success, error in
            completion(success, error)
        }
    }
    #endif
}
