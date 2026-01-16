# Hemoglobin A1C Export Implementation Guide

## Overview
Hemoglobin A1C export capability has been successfully added to HealthExporter. This feature allows users to export their A1C lab results from HealthKit's Clinical Records.

## Implementation Details

### 1. Data Model (HealthSampleTypes.swift)
Added `A1CSample` struct that:
- Parses FHIR resources from `HKClinicalRecord` objects
- Searches for LOINC code **4548-4** (Hemoglobin A1C)
- Extracts three key fields:
  - `effectiveDateTime`: The date/time of the lab result
  - `valueQuantity.value`: The A1C percentage value
  - `valueQuantity.unit`: The unit (typically "%")
- Uses `JSONSerialization` for JSON extraction from FHIR resources
- Includes comprehensive error handling for malformed records

### 2. HealthKit Manager (HealthKitManager.swift)

#### Authorization Request Updated
- Now requests `HKClinicalTypeIdentifier.labResultRecord` permission (iOS 15.0+)
- Added version check: `#available(iOS 15.0, *)`
- Maintains backward compatibility with older iOS versions

#### New Fetch Method: `fetchA1CData()`
```swift
func fetchA1CData(dateRange: (startDate: Date, endDate: Date)? = nil, 
                  completion: @escaping ([A1CSample]?, Error?) -> Void)
```
- Uses `HKClinicalQuery` to fetch lab result records
- Filters for LOINC code 4548-4 (A1C) within the FHIR resource
- Applies date range filtering post-query (clinical records don't support HKQuery date predicates)
- Returns parsed `A1CSample` objects

### 3. Settings Management (SettingsManager.swift)
- Added `@Published var exportA1C: Bool` property
- Persists preference to UserDefaults with key `"exportA1C"`
- Defaults to `false` on first app launch

### 4. User Interface (DataSelectionView.swift)
- Added toggle: "Hemoglobin A1C (%)"
- Integrated into metric selection and export flow
- Updated `hasSelectedMetric` computed property
- A1C data is fetched concurrently with other metrics via DispatchGroup

### 5. CSV Generation (CSVGenerator.swift)
- Updated `generateCombinedCSV()` method signature to include `a1cSamples` parameter
- A1C records appear in CSV with:
  - Metric name: "Hemoglobin A1C"
  - Value formatted to 2 decimal places
  - Unit: From FHIR resource (typically "%")
  - Example row: `2026-01-15 14:30:00,2026-01-15T14:30:00Z,Hemoglobin A1C,7.50,%`

## Required Configuration

### ⚠️ Info.plist Setup
Add this key to your `Info.plist`:
```xml
<key>NSHealthClinicalHealthRecordsShareUsageDescription</key>
<string>We need access to your clinical health records to export your Hemoglobin A1C results to a CSV file for your health records.</string>
```

### ⚠️ Xcode Signing & Capabilities
1. Open project settings: **HealthExporter.xcodeproj**
2. Select the **HealthExporter** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add: **Clinical Health Records**
6. Ensure **HealthKit** capability is also present

### iOS Version Requirement
- A1C export requires **iOS 15.0 or later**
- Feature gracefully degrades on older iOS versions (error returned)
- Other export features (Weight, Steps, Blood Glucose) continue to work

## API Details

### FHIR Resource Structure
The clinical records are queried as FHIR Lab Result resources. The A1CSample parser expects:
```json
{
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "4548-4"
      }
    ]
  },
  "effectiveDateTime": "2026-01-15T14:30:00Z",
  "valueQuantity": {
    "value": 7.5,
    "unit": "%"
  }
}
```

### LOINC Code Reference
- **Code**: 4548-4
- **Name**: Hemoglobin A1c
- **System**: http://loinc.org

## Error Handling

The implementation includes comprehensive error handling:
- Returns `nil` if clinical type is unavailable
- Returns `nil` if FHIR resource cannot be parsed
- Returns `nil` if LOINC code 4548-4 is not found
- Returns `nil` if required fields (effectiveDateTime, valueQuantity) are missing
- Graceful degradation on iOS < 15.0

## Testing Notes

### Simulator
- Clinical Records functionality is **not available** on iOS simulator
- Must test on a physical iOS 15.0+ device
- The Health app on the device must have clinical records synced

### Physical Device
1. Enable HealthKit in Signing & Capabilities
2. Ensure Clinical Health Records capability is active
3. User will be prompted for clinical records access on first export attempt
4. Requires the `NSHealthClinicalHealthRecordsShareUsageDescription` in Info.plist

## CSV Output Example

```csv
Date,ISO8601,Metric,Value,Unit
2026-01-15 14:30:00,2026-01-15T14:30:00Z,Weight,185.50,lbs
2026-01-15 14:30:00,2026-01-15T14:30:00Z,Steps,5432,steps
2026-01-15 14:30:00,2026-01-15T14:30:00Z,Blood Glucose,145,mg/dL
2026-01-15 14:30:00,2026-01-15T14:30:00Z,Hemoglobin A1C,7.50,%
```

## Integration with Existing Flow

The A1C export integrates seamlessly with the existing architecture:

1. **Authorization**: Included in the existing `requestAuthorization()` call
2. **Concurrent Fetching**: Uses DispatchGroup alongside other data fetches
3. **CSV Generation**: Appended to existing combined CSV format
4. **Settings Persistence**: Follows same UserDefaults pattern as other metrics
5. **UI**: Consistent toggle-based selection matching Weight/Steps/Glucose

## Future Enhancements

Potential improvements for future versions:
- Support for additional clinical record types (e.g., lab panels)
- Additional LOINC codes (e.g., blood pressure readings, lipid panels)
- Unit preference settings for A1C (e.g., mmol/mol conversion)
- Date range filtering optimization at query level (when HealthKit supports it)

## Code Changes Summary

### Files Modified
1. **HealthSampleTypes.swift** - Added `A1CSample` struct
2. **HealthKitManager.swift** - Added authorization and `fetchA1CData()` method
3. **SettingsManager.swift** - Added `exportA1C` property
4. **DataSelectionView.swift** - Added A1C toggle and fetch logic
5. **CSVGenerator.swift** - Updated CSV generation with A1C data

### Backward Compatibility
- All changes are backward compatible
- A1C export is optional and defaults to disabled
- Existing weight/steps/glucose export unaffected
- iOS 15.0+ requirement isolated to A1C feature only
