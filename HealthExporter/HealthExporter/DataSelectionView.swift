import SwiftUI
import UniformTypeIdentifiers
import HealthKit

struct DataSelectionView: View {
    @State private var exportWeight = true
    @State private var exportSteps = false
    @State private var showingExporter = false
    @State private var showingShareSheet = false
    @State private var csvContent = ""
    @State private var fileName = ""
    @State private var useAllData = false
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    @State private var endDate = Date()
    
    @ObservedObject var settings: SettingsManager
    let healthManager = HealthKitManager()
    
    private var isValidDateRange: Bool {
        useAllData || startDate <= endDate
    }
    
    private var hasSelectedMetric: Bool {
        exportWeight || exportSteps
    }
    
    private var canExport: Bool {
        hasSelectedMetric && isValidDateRange
    }

    var body: some View {
        VStack {
            Text("Select Data to Export")
                .font(.largeTitle)
                .padding()
            
            Toggle(isOn: $exportWeight) {
                Text("Weight")
            }
            .padding(.horizontal)
            
            Toggle(isOn: $exportSteps) {
                Text("Steps")
            }
            .padding(.horizontal)
            
            Divider()
                .padding()
            
            Text("Date Range")
                .font(.headline)
                .padding(.horizontal)
            
            Toggle(isOn: $useAllData) {
                Text("All Data")
            }
            .padding()
            
            if !useAllData {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Start Date")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("End Date")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                }
                .padding()
            }
            
            Spacer()
            
            if !hasSelectedMetric {
                Text("Please select at least one metric")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if !useAllData && !isValidDateRange {
                Text("End date must be on or after start date")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    exportData(forSaving: true)
                }) {
                    Text("Save...")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(canExport ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!canExport)
                
                Button(action: {
                    exportData(forSaving: false)
                }) {
                    Text("Share...")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(canExport ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!canExport)
            }
            .padding()
        }
        .padding()
        .fileExporter(
            isPresented: $showingExporter,
            document: CSVDocument(content: csvContent),
            contentType: .commaSeparatedText,
            defaultFilename: fileName
        ) { result in
            switch result {
            case .success(let url):
                print("File saved to: \(url)")
            case .failure(let error):
                print("Error saving file: \(error)")
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(filePath: saveToTemporaryLocation(), fileName: fileName)
        }
    }
    
    private func exportData(forSaving: Bool) {
        healthManager.requestAuthorization { success, error in
            if success {
                let dateRange = useAllData ? nil : (startDate, endDate)
                
                var weightSamples: [HKQuantitySample]? = nil
                var stepsSamples: [HKQuantitySample]? = nil
                let dispatchGroup = DispatchGroup()
                
                if exportWeight {
                    dispatchGroup.enter()
                    healthManager.fetchWeightData(dateRange: dateRange) { samples, error in
                        weightSamples = samples
                        dispatchGroup.leave()
                    }
                }
                
                if exportSteps {
                    dispatchGroup.enter()
                    healthManager.fetchStepsData(dateRange: dateRange) { samples, error in
                        stepsSamples = samples
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    csvContent = CSVGenerator.generateCombinedCSV(weightSamples: weightSamples, stepsSamples: stepsSamples, weightUnit: self.settings.weightUnit)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
                    let dateString = dateFormatter.string(from: Date())
                    fileName = "\(dateString)_health_export.csv"
                    
                    if forSaving {
                        showingExporter = true
                    } else {
                        showingShareSheet = true
                    }
                }
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func saveToTemporaryLocation() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        try? csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

struct DataSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DataSelectionView(settings: SettingsManager())
    }
}