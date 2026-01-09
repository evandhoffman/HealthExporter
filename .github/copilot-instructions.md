# HealthExporter - Copilot Instructions

## Project Overview

HealthExporter is an iOS app built with SwiftUI that exports HealthKit data to CSV files. The app allows users to export their weight history with optional date range filtering.

## Tech Stack

- **Language**: Swift 5
- **UI Framework**: SwiftUI
- **Platform**: iOS 26.1+
- **Frameworks**: HealthKit, UniformTypeIdentifiers

## Project Structure

```
HealthExporter/
├── HealthExporter.xcodeproj/     # Xcode project file
├── HealthExporter/
│   └── HealthExporter/           # Main source folder
│       ├── HealthExporterApp.swift   # App entry point (@main)
│       ├── SplashView.swift          # Welcome/splash screen
│       ├── DataSelectionView.swift   # Data selection & export UI
│       ├── HealthKitManager.swift    # HealthKit authorization & queries
│       ├── CSVGenerator.swift        # CSV string generation
│       ├── CSVDocument.swift         # FileDocument for export
│       └── Assets.xcassets/          # App assets
└── README.md
```

## Architecture

### Views
- **SplashView**: Initial welcome screen with app title and "Next" button
- **DataSelectionView**: Main screen with data type toggles, date pickers, and export button

### Managers
- **HealthKitManager**: Handles HealthKit authorization and data fetching with optional date range filtering

### Utilities
- **CSVGenerator**: Converts HKQuantitySample arrays to CSV strings
- **CSVDocument**: FileDocument implementation for SwiftUI's fileExporter

## Key Patterns

1. **Navigation**: Uses NavigationView with NavigationLink for screen transitions
2. **File Export**: Uses SwiftUI's `.fileExporter()` modifier with a custom FileDocument
3. **HealthKit Queries**: Async completion handlers for authorization and data fetching
4. **Date Filtering**: Optional date range with inclusive start/end dates

## Required Capabilities

- **HealthKit**: Must be enabled in Signing & Capabilities
- **Info.plist Keys** (set via Build Settings):
  - `NSHealthShareUsageDescription`
  - `NSHealthUpdateUsageDescription`

## Development Notes

- HealthKit requires a physical iOS device for full testing (simulator has limited support)
- The app currently exports weight (bodyMass) data only
- CSV filenames use the format: `YYYY-MM-DD_weight_data.csv`
- Default date range is past 30 days; "All Data" toggle disables filtering

## Future Expansion

When adding new health data types:
1. Add new quantity type identifiers in `HealthKitManager.requestAuthorization()`
2. Create new fetch methods in `HealthKitManager` for each data type
3. Add corresponding toggle switches in `DataSelectionView`
4. Extend `CSVGenerator` with methods for each data type
5. Update the export logic to combine selected data types

## Code Style

- SwiftUI declarative syntax
- Completion handler pattern for async HealthKit operations
- `@State` properties for view-local state management
- Compact DatePicker style for space efficiency
