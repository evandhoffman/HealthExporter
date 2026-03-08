import SwiftUI
import UniformTypeIdentifiers
import HealthKit
import os

private let logger = Logger(subsystem: "com.HealthExporter", category: "DataSelection")

struct DataSelectionView: View {
    @State private var showingExporter = false
    @State private var csvContent = ""
    @State private var fileName = ""
    @State private var selectedDateRangeOption: DateRangeOption = .lastXDays
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showingSaveSuccess = false
    @State private var exportEnabled = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false

    @ObservedObject var settings: SettingsManager
    let healthManager = HealthKitManager()

    private static let dayOptions = Array(1...30) + [60, 90, 180, 365, 730]
    private static let recordOptions = Array(stride(from: 100, through: 1_000, by: 100)) + Array(stride(from: 2_000, through: 10_000, by: 1_000))

    private var isValidDateRange: Bool {
        startDate <= endDate
    }

    private var hasSelectedMetric: Bool {
        settings.exportWeight ||
        settings.exportSteps ||
        settings.exportGlucose ||
        settings.exportA1C
    }

    private func updateExportEnabled() {
        guard hasSelectedMetric else {
            exportEnabled = false
            return
        }

        switch selectedDateRangeOption {
        case .lastXDays, .lastXRecords, .allRecords:
            exportEnabled = true
        case .specificDateRange:
            exportEnabled = isValidDateRange
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
                    Image(systemName: "cross.case")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: $settings.exportA1C)
                .labelsHidden()
            }
            .padding(.horizontal)

            HStack(spacing: 4) {
                Image(systemName: "cross.case")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("Requires access to Clinical Health Records")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

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
                VStack(spacing: 4) {
                    Text("Days:")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Picker("Days", selection: $settings.lastXDaysValue) {
                        ForEach(DataSelectionView.dayOptions, id: \.self) { days in
                            Text("\(days)").tag(days)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .accessibilityLabel("Number of days")
                }
                .padding(.horizontal)
            }

            // Last X Records Option
            if selectedDateRangeOption == .lastXRecords {
                VStack(spacing: 4) {
                    Text("Records:")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Picker("Records", selection: $settings.lastXRecordsValue) {
                        ForEach(DataSelectionView.recordOptions, id: \.self) { records in
                            Text("\(records)").tag(records)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .accessibilityLabel("Number of records")
                }
                .padding(.horizontal)
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

            if selectedDateRangeOption == .specificDateRange && !isValidDateRange {
                Text("End date must be on or after start date")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Button(action: {
                exportData()
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
            .padding()
        }
        .padding()
        .onAppear { updateExportEnabled() }
        .onChange(of: settings.exportWeight) { updateExportEnabled() }
        .onChange(of: settings.exportSteps) { updateExportEnabled() }
        .onChange(of: settings.exportGlucose) { updateExportEnabled() }
        .onChange(of: settings.exportA1C) { updateExportEnabled() }
        .onChange(of: selectedDateRangeOption) { updateExportEnabled() }
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
                csvContent = ""
                errorMessage = ExportError.fileWriteFailed(underlying: error).localizedDescription
                showErrorAlert = true
            }
        }
        .onDisappear {
            csvContent = ""
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

    private func exportData() {
        healthManager.requestAuthorization(includeA1C: settings.exportA1C) { success, error in
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

                let dateFormat = self.settings.dateFormat
                let sortOrder = self.settings.sortOrder
                let weightUnit = self.settings.weightUnit

                var csv = CSVGenerator.csvHeader + "\n"

                if var samples = weightSamples {
                    weightSamples = nil
                    CSVGenerator.appendWeightRows(to: &csv, samples: &samples, unit: weightUnit, dateFormat: dateFormat, sortOrder: sortOrder)
                }

                if var samples = stepsSamples {
                    stepsSamples = nil
                    CSVGenerator.appendStepsRows(to: &csv, samples: &samples, dateFormat: dateFormat, sortOrder: sortOrder)
                }

                if var samples = glucoseSamples {
                    glucoseSamples = nil
                    CSVGenerator.appendGlucoseRows(to: &csv, samples: &samples, dateFormat: dateFormat, sortOrder: sortOrder)
                }

                if var samples = a1cSamples {
                    a1cSamples = nil
                    CSVGenerator.appendA1CRows(to: &csv, samples: &samples, dateFormat: dateFormat, sortOrder: sortOrder)
                }

                csvContent = csv

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
                let dateString = dateFormatter.string(from: Date())
                fileName = "HealthExporter_\(dateString).csv"

                showingExporter = true
            }
        }
    }

    private func getDateRangeForOption() -> (startDate: Date, endDate: Date)? {
        switch selectedDateRangeOption {
        case .lastXDays:
            if let start = Calendar.current.date(byAdding: .day, value: -settings.lastXDaysValue, to: Date()) {
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
            return settings.lastXRecordsValue
        }
    }

}

struct DataSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DataSelectionView(settings: SettingsManager())
    }
}
