# Repository Guidelines

## Project Structure & Module Organization
`HealthExporter/HealthExporter/` contains the app source: SwiftUI views (`LaunchView.swift`, `DataSelectionView.swift`, `SettingsView.swift`), managers (`HealthKitManager.swift`, `SettingsManager.swift`), and export logic (`CSVGenerator.swift`, `CSVDocument.swift`). Tests live in `HealthExporterTests/`. Keep user-facing docs in `docs/`, with feature-specific notes under subfolders such as `docs/a1c/`. Store screenshots and marketing assets in `assets/`. Project configuration is in `HealthExporter.xcodeproj/` and `HealthExporter.xcworkspace/`.

## Architecture Notes
Navigation flow: `HealthExporterApp` (`NavigationStack`) → `LaunchView` (splash/loading, then `Next` + Settings) → `DataSelectionView`; `SettingsView` is presented from the launch screen.

Key components:

| File | Role |
|------|------|
| `HealthKitManager.swift` | HealthKit authorization and data fetching; uses `DispatchGroup` for parallel concurrent queries |
| `HealthMetricConfig.swift` | Central metric registry for supported export metrics |
| `SettingsManager.swift` | Persists unit and format preferences in `UserDefaults` |
| `CSVGenerator.swift` | Converts samples to CSV with unit conversion, date formatting, and sort order |
| `DataSelectionView.swift` | Metric toggles, date range picker, export trigger, and exporter state |

A1C support uses Clinical Health Records via `HKClinicalTypeIdentifier.labResultRecord`; see `docs/a1c/` for implementation details.

## Build, Test, and Development Commands
Open the project in Xcode for day-to-day work:

```bash
open HealthExporter.xcodeproj
```

Run the full unit test suite from the command line:

```bash
xcodebuild test -project HealthExporter.xcodeproj -scheme HealthExporter -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17 Pro' CODE_SIGN_IDENTITY='' CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

Build without signing for simulator validation:

```bash
xcodebuild build -project HealthExporter.xcodeproj -scheme HealthExporter -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

Use Xcode on a physical device for HealthKit and Clinical Records verification; simulator coverage is limited.

## Export Flow
The app is read-only with respect to HealthKit in production. `HealthKitManager.requestAuthorization()` calls `requestAuthorization(toShare: Set(), read: ...)`.

Export sequence:
1. User selects metrics and a date range in `DataSelectionView`.
2. HealthKit read authorization is requested if needed.
3. `HealthKitManager` fetches the selected metrics in parallel.
4. `CSVGenerator.generateCombinedCSV()` builds the output in memory.
5. SwiftUI `.fileExporter()` presents the Files picker.
6. Sample arrays and `csvContent` are cleared after export.

Keep this flow and its surrounding privacy copy aligned whenever export behavior changes.

## Coding Style & Naming Conventions
Follow existing Swift conventions: 4-space indentation, one top-level type per file, `UpperCamelCase` for types, `lowerCamelCase` for properties and methods. Prefer small SwiftUI views and move reusable logic into managers or helper types. Keep comments sparse and only where intent is not obvious. Match current file naming: view types end in `View`, managers end in `Manager`, tests end in `Tests`. When adding metrics, route availability through `HealthMetricConfig.swift`; do not gate UI directly on `BuildConfig`.

## Implementation Patterns
When adding a metric:
1. Update `HealthMetricConfig.swift`.
2. Request the right HealthKit type in `HealthKitManager`.
3. Add the toggle and selection handling in `DataSelectionView`.
4. Persist the setting in `SettingsManager`.
5. Extend `CSVGenerator`.
6. Add tests and docs in the same change.

Memory management matters because HealthKit datasets can be large:
- Release fetched sample arrays immediately after CSV generation, for example `weightSamples = nil`.
- Clear `csvContent` after successful export.
- Prefer append-style CSV generation and avoid unnecessary intermediate allocations.
- Profile memory if a change could expand retained sample data.

CSV format details:
- Columns are `Date,Metric,Value,Unit,Source`
- Date formats come from `DateFormatOption`
- Sort order comes from `SortOrder`
- Weight precision is 2 decimals
- Filename format is `HealthExporter_YYYY-MM-DD_HHMMSS.csv`
- Default units are Fahrenheit, pounds, and imperial

## Testing Guidelines
This repo uses `XCTest`. Add tests in `HealthExporterTests/` with filenames like `FeatureNameTests.swift` and methods named `test...`. Cover CSV formatting, date filtering, unit conversion, and metric availability logic. Run `Product > Test` in Xcode or the `xcodebuild test` command above before opening a PR.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commit subjects such as `Fix: clear csvContent on export failure to free memory`, `Update docs to match current codebase`, and version bumps like `Bump build number to 18 [skip ci]`. Keep commits focused. PRs should describe the user-visible change, list testing performed, link related issues, and include screenshots for SwiftUI/UI updates. Note any device-only validation when HealthKit behavior cannot be reproduced in CI.

## Security & Configuration Tips
Do not commit real secrets; use `Secrets.plist.example` as the template. Keep HealthKit data on-device, avoid logging sensitive values, and preserve the privacy-first design.

Required capabilities and configuration:
- HealthKit is always required.
- Clinical Health Records is required for A1C export.
- Usage descriptions are set via build settings: `NSHealthShareUsageDescription` and `NSHealthClinicalHealthRecordsShareUsageDescription`.

HealthKit requires a physical device for full verification. The simulator has limited support; use the simulator-only test data generator for UI development when needed.
