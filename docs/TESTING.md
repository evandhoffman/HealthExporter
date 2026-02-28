# Testing Guide

## Overview

HealthExporter uses XCTest unit tests that run automatically in GitHub CI on every push and pull request.

## Test Structure

Tests live in `HealthExporterTests/` (sibling to the main `HealthExporter/` source folder):

| File | What it tests |
|------|--------------|
| `CSVGeneratorTests.swift` | CSV generation for weight, steps, glucose, A1C; unit conversion (kg→lbs); output formatting |
| `DateRangeOptionTests.swift` | `DateRangeOption` enum cases, raw values, `displayName` |
| `HealthMetricConfigTests.swift` | `HealthMetricConfig.isAvailable`, `HealthMetrics` static properties, `LOINCCode` constants |
| `GlucoseSampleTests.swift` | `GlucoseSampleMgDl` init — values ≥20 accepted, values <20 rejected |
| `SettingsManagerTests.swift` | Default values, UserDefaults persistence, invalid-value fallbacks, A1C availability enforcement |

## Running Tests Locally

### In Xcode
1. Open `HealthExporter.xcworkspace`
2. Select **Product → Test** (⌘U)
3. Results appear in the Test Navigator (⌘6)

### From the command line
```bash
# Install dependencies first (if not already done)
pod install

# Run tests against the latest available simulator
xcodebuild test \
  -workspace HealthExporter.xcworkspace \
  -scheme HealthExporter \
  -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro' \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  | xcpretty
```

## GitHub Actions CI

The workflow is defined in `.github/workflows/ios-tests.yml` and triggers on:
- Pushes to `main` or `add_tests`
- Pull requests targeting `main`

### Required setup — none for public repos

For a **public repository**, no secrets or environment variables are needed. The workflow uses `CODE_SIGNING_ALLOWED=NO` so no Apple Developer account is required to run simulator tests.

### Optional setup for private repos or custom runners

| Setting | Purpose |
|---------|---------|
| `DEVELOPMENT_TEAM` build override | Only needed if you add entitlements-gated features to the test target |

### Xcode version

The workflow automatically picks the newest installed Xcode on the runner:
```yaml
XCODE=$(find /Applications -name "Xcode*.app" -maxdepth 1 -type d | sort -rV | head -1)
sudo xcode-select -s "$XCODE"
```

The project requires **Xcode 26.x** (for the iOS 26.0 deployment target). GitHub's `macos-15` runner should have this installed. If the runner only has an older Xcode, the build will fail with a deployment-target error — in that case, update `runs-on` in the workflow to a newer runner image (e.g. `macos-15-xlarge` or a future `macos-26`).

### xcpretty

The workflow pipes `xcodebuild` output through `xcpretty` for readable CI logs. If `xcpretty` is not pre-installed on the runner, add:
```yaml
- name: Install xcpretty
  run: gem install xcpretty
```
before the "Run tests" step.

### CocoaPods caching

The workflow caches the `Pods/` directory keyed on `Podfile.lock`. If you add or update pods, the cache is automatically invalidated on the next run.

## Adding New Tests

1. Create a new `*Tests.swift` file in `HealthExporterTests/`
2. The `PBXFileSystemSynchronizedRootGroup` in the Xcode project picks it up automatically — no `.pbxproj` edits needed for additional test files.
3. Use `@testable import HealthExporter` to access internal types.

## Coverage Notes

- **HealthKit data fetching** (`HealthKitManager`) is not unit-tested because it requires a running HealthKit store (unavailable in CI). Test those paths on a physical device or simulator with HealthKit data.
- **`A1CSample` / `FHIRLabResultParser`** FHIR parsing is not directly testable without `HKClinicalRecord`, which cannot be instantiated in tests. The `A1CSample` test helper init (defined as an extension in `CSVGeneratorTests.swift`) allows testing the CSV output path without a real clinical record.
- **SwiftUI views** are not tested; consider adding UI tests or snapshot tests if view logic grows complex.
