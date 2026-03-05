# HealthExporter Code Review

## Overview

The app exports Apple HealthKit data (weight, steps, blood glucose, A1C) to CSV files. The architecture is well-structured with clear separation of concerns across views, managers, and data models.

---

## Critical Issues

### 1. ~~Temporary files never cleaned up~~ ✅ RESOLVED

The share sheet and `saveToTemporaryLocation()` have been removed. The app now uses SwiftUI's `.fileExporter()` exclusively, which does not create temporary files.

### 2. ~~Sensitive health data in debug logs~~ ✅ RESOLVED

`print()` statements replaced with `os.Logger` using `.debug` level. Sensitive values use `privacy: .private` redaction.

### 3. ~~Errors silently swallowed~~ ✅ RESOLVED

`ExportError` enum added with localized error descriptions. `DataSelectionView` now surfaces errors via `.alert()` for authorization failures, empty data, and file write failures.

---

## High-Priority Issues

### 4. Force unwraps on calendar calculations
**Locations:** `DataSelectionView.swift` (~line 335), `HealthKitManager.swift` (~lines 44, 63, 101, 165)

`Calendar.current.date(byAdding:...)!` — while unlikely to crash, these are unnecessary risks.

**Fix:** Use `guard let` with a fallback:
```swift
guard let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else {
    return
}
```

### 5. Blood glucose filter silently drops data
**Location:** `HealthSampleTypes.swift` (lines ~11-14)

Values below 20 mg/dL are silently discarded, assuming they're percentage misinterpretations. Valid low readings could be lost without any indication.

**Fix:** Log filtered values at minimum. Consider making the threshold configurable or warning the user about filtered records.

### 6. ~~No validation before export~~ ✅ RESOLVED

`DataSelectionView` now checks that at least one metric returned data (`hasData` guard) and shows an `ExportError.noDataFound` alert if the export would be empty. The export button is also disabled when no metrics are selected or the date range is invalid.

---

## Medium-Priority Issues

### 7. Migrate from DispatchGroup to async/await
**Location:** `DataSelectionView.swift` (~lines 267-304)

The current DispatchGroup-based fetching pattern is harder to read and doesn't support cancellation.

**Fix:** Refactor to use Swift concurrency with `TaskGroup`, which also enables cancellation:
```swift
func fetchData() async {
    await withTaskGroup(of: Void.self) { group in
        if settings.exportWeight {
            group.addTask { weightSamples = await healthKitManager.fetchWeight(...) }
        }
        // ...
    }
}
```

### 8. Consolidate onChange handlers
**Location:** `DataSelectionView.swift` (~lines 220-229)

Nine separate `onChange` handlers for validation logic could be grouped into a single validation method triggered by relevant state changes.

### 9. ~~SecretsManager is empty~~ (Resolved)
`SecretsManager.swift` has been removed from the project.

### 10. BuildConfig uses static flag
**Location:** `BuildConfig.swift`

`BuildConfig.isPaidAccount` is a static boolean that can't be injected or overridden for testing. Consider making it injectable via the environment or an initializer parameter.

---

## Low-Priority / Code Quality

### 11. ~~CSV generation efficiency~~ (Resolved)
`CSVGenerator.swift` now uses append methods that write directly to a string buffer (`csv.append()`), avoiding intermediate array allocations. Each metric type has a dedicated `appendXxxRows(to:samples:...)` method that sorts in-place and appends rows directly.

### 12. ~~Inconsistent error handling patterns~~ ✅ PARTIALLY RESOLVED

`ExportError` enum added in `ExportError.swift` with cases for `healthKitAuthorizationFailed`, `noDataFound`, and `fileWriteFailed` — each with associated underlying errors and localized descriptions. HealthKit fetch methods still use completion-handler error patterns.

### 13. ~~Add unit tests~~ (Partially resolved)
Unit tests have been added in `HealthExporterTests/`:
- `CSVGeneratorTests.swift` — CSV generation for all metrics, unit conversion, formatting
- `DateRangeOptionTests.swift` — date range enum cases and display names
- `HealthMetricConfigTests.swift` — metric availability and LOINC codes
- `GlucoseSampleTests.swift` — blood glucose filtering logic

Remaining gaps: HealthKit data fetching (requires HealthKit store), FHIR parsing (requires HKClinicalRecord), and SwiftUI views.
