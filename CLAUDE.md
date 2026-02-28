# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HealthExporter is an iOS SwiftUI app that exports Apple HealthKit data (Weight, Steps, Blood Glucose, Hemoglobin A1C) to CSV files. Target platform: iOS 26+ physical devices only.

## Build & Run

```bash
# Open workspace in Xcode
open HealthExporter.xcworkspace

# Command-line build (Debug)
xcodebuild -workspace HealthExporter.xcworkspace -scheme HealthExporter -configuration Debug

# Command-line build (Release/Archive)
xcodebuild -workspace HealthExporter.xcworkspace -scheme HealthExporter -configuration Release archive
```

**Important**: HealthKit requires a **physical iOS device** for full testing. The simulator has limited HealthKit support. Use "Generate Test Data" (in Settings, simulator-only) for UI development.

## Architecture

### Navigation Flow
`HealthExporterApp` (NavigationStack) → `SplashView` → `DataSelectionView`; Settings sheet accessible from SplashView gear icon.

### Key Components

| File | Role |
|------|------|
| `HealthKitManager.swift` | HealthKit authorization + data fetching; uses DispatchGroup for parallel concurrent queries |
| `HealthMetricConfig.swift` | Central metric registry with `requiresPaidAccount` flags and `isAvailable` checks |
| `SettingsManager.swift` | `@ObservableObject` persisting unit prefs to UserDefaults; forces unavailable metrics to `false` at init |
| `CSVGenerator.swift` | Converts HKQuantitySample arrays → CSV string with unit conversion |
| `BuildConfig.swift` | Feature flag: `hasPaidDeveloperAccount` gates A1C availability |
| `DataSelectionView.swift` | Main UI: metric toggles, date range picker, Save/Share export buttons |

### Export Flow
1. User selects metrics + date range in `DataSelectionView`
2. HealthKit authorization requested (if needed)
3. `HealthKitManager` fetches selected metrics in parallel (DispatchGroup)
4. `CSVGenerator.generateCombinedCSV()` builds output
5. Save → SwiftUI `.fileExporter()` → Files app; Share → `ShareSheet` → `UIActivityViewController`
6. Sample arrays and CSV content are cleared from memory immediately after export

## Critical Patterns

### Metric Availability (MUST follow this pattern)
Metric availability is centrally managed in `HealthMetricConfig.swift`. When gating a metric on a paid account:

1. Set `requiresPaidAccount: true` in `HealthMetricConfig.swift`
2. Use `HealthMetrics.{metric}.isAvailable` everywhere — never check `BuildConfig` directly
3. In `DataSelectionView`, use a custom `Binding` that enforces unavailability:
```swift
Toggle("", isOn: Binding(
    get: { HealthMetrics.a1c.isAvailable && settings.exportA1C },
    set: { newValue in
        if HealthMetrics.a1c.isAvailable { settings.exportA1C = newValue }
        else { settings.exportA1C = false }
    }
))
```
4. In `SettingsManager.init()`, force unavailable metrics to `false` and remove from UserDefaults
5. In `hasSelectedMetric`, only count metrics where `isAvailable && setting == true`

### Memory Management (CRITICAL)
HealthKit datasets can be very large. Always:
- Release sample arrays immediately after CSV generation: `weightSamples = nil`
- Clear `csvContent` after successful export
- Use `lines.joined(separator: "\n")` (not string concatenation) in CSV generation
- Pre-allocate with `lines.reserveCapacity(...)` when count is known

### Adding a New Metric
1. Add to `HealthMetricConfig.swift` with `requiresPaidAccount` value
2. Add quantity type to `HealthKitManager.requestAuthorization()`
3. Add fetch method in `HealthKitManager`
4. Add toggle in `DataSelectionView` using the availability binding pattern above
5. Extend `CSVGenerator.generateCombinedCSV()` for the new type
6. Add unit conversion if needed
7. Update `SettingsManager.init()` to force unavailable metrics to `false`
8. Release samples after CSV generation (memory optimization)

## CSV Format

```
Date,ISO8601,Metric,Value,Unit
2026-01-09 10:30:00,2026-01-09T10:30:00Z,Weight,185.50,lbs
```

- **Date**: `yyyy-MM-dd HH:mm:ss` (local time, Excel-friendly)
- **ISO8601**: `yyyy-MM-dd'T'HH:mm:ssZ` (UTC)
- Filename: `HealthExporter_YYYY-MM-DD_HHMMSS.csv`
- Weight precision: 2 decimal places

## Required Capabilities

- **HealthKit**: Always required (enabled in Signing & Capabilities)
- **Clinical Health Records**: Required for A1C; only enable when `BuildConfig.hasPaidDeveloperAccount == true`
- Info.plist keys set via Build Settings (`INFOPLIST_KEY_*`): `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`, `NSHealthClinicalHealthRecordsShareUsageDescription`

## A1C Status

Hemoglobin A1C export is **untested end-to-end**. The code compiles and is gated behind `BuildConfig.hasPaidDeveloperAccount`, but has not been verified on a device with Clinical Health Records enabled. See `docs/a1c/` for FHIR/LOINC implementation details.

## Documentation

Feature documentation lives in `docs/`, organized by subdirectory (e.g., `docs/a1c/`). Update docs when changing implementation details.
