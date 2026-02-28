import Foundation
import Combine

enum TemperatureUnit: String, CaseIterable {
    case celsius = "Celsius (°C)"
    case fahrenheit = "Fahrenheit (°F)"
}

enum WeightUnit: String, CaseIterable {
    case kilograms = "Kilograms (kg)"
    case pounds = "Pounds (lbs)"
}

enum DistanceSpeedUnit: String, CaseIterable {
    case metric = "Metric (meters/kph)"
    case imperial = "Imperial (feet/mph)"
}

class SettingsManager: ObservableObject {
    @Published var temperatureUnit: TemperatureUnit
    @Published var weightUnit: WeightUnit
    @Published var distanceSpeedUnit: DistanceSpeedUnit
    @Published var exportWeight: Bool
    @Published var exportSteps: Bool
    @Published var exportGlucose: Bool
    @Published var exportA1C: Bool

    private var cancellables = Set<AnyCancellable>()

    init() {
        let tempUnitRaw = UserDefaults.standard.string(forKey: "temperatureUnit") ?? TemperatureUnit.celsius.rawValue
        self.temperatureUnit = TemperatureUnit(rawValue: tempUnitRaw) ?? .celsius

        let weightUnitRaw = UserDefaults.standard.string(forKey: "weightUnit") ?? WeightUnit.kilograms.rawValue
        self.weightUnit = WeightUnit(rawValue: weightUnitRaw) ?? .kilograms

        let distanceSpeedUnitRaw = UserDefaults.standard.string(forKey: "distanceSpeedUnit") ?? DistanceSpeedUnit.metric.rawValue
        self.distanceSpeedUnit = DistanceSpeedUnit(rawValue: distanceSpeedUnitRaw) ?? .metric

        // Load metric preferences (default to exporting weight and steps)
        self.exportWeight = UserDefaults.standard.object(forKey: "exportWeight") as? Bool ?? true
        self.exportSteps = UserDefaults.standard.object(forKey: "exportSteps") as? Bool ?? true
        self.exportGlucose = UserDefaults.standard.object(forKey: "exportGlucose") as? Bool ?? false

        // A1C: Only enable if available AND user preference says so
        // Force to false if not available (free tier account)
        if HealthMetrics.a1c.isAvailable {
            self.exportA1C = UserDefaults.standard.object(forKey: "exportA1C") as? Bool ?? false
        } else {
            self.exportA1C = false
            UserDefaults.standard.set(false, forKey: "exportA1C")
        }

        // Persist changes via Combine subscribers (avoids @Published + didSet crash)
        $temperatureUnit
            .dropFirst()
            .sink { UserDefaults.standard.set($0.rawValue, forKey: "temperatureUnit") }
            .store(in: &cancellables)

        $weightUnit
            .dropFirst()
            .sink { UserDefaults.standard.set($0.rawValue, forKey: "weightUnit") }
            .store(in: &cancellables)

        $distanceSpeedUnit
            .dropFirst()
            .sink { UserDefaults.standard.set($0.rawValue, forKey: "distanceSpeedUnit") }
            .store(in: &cancellables)

        $exportWeight
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "exportWeight") }
            .store(in: &cancellables)

        $exportSteps
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "exportSteps") }
            .store(in: &cancellables)

        $exportGlucose
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "exportGlucose") }
            .store(in: &cancellables)

        $exportA1C
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "exportA1C") }
            .store(in: &cancellables)
    }
}
