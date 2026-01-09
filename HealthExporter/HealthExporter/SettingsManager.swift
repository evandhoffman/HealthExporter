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
    @Published var temperatureUnit: TemperatureUnit {
        didSet {
            UserDefaults.standard.set(temperatureUnit.rawValue, forKey: "temperatureUnit")
        }
    }
    
    @Published var weightUnit: WeightUnit {
        didSet {
            UserDefaults.standard.set(weightUnit.rawValue, forKey: "weightUnit")
        }
    }
    
    @Published var distanceSpeedUnit: DistanceSpeedUnit {
        didSet {
            UserDefaults.standard.set(distanceSpeedUnit.rawValue, forKey: "distanceSpeedUnit")
        }
    }
    
    init() {
        let tempUnitRaw = UserDefaults.standard.string(forKey: "temperatureUnit") ?? TemperatureUnit.celsius.rawValue
        self.temperatureUnit = TemperatureUnit(rawValue: tempUnitRaw) ?? .celsius
        
        let weightUnitRaw = UserDefaults.standard.string(forKey: "weightUnit") ?? WeightUnit.kilograms.rawValue
        self.weightUnit = WeightUnit(rawValue: weightUnitRaw) ?? .kilograms
        
        let distanceSpeedUnitRaw = UserDefaults.standard.string(forKey: "distanceSpeedUnit") ?? DistanceSpeedUnit.metric.rawValue
        self.distanceSpeedUnit = DistanceSpeedUnit(rawValue: distanceSpeedUnitRaw) ?? .metric
    }
}
