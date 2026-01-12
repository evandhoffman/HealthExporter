# Health Exporter

An iOS app to export HealthKit data to CSV files.

## Features

- **Splash screen** with navigation to data selection and settings access
- **Multiple health metrics**: Export Weight and Steps data
- **Date range filtering**: Select custom start/end dates or export all data
- **Unit preferences**: Configure weight units (kg/lbs), temperature (°C/°F), and distance/speed (metric/imperial)
- **Dual export options**:
  - **Save**: Save directly to Files app
  - **Share**: Share via iOS share sheet (Dropbox, Google Drive, email, etc.)
- **Settings persistence**: Unit preferences are automatically saved

## Setup

1. Open `HealthExporter.xcodeproj` in Xcode
2. Ensure HealthKit is enabled in Signing & Capabilities
3. Build and run on a physical device (HealthKit has limited simulator support)

## Usage

1. Launch the app
2. (Optional) Tap the gear icon to configure unit preferences
3. Tap "Next" to go to the data selection screen
4. Select metrics to export (Weight, Steps)
5. Choose date range or toggle "All Data"
6. Tap "Save..." to save to Files or "Share..." to share via other apps

## CSV Output Format

The exported CSV includes the following columns:
- **Date**: Timestamp of the measurement in Excel/Google Sheets friendly format (yyyy-MM-dd HH:mm:ss)
- **ISO8601**: Timestamp in ISO8601 format (yyyy-MM-dd'T'HH:mm:ssZ)
- **Metric**: Type of measurement (Weight, Steps)
- **Value**: Numeric value (weight formatted to 2 decimal places)
- **Unit**: Unit of measurement (kg, lbs, steps)

Example:
```
Date,ISO8601,Metric,Value,Unit
2026-01-09 10:30:00,2026-01-09T10:30:00Z,Weight,185.50,lbs
2026-01-09 11:00:00,2026-01-09T11:00:00Z,Steps,5432,steps
```

Filename format: `YYYY-MM-DD_HHMMSS_health_export.csv`

## Requirements

- iOS 26.1+
- Physical iOS device (for full HealthKit functionality)
- HealthKit access permission

## Project Structure

```
HealthExporter/
├── HealthExporter.xcodeproj/
├── HealthExporter/
│   └── HealthExporter/
│       ├── HealthExporterApp.swift
│       ├── SplashView.swift
│       ├── DataSelectionView.swift
│       ├── SettingsView.swift
│       ├── SettingsManager.swift
│       ├── HealthKitManager.swift
│       ├── CSVGenerator.swift
│       ├── CSVDocument.swift
│       ├── ShareSheet.swift
│       └── Assets.xcassets/
└── README.md
```