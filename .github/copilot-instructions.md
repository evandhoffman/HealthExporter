# HealthExporter - Copilot Instructions

## Project Overview

HealthExporter is an iOS app built with SwiftUI that exports HealthKit data to CSV files. The app allows users to export their weight and steps history with optional date range filtering and configurable unit preferences.

## Tech Stack

- **Language**: Swift 5
- **UI Framework**: SwiftUI
- **Platform**: iOS 26.1+
- **Frameworks**: HealthKit, UniformTypeIdentifiers, Combine

## Project Structure

```
HealthExporter/
├── HealthExporter.xcodeproj/     # Xcode project file
├── HealthExporter/
│   └── HealthExporter/           # Main source folder
│       ├── HealthExporterApp.swift   # App entry point (@main)
│       ├── SplashView.swift          # Welcome/splash screen with settings access
│       ├── DataSelectionView.swift   # Data selection, date range & export UI
│       ├── SettingsView.swift        # Settings panel for unit preferences
│       ├── SettingsManager.swift     # Settings persistence with UserDefaults
│       ├── HealthKitManager.swift    # HealthKit authorization & queries
│       ├── CSVGenerator.swift        # CSV string generation with unit conversion
│       ├── CSVDocument.swift         # FileDocument for SwiftUI fileExporter
│       ├── ShareSheet.swift          # UIActivityViewController wrapper
│       └── Assets.xcassets/          # App assets
└── README.md
```

## Architecture

### Views
- **SplashView**: Welcome screen with "Next" button and gear icon for Settings
- **DataSelectionView**: Main screen with metric toggles (Weight, Steps), date pickers, and Save/Share buttons
- **SettingsView**: Unit preference configuration (Temperature, Weight, Distance/Speed)

### Managers
- **HealthKitManager**: Handles HealthKit authorization and data fetching with optional date range filtering
- **SettingsManager**: ObservableObject that persists unit preferences via UserDefaults

### Utilities
- **CSVGenerator**: Converts HKQuantitySample arrays to CSV strings with unit conversion
- **CSVDocument**: FileDocument implementation for SwiftUI's fileExporter
- **ShareSheet**: UIViewControllerRepresentable wrapper for UIActivityViewController

## Key Patterns

1. **Navigation**: Uses NavigationView with NavigationLink for screen transitions
2. **File Export**: Two options:
   - SwiftUI's `.fileExporter()` modifier for Save functionality
   - UIActivityViewController (via ShareSheet) for Share functionality
3. **HealthKit Queries**: Async completion handlers with DispatchGroup for parallel fetching
4. **Date Filtering**: Optional date range with inclusive start/end dates
5. **Settings Persistence**: UserDefaults with @Published properties for auto-save
6. **Unit Conversion**: Weight converted from kg to lbs based on user preference (1 kg = 2.2046226218 lbs)

## Required Capabilities

- **HealthKit**: Must be enabled in Signing & Capabilities
- **Info.plist Keys** (set via Build Settings as INFOPLIST_KEY_*):
  - `NSHealthShareUsageDescription`
  - `NSHealthUpdateUsageDescription`

## Supported Health Metrics

| Metric | HealthKit Identifier | Units |
|--------|---------------------|-------|
| Weight | `.bodyMass` | kg, lbs |
| Steps | `.stepCount` | count |

## CSV Output Format

Columns: `Date, Metric, Value, Unit`

Example:
```
Date,Metric,Value,Unit
1/9/26, 10:30 AM,Weight,185.50,lbs
1/9/26, 11:00 AM,Steps,5432,steps
```

Filename format: `HealthExporter_YYYY-MM-DD_HHMMSS.csv`

## Development Notes

- HealthKit requires a physical iOS device for full testing (simulator has limited support)
- Export button is disabled when no metrics are selected or date range is invalid
- Weight values are formatted to 2 decimal places
- Default date range is past 30 days; "All Data" toggle disables filtering
- Settings auto-save on change (no save button needed)

## Future Expansion

When adding new health data types:
1. Add new quantity type identifiers in `HealthKitManager.requestAuthorization()`
2. Create new fetch methods in `HealthKitManager` for each data type
3. Add corresponding toggle switches in `DataSelectionView`
4. Extend `CSVGenerator.generateCombinedCSV()` with the new data type
5. Add unit conversion logic if applicable
6. Update SettingsManager/SettingsView if new unit preferences are needed

## Code Style

- SwiftUI declarative syntax
- Completion handler pattern for async HealthKit operations
- `@State` properties for view-local state management
- `@ObservedObject` for shared SettingsManager
- `@StateObject` at app root for SettingsManager lifecycle
- Compact DatePicker style for space efficiency
- DispatchGroup for coordinating parallel async operations
