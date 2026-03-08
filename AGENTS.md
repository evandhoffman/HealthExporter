# Repository Guidelines

## Project Structure & Module Organization
`HealthExporter/HealthExporter/` contains the app source: SwiftUI views (`LaunchView.swift`, `DataSelectionView.swift`, `SettingsView.swift`), managers (`HealthKitManager.swift`, `SettingsManager.swift`), and export logic (`CSVGenerator.swift`, `CSVDocument.swift`). Tests live in `HealthExporterTests/`. Keep user-facing docs in `docs/`, with feature-specific notes under subfolders such as `docs/a1c/`. Store screenshots and marketing assets in `assets/`. Project configuration is in `HealthExporter.xcodeproj/` and `HealthExporter.xcworkspace/`.

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

## Coding Style & Naming Conventions
Follow existing Swift conventions: 4-space indentation, one top-level type per file, `UpperCamelCase` for types, `lowerCamelCase` for properties and methods. Prefer small SwiftUI views and move reusable logic into managers or helper types. Keep comments sparse and only where intent is not obvious. Match current file naming: view types end in `View`, managers end in `Manager`, tests end in `Tests`. When adding metrics, route availability through `HealthMetricConfig.swift`; do not gate UI directly on `BuildConfig`.

## Testing Guidelines
This repo uses `XCTest`. Add tests in `HealthExporterTests/` with filenames like `FeatureNameTests.swift` and methods named `test...`. Cover CSV formatting, date filtering, unit conversion, and metric availability logic. Run `Product > Test` in Xcode or the `xcodebuild test` command above before opening a PR.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commit subjects such as `Fix: clear csvContent on export failure to free memory`, `Update docs to match current codebase`, and version bumps like `Bump build number to 18 [skip ci]`. Keep commits focused. PRs should describe the user-visible change, list testing performed, link related issues, and include screenshots for SwiftUI/UI updates. Note any device-only validation when HealthKit behavior cannot be reproduced in CI.

## Security & Configuration Tips
Do not commit real secrets; use `Secrets.plist.example` as the template. Keep HealthKit data on-device, avoid logging sensitive values, and preserve the privacy-first design. Export paths can hold large datasets, so release HealthKit sample arrays after CSV generation and clear temporary CSV state after save/share flows.
