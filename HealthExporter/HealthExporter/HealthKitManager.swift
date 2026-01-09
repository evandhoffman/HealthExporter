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
        let typesToRead: Set<HKObjectType> = [weightType, stepsType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
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
}