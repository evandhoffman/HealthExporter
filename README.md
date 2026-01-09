# Health Exporter

An iOS app to export HealthKit data to CSV files.

## Features

- Splash screen with navigation to data selection
- Select weight data to export
- Export to CSV and save via iOS share sheet (supports Files app, Dropbox, Google Drive, etc.)

## Setup

1. Open the project in Xcode (open the folder containing this README).
2. Ensure HealthKit is enabled in the app capabilities.
3. Build and run on a device (HealthKit requires a physical device).

## Usage

1. Launch the app.
2. Tap "Next" on the splash screen.
3. Ensure "Weight" is selected (it's on by default).
4. Tap "Export..." to generate and save the CSV file.

## Requirements

- iOS 14+
- HealthKit access (grant permission when prompted)

## Files

- `src/HealthExporterApp.swift`: Main app entry
- `src/SplashView.swift`: Splash screen
- `src/DataSelectionView.swift`: Data selection screen
- `src/HealthKitManager.swift`: HealthKit interaction
- `src/CSVGenerator.swift`: CSV generation
- `src/DocumentExporter.swift`: File export dialog
- `Info.plist`: App configuration