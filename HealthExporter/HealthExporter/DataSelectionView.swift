import SwiftUI
import UniformTypeIdentifiers
import HealthKit
import os

private let logger = Logger(subsystem: "com.HealthExporter", category: "DataSelection")

struct DataSelectionView: View {
    @State private var showingExporter = false
    @State private var showingShareSheet = false
    @State private var csvContent = ""
    @State private var fileName = ""
    @State private var selectedDateRangeOption: DateRangeOption = .lastXDays
    @State private var lastXDaysValue: String = "30"
    @State private var lastXRecordsValue: String = "100"
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showingSaveSuccess = false
    @State private var exportEnabled = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    @State private var temporaryFileURL: URL?
    
    @ObservedObject var settings: SettingsManager
    let healthManager = HealthKitManager()
    
    private var isValidDateRange: Bool {
        startDate <= endDate
    }
    
    private func isValidNumber(_ text: String) -> Bool {
        if let number = Int(text), number > 0 {
            return true
        }
        return false
    }
    
    private var hasSelectedMetric: Bool {
        settings.exportWeight || 
        settings.exportSteps || 
        settings.exportGlucose || 
        (HealthMetrics.a1c.isAvailable && settings.exportA1C)
    }
    
    private func updateExportEnabled() {
        guard hasSelectedMetric else {
            exportEnabled = false
            return
        }
        
        switch selectedDateRangeOption {
        case .lastXDays:
            exportEnabled = isValidNumber(lastXDaysValue)
        case .lastXRecords:
            exportEnabled = isValidNumber(lastXRecordsValue)
        case .specificDateRange:
            exportEnabled = isValidDateRange
        case .allRecords:
            exportEnabled = true
        }
    }

    var body: some View {
        VStack {
            Text("Select Data to Export")
                .font(.largeTitle)
                .padding()
            
            Toggle(isOn: $settings.exportWeight) {
                Text("Weight")
            }
            .padding(.horizontal)
            
            Toggle(isOn: $settings.exportSteps) {
                Text("Steps")
            }
            .padding(.horizontal)
            
            Toggle(isOn: $settings.exportGlucose) {
                Text("Blood Glucose (mg/dL)")
            }
            .padding(.horizontal)
            
            HStack {
                HStack(spacing: 4) {
                    Text("Hemoglobin A1C (%)")
                    if !HealthMetrics.a1c.isAvailable {
                        Text("💰")
                            .font(.caption)
                    }
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { HealthMetrics.a1c.isAvailable && settings.exportA1C },
                    set: { newValue in
                        if HealthMetrics.a1c.isAvailable {
                            settings.exportA1C = newValue
                        } else {
                            settings.exportA1C = false
                        }
                    }
                ))
                .labelsHidden()
            }
            .padding(.horizontal)
            .opacity(HealthMetrics.a1c.isAvailable ? 1.0 : 0.5)
            .disabled(!HealthMetrics.a1c.isAvailable)
            
            Divider()
                .padding()
            
            Text("Date Range")
                .font(.headline)
                .padding(.horizontal)
            
            Picker("Date Range", selection: $selectedDateRangeOption) {
                ForEach(DateRangeOption.allCases, id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Last X Days Option
            if selectedDateRangeOption == .lastXDays {
                HStack {
                    Text("Days:")
                    TextField("30", text: $lastXDaysValue)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                }
                .padding()
            }
            
            // Last X Records Option
            if selectedDateRangeOption == .lastXRecords {
                HStack {
                    Text("Records:")
                    TextField("100", text: $lastXRecordsValue)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                }
                .padding()
            }
            
            // Specific Date Range Option
            if selectedDateRangeOption == .specificDateRange {
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
            
            if selectedDateRangeOption == .lastXDays && !isValidNumber(lastXDaysValue) {
                Text("Please enter a positive number of days")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if selectedDateRangeOption == .lastXRecords && !isValidNumber(lastXRecordsValue) {
                Text("Please enter a positive number of records")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if selectedDateRangeOption == .specificDateRange && !isValidDateRange {
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
                        .background(exportEnabled ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!exportEnabled)
                
                Button(action: {
                    exportData(forSaving: false)
                }) {
                    Text("Share...")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(exportEnabled ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!exportEnabled)
            }
            .padding()
        }
        .padding()
        .onAppear { updateExportEnabled() }
        .onChange(of: settings.exportWeight) { updateExportEnabled() }
        .onChange(of: settings.exportSteps) { updateExportEnabled() }
        .onChange(of: settings.exportGlucose) { updateExportEnabled() }
        .onChange(of: settings.exportA1C) { updateExportEnabled() }
        .onChange(of: selectedDateRangeOption) { updateExportEnabled() }
        .onChange(of: lastXDaysValue) { updateExportEnabled() }
        .onChange(of: lastXRecordsValue) { updateExportEnabled() }
        .onChange(of: startDate) { updateExportEnabled() }
        .onChange(of: endDate) { updateExportEnabled() }
        .fileExporter(
            isPresented: $showingExporter,
            document: CSVDocument(content: csvContent),
            contentType: .commaSeparatedText,
            defaultFilename: fileName
        ) { result in
            switch result {
            case .success(let url):
                logger.info("File saved to: \(url.path)")
                showingSaveSuccess = true
                csvContent = ""
            case .failure(let error):
                logger.error("Error saving file: \(error.localizedDescription)")
                errorMessage = ExportError.fileWriteFailed(underlying: error).localizedDescription
                showErrorAlert = true
            }
        }
        .sheet(isPresented: $showingShareSheet, onDismiss: {
            if let url = temporaryFileURL {
                try? FileManager.default.removeItem(at: url)
                temporaryFileURL = nil
            }
        }) {
            ShareSheet(filePath: saveToTemporaryLocation(), fileName: fileName)
        }
        .onDisappear {
            csvContent = ""
            if let url = temporaryFileURL {
                try? FileManager.default.removeItem(at: url)
                temporaryFileURL = nil
            }
        }
        .alert("File saved!", isPresented: $showingSaveSuccess) {
            Button("Ok!") {
                showingSaveSuccess = false
            }
        }
        .alert("Export Error", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
    }
    
    private func exportData(forSaving: Bool = false) {
        healthManager.requestAuthorization { success, error in
            guard success else {
                DispatchQueue.main.async {
                    logger.error("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                    errorMessage = ExportError.healthKitAuthorizationFailed(underlying: error).localizedDescription
                    showErrorAlert = true
                }
                return
            }

            var weightSamples: [HKQuantitySample]? = nil
            var stepsSamples: [HKQuantitySample]? = nil
            var glucoseSamples: [GlucoseSampleMgDl]? = nil
            var a1cSamples: [A1CSample]? = nil
            let dispatchGroup = DispatchGroup()

            let dateRange: (startDate: Date, endDate: Date)? = getDateRangeForOption()
            let recordLimit: Int = getRecordLimitForOption()

            if settings.exportWeight {
                dispatchGroup.enter()
                healthManager.fetchWeightData(dateRange: dateRange, limit: recordLimit) { samples, error in
                    weightSamples = samples
                    dispatchGroup.leave()
                }
            }

            if settings.exportSteps {
                dispatchGroup.enter()
                healthManager.fetchStepsData(dateRange: dateRange, limit: recordLimit) { samples, error in
                    stepsSamples = samples
                    dispatchGroup.leave()
                }
            }

            if settings.exportGlucose {
                dispatchGroup.enter()
                healthManager.fetchBloodGlucoseDataTyped(dateRange: dateRange, limit: recordLimit) { samples, error in
                    glucoseSamples = samples
                    dispatchGroup.leave()
                }
            }

            if settings.exportA1C {
                dispatchGroup.enter()
                healthManager.fetchA1CData(dateRange: dateRange) { samples, error in
                    a1cSamples = samples
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                let hasData = (weightSamples?.isEmpty == false) ||
                              (stepsSamples?.isEmpty == false) ||
                              (glucoseSamples?.isEmpty == false) ||
                              (a1cSamples?.isEmpty == false)

                guard hasData else {
                    weightSamples = nil
                    stepsSamples = nil
                    glucoseSamples = nil
                    a1cSamples = nil
                    errorMessage = ExportError.noDataFound.localizedDescription
                    showErrorAlert = true
                    return
                }

                csvContent = CSVGenerator.generateCombinedCSV(weightSamples: weightSamples, stepsSamples: stepsSamples, glucoseSamples: glucoseSamples, a1cSamples: a1cSamples, weightUnit: self.settings.weightUnit)

                weightSamples = nil
                stepsSamples = nil
                glucoseSamples = nil
                a1cSamples = nil

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
                let dateString = dateFormatter.string(from: Date())
                fileName = "HealthExporter_\(dateString).csv"

                if forSaving {
                    showingExporter = true
                } else {
                    showingShareSheet = true
                }
            }
        }
    }
    
    private func getDateRangeForOption() -> (startDate: Date, endDate: Date)? {
        switch selectedDateRangeOption {
        case .lastXDays:
            if let days = Int(lastXDaysValue),
               let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) {
                return (start, Date())
            }
            return nil
        case .lastXRecords:
            return nil
        case .specificDateRange:
            return (startDate, endDate)
        case .allRecords:
            return nil
        }
    }
    
    private func getRecordLimitForOption() -> Int {
        switch selectedDateRangeOption {
        case .lastXDays, .allRecords, .specificDateRange:
            return HKObjectQueryNoLimit
        case .lastXRecords:
            return Int(lastXRecordsValue) ?? 100
        }
    }
    
    private func saveToTemporaryLocation() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            logger.error("Failed to write temp file: \(error.localizedDescription)")
        }
        temporaryFileURL = fileURL
        return fileURL
    }
}

struct DataSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DataSelectionView(settings: SettingsManager())
    }
}