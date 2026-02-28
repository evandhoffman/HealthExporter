# HealthExporter Code Review

## Overview

The app exports Apple HealthKit data (weight, steps, blood glucose, A1C) to CSV files. The architecture is well-structured with clear separation of concerns across views, managers, and data models.

---

## Critical Issues

### 1. Temporary files never cleaned up
**Location:** `DataSelectionView.swift` — `saveToTemporaryLocation()`

`saveToTemporaryLocation()` writes CSVs to the temp directory but never deletes them. They accumulate over time.

**Fix:** Delete the temp file after the share sheet dismisses, e.g.:
```swift
.sheet(isPresented: $showShareSheet, onDismiss: {
    if let url = temporaryFileURL {
        try? FileManager.default.removeItem(at: url)
    }
}) { ... }
```

### 2. Sensitive health data in debug logs
**Location:** `HealthKitManager.swift`

`print()` statements log glucose values and sample details. This is a privacy concern in production builds.

**Fix:** Replace `print()` with `os.Logger` and use `.debug` level so messages are stripped in release builds:
```swift
import os
private let logger = Logger(subsystem: "com.yourapp.HealthExporter", category: "HealthKit")
logger.debug("Fetched \(samples.count) samples")
```

### 3. Errors silently swallowed
**Locations:** `DataSelectionView.swift` (lines ~238, ~243, ~360), `HealthKitManager.swift`

Multiple `try?` usages and `print()` for error reporting mean the user gets no feedback when something fails (HealthKit authorization, file writes, etc.).

**Fix:** Surface errors to the user via alerts:
```swift
@State private var errorMessage: String?
@State private var showErrorAlert = false

.alert("Export Error", isPresented: $showErrorAlert) {
    Button("OK") { }
} message: {
    Text(errorMessage ?? "An unknown error occurred.")
}
```

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

### 6. No validation before export
**Location:** `CSVGenerator.swift`, `DataSelectionView.swift`

Users can export empty CSV files without any warning.

**Fix:** Check that at least one metric returned data before generating the CSV, and show an alert if the export would be empty.

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

### 9. SecretsManager is empty
**Location:** `SecretsManager.swift`

Empty singleton class with only a TODO comment. Remove it or implement it.

### 10. BuildConfig uses static flag
**Location:** `BuildConfig.swift`

`BuildConfig.isPaidAccount` is a static boolean that can't be injected or overridden for testing. Consider making it injectable via the environment or an initializer parameter.

---

## Low-Priority / Code Quality

### 11. CSV generation efficiency
**Location:** `CSVGenerator.swift`

String concatenation in a loop can be inefficient for large datasets. Consider building an array of lines and joining at the end, or streaming directly to a file.

### 12. Inconsistent error handling patterns
**Location:** Codebase-wide

Mix of optional returns, NSError completions, and `print()` calls. A unified error type would improve consistency:
```swift
enum ExportError: LocalizedError {
    case healthKitAuthorizationFailed
    case fileWriteFailed
    case csvGenerationFailed(reason: String)
    case invalidDateRange

    var errorDescription: String? {
        switch self {
        case .healthKitAuthorizationFailed: return "HealthKit authorization was denied."
        case .fileWriteFailed: return "Failed to save the CSV file."
        case .csvGenerationFailed(let reason): return "CSV generation failed: \(reason)"
        case .invalidDateRange: return "The selected date range is invalid."
        }
    }
}
```

### 13. Add unit tests
Key areas to test:
- CSV generation with various data types and edge cases
- Date range calculations
- Unit conversions (kg/lbs, C/F)
- Blood glucose filtering logic
- Empty data handling
