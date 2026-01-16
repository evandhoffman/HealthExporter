import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    @State private var testDataMessage = ""
    
    let healthManager = HealthKitManager()
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Units")) {
                        Picker("Temperature", selection: $settings.temperatureUnit) {
                            ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        
                        Picker("Weight", selection: $settings.weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        
                        Picker("Distance/Speed", selection: $settings.distanceSpeedUnit) {
                            ForEach(DistanceSpeedUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                    }
                    
                    #if targetEnvironment(simulator)
                    Section(header: Text("Testing")) {
                        Button(action: generateTestData) {
                            Text("Generate Test Data")
                                .foregroundColor(.blue)
                        }
                        
                        if !testDataMessage.isEmpty {
                            Text(testDataMessage)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    #endif
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    #if targetEnvironment(simulator)
    private func generateTestData() {
        healthManager.generateTestData { success, error in
            if success {
                testDataMessage = "✓ Test data generated (30 days)"
            } else {
                testDataMessage = "✗ Failed to generate test data"
            }
        }
    }
    #endif
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settings: SettingsManager())
    }
}
