# Hemoglobin A1C Quick Reference

> Testing status: A1C export has been verified working end-to-end on a physical device with Clinical Health Records enabled.

## What It Does

- Exports Hemoglobin A1C values from Apple Health Clinical Records
- Uses LOINC `4548-4` to identify the matching lab result records
- Includes A1C rows in the same CSV as weight, steps, and glucose

## Key Files

- `HealthSampleTypes.swift` for `A1CSample` and FHIR parsing
- `HealthKitManager.swift` for authorization and `fetchA1CData(dateRange:limit:completion:)`
- `SettingsManager.swift` for the `exportA1C` preference
- `DataSelectionView.swift` for the A1C toggle and export flow
- `CSVGenerator.swift` for CSV row generation

## Required Setup

Keep these generated Info.plist build settings in the Xcode project:

- `INFOPLIST_KEY_NSHealthClinicalHealthRecordsShareUsageDescription`
- `INFOPLIST_KEY_NSHealthShareUsageDescription`
- `INFOPLIST_KEY_NSHealthUpdateUsageDescription`

Also make sure the target has HealthKit and Clinical Health Records capabilities enabled.

## Runtime Notes

- The app currently targets iOS 26+
- The A1C code path itself is guarded with `#available(iOS 15.0, *)`
- Simulator support is limited; validate on a physical device
- The simulator-only test data generator is separate from the production export path

## Export Flow

1. User enables Hemoglobin A1C in the export screen
2. App requests HealthKit read access
3. A1C clinical records are fetched and parsed
4. The combined CSV is generated in memory
5. The file picker saves the export

## CSV Example

```csv
Date,Metric,Value,Unit,Source
2026-01-15 14:30:00,Hemoglobin A1C,7.50,%,Apple Health
```

## Notes

- Default export state for A1C is off
- A1C rows are formatted to 2 decimal places
- Existing export metrics are unaffected
