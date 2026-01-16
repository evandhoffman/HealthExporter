import Foundation

/// Configuration for health metrics including availability requirements
struct HealthMetricConfig {
    let name: String
    let requiresPaidAccount: Bool
    
    /// Returns true if this metric is available based on current account status
    var isAvailable: Bool {
        !requiresPaidAccount || BuildConfig.hasPaidDeveloperAccount
    }
}

/// Centralized configuration for all health metrics
enum HealthMetrics {
    static let weight = HealthMetricConfig(
        name: "Weight",
        requiresPaidAccount: false
    )
    
    static let steps = HealthMetricConfig(
        name: "Steps",
        requiresPaidAccount: false
    )
    
    static let glucose = HealthMetricConfig(
        name: "Blood Glucose",
        requiresPaidAccount: false
    )
    
    static let a1c = HealthMetricConfig(
        name: "Hemoglobin A1C",
        requiresPaidAccount: true
    )
}
