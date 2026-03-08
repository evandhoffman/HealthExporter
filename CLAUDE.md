# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HealthExporter is an iOS SwiftUI app that exports Apple HealthKit data (Weight, Steps, Blood Glucose, Hemoglobin A1C) to CSV files. Target platform: iOS 26+ physical devices only.

## Build & Run

```bash
# Open project in Xcode
open HealthExporter.xcodeproj

# Command-line build (Debug)
xcodebuild -project HealthExporter.xcodeproj -scheme HealthExporter -configuration Debug

# Command-line build (Release/Archive)
xcodebuild -project HealthExporter.xcodeproj -scheme HealthExporter -configuration Release archive
```

**Important**: HealthKit requires a **physical iOS device** for full testing. The simulator has limited HealthKit support. Use "Generate Test Data" (in Settings, simulator-only) for UI development.

## Architecture

### Navigation Flow
`HealthExporterApp` (NavigationStack) → `LaunchView` (splash with loading spinner, then reveals Next button + Settings) → `DataSelectionView`; Settings sheet accessible from LaunchView.

### Key Components

| File | Role |
|------|------|
| `HealthKitManager.swift` | HealthKit authorization + data fetching; uses DispatchGroup for parallel concurrent queries |
| `HealthMetricConfig.swift` | Central metric registry for supported export metrics |
| `SettingsManager.swift` | `@ObservableObject` persisting unit/format prefs to UserDefaults |
| `CSVGenerator.swift` | Converts HKQuantitySample arrays → CSV string with unit conversion, configurable date format and sort order |
| `DataSelectionView.swift` | Main UI: metric toggles, date range picker, Save/Share export buttons |

### Export Flow
1. User selects metrics + date range in `DataSelectionView`
2. HealthKit authorization requested (if needed)
3. `HealthKitManager` fetches selected metrics in parallel (DispatchGroup)
4. `CSVGenerator.generateCombinedCSV()` builds output
5. Save → SwiftUI `.fileExporter()` → Files app; Share → `ShareSheet` → `UIActivityViewController`
6. Sample arrays and CSV content are cleared from memory immediately after export

## Critical Patterns

### Metric Registry
Supported metrics are centralized in `HealthMetricConfig.swift`. If you add a new metric:

1. Add it to `HealthMetrics`
2. Add authorization/fetching support in `HealthKitManager`
3. Add a toggle in `DataSelectionView`
4. Persist its setting in `SettingsManager`
5. Extend CSV generation and tests

### Memory Management (CRITICAL)
HealthKit datasets can be very large. Always:
- Release sample arrays immediately after CSV generation: `weightSamples = nil`
- Clear `csvContent` after successful export
- Use `lines.joined(separator: "\n")` (not string concatenation) in CSV generation
- Pre-allocate with `lines.reserveCapacity(...)` when count is known

### Adding a New Metric
1. Add to `HealthMetricConfig.swift`
2. Add quantity type to `HealthKitManager.requestAuthorization()`
3. Add fetch method in `HealthKitManager`
4. Add toggle in `DataSelectionView`
5. Extend `CSVGenerator.generateCombinedCSV()` for the new type
6. Add unit conversion if needed
7. Update `SettingsManager` persistence if needed
8. Release samples after CSV generation (memory optimization)

## CSV Format

```
Date,Metric,Value,Unit,Source
2026-01-09 10:30:00,Weight,185.50,lbs,Withings
```

- **Date**: Single column, format selectable in Settings via `DateFormatOption`
  - `yyyy-MM-dd HH:mm:ss` (default, local time, Excel-friendly)
  - `ISO8601` (UTC)
  - `yyyy/MM/dd HH:mm:ss`
  - `MM/dd/yyyy HH:mm:ss`
  - `dd MMM yyyy HH:mm:ss`
- **Sort Order**: Configurable via `SortOrder` enum — ascending (oldest first, default) or descending (newest first)
- Filename: `HealthExporter_YYYY-MM-DD_HHMMSS.csv`
- Weight precision: 2 decimal places
- Default units: Fahrenheit, lbs, imperial (US customary)

## Required Capabilities

- **HealthKit**: Always required (enabled in Signing & Capabilities)
- **Clinical Health Records**: Required for A1C export
- Info.plist keys set via Build Settings (`INFOPLIST_KEY_*`): `NSHealthShareUsageDescription`, `NSHealthClinicalHealthRecordsShareUsageDescription`

## A1C Status

Hemoglobin A1C export has been verified working on a physical device with Clinical Health Records enabled. See `docs/a1c/` for FHIR/LOINC implementation details.

## Documentation

Feature documentation lives in `docs/`, organized by subdirectory (e.g., `docs/a1c/`). Update docs when changing implementation details.
