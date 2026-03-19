# Hemoglobin A1C Export Implementation Guide

## Overview

Hemoglobin A1C export is part of the current HealthExporter release. Users can opt into exporting Clinical Health Records lab results and the app will include matching A1C records in the combined CSV output.

> Testing status: A1C export has been verified working end-to-end on a physical device with Clinical Health Records enabled.

## Current Architecture

### Data Model

- `HealthSampleTypes.swift` defines `A1CSample`
- `A1CSample` parses FHIR payloads from `HKClinicalRecord`
- The parser looks for LOINC `4548-4`
- Parsed fields are `effectiveDateTime`, `valueQuantity.value`, `valueQuantity.unit`, and source name

### HealthKit Authorization

- `HealthKitManager.requestAuthorization(includeA1C:)` includes clinical records only when A1C export is selected
- Production authorization is read-only; `toShare` is an empty set
- The app currently targets iOS 26+, while the clinical-records code path itself is guarded with `#available(iOS 15.0, *)`

### Fetch Path

- `HealthKitManager.fetchA1CData(dateRange:limit:completion:)` fetches clinical lab result records
- The query currently fetches records first, then filters the parsed `A1CSample` values by date range
- That keeps the implementation simple, but it is also a candidate for query-level filtering later

### UI and Settings

- `SettingsManager` persists `exportA1C`
- `DataSelectionView` shows the Hemoglobin A1C toggle and includes A1C in the export dispatch group
- `SettingsView` exposes simulator-only test data generation, but the write path is not part of the production export flow

### CSV Output

- `CSVGenerator` appends A1C rows to the combined export
- The metric label is `Hemoglobin A1C`
- The value is formatted to 2 decimal places

## Required Configuration

The app uses generated Info.plist values from `HealthExporter.xcodeproj/project.pbxproj`. Keep these build settings present:

- `INFOPLIST_KEY_NSHealthClinicalHealthRecordsShareUsageDescription`
- `INFOPLIST_KEY_NSHealthShareUsageDescription`
- `INFOPLIST_KEY_NSHealthUpdateUsageDescription`

The Clinical Health Records usage string should clearly explain why the app needs A1C access.

## Device Verification

- Clinical Records are not available in the simulator
- Validate A1C export on a physical iOS device
- Make sure the device has clinical records synced in Apple Health

## Data Flow

1. User selects Hemoglobin A1C in `DataSelectionView`
2. The app requests HealthKit read access for the selected metrics
3. `HealthKitManager` fetches the clinical records
4. The FHIR payloads are parsed into `A1CSample` values
5. `CSVGenerator` appends A1C rows into the combined CSV
6. The system file picker handles the save/export step

## Notes

- A1C export is optional and defaults to disabled
- Existing weight, steps, and glucose export behavior is unchanged
- The simulator-only write path remains behind `#if targetEnvironment(simulator)`
