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
                    Section(header: Text("Export Format")) {
                        Picker("Date Format", selection: $settings.dateFormat) {
                            ForEach(DateFormatOption.allCases, id: \.self) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                        .accessibilityIdentifier("dateFormatPicker")
                        Picker("Sort Order", selection: $settings.sortOrder) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                        .accessibilityIdentifier("sortOrderPicker")
                    }

                    Section(header: Text("Units")) {
                        Picker("Temperature", selection: $settings.temperatureUnit) {
                            ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .accessibilityIdentifier("temperaturePicker")

                        Picker("Weight", selection: $settings.weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .accessibilityIdentifier("weightUnitPicker")

                        Picker("Distance/Speed", selection: $settings.distanceSpeedUnit) {
                            ForEach(DistanceSpeedUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .accessibilityIdentifier("distanceSpeedPicker")
                    }

                    #if targetEnvironment(simulator)
                    Section(header: Text("Testing")) {
                        Button(action: generateTestData) {
                            Text("Generate Weight Data")
                                .foregroundColor(.blue)
                        }

                        if !testDataMessage.isEmpty {
                            Text(testDataMessage)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    #endif

                    Section(header: Text("About")) {
                        NavigationLink(destination: PrivacyPolicyView()) {
                            Text("Privacy Policy & Disclaimer")
                        }
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"))")
                                .foregroundColor(.secondary)
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
                    .accessibilityIdentifier("doneButton")
                }
            }
        }
    }

    #if targetEnvironment(simulator)
    private func generateTestData() {
        healthManager.generateTestData { success, error in
            if success {
                testDataMessage = "✓ Weight data generated (60 days)"
            } else {
                testDataMessage = "✗ Failed to generate weight data"
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
