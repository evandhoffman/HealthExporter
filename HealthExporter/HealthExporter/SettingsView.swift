import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settings: SettingsManager())
    }
}
