# App Store Review Blocker Assessment

**Date:** 2026-03-07  
**App:** HealthExporter / `HealthExporterCSV`  
**Reviewer posture:** Assume rejection unless the implementation is clean, accurate, and justified.

## Likely Rejection Risks

### 1. Clinical Health Records entitlement is always shipped
**Severity:** High

`HealthExporter/HealthExporter.entitlements:5-10` always includes HealthKit plus `com.apple.developer.healthkit.access = health-records`. That is a sensitive entitlement. If the production App ID, provisioning profile, App Review notes, or metadata are not perfectly aligned with Clinical Health Records usage, this is an easy rejection or at minimum a request for clarification.

Why I would push on this:
- The codebase treats A1C as a conditional feature, but the entitlement is unconditional.
- Reviewers tend to scrutinize health-record entitlements harder than ordinary read-only HealthKit access.

### 2. The project still declares a HealthKit write usage string
**Severity:** High

`HealthExporter.xcodeproj/project.pbxproj:360` and `:398` still set `NSHealthUpdateUsageDescription`, even though `HealthKitManager.requestAuthorization()` requests `toShare: Set()` in `HealthExporter/HealthExporter/HealthKitManager.swift:24`.

Why this is risky:
- The app presents itself as read-only.
- The repo docs claim this key was removed, but it is still present.
- Any mismatch between permission strings, privacy disclosures, and runtime behavior is exactly the kind of thing App Review flags.

### 3. In-app privacy text is not fully accurate anymore
**Severity:** Medium

`HealthExporter/HealthExporter/PrivacyPolicyView.swift:35-38` says the CSV is presented via the “system share sheet or file picker.” The current UI in `HealthExporter/HealthExporter/DataSelectionView.swift:236-253` only uses `.fileExporter()`.

Why I would care:
- Privacy and data-handling claims need to be precise.
- This is not catastrophic, but misleading privacy wording is avoidable and weakens trust during review.

### 4. Branding is inconsistent across the app
**Severity:** Medium

The in-app title is “Health Exporter” in `HealthExporter/HealthExporter/LaunchView.swift:18`, while the bundle display name is `HealthExporterCSV` in `HealthExporter.xcodeproj/project.pbxproj:357` and `:395`.

Why this may matter:
- Reviewers regularly compare app name, screenshots, and on-device presentation.
- Inconsistent naming can trigger “metadata not matching the app” questions.

### 5. A1C feature messaging is operationally brittle
**Severity:** Medium

Availability is controlled by the hardcoded `BuildConfig.hasPaidDeveloperAccount = true` in `HealthExporter/HealthExporter/BuildConfig.swift:5`. If that value changes for a build, the UI falls back to a disabled toggle with a money-bag indicator in `HealthExporter/HealthExporter/DataSelectionView.swift:82-109`.

Why I would flag it:
- This is developer-account state leaking into end-user UI.
- If a review build ever ships with the flag off while the entitlement remains on, the app looks confused and under-justified.

## Quality / Polish Concerns

### 6. App icon assets look undercooked
**Severity:** Low

The asset catalog only shows a JPEG-backed icon and a single splash image source under `HealthExporter/HealthExporter/Assets.xcassets/`. No obvious dark/tinted variants are present.

Not usually a rejection by itself, but it contributes to a “not fully finished” impression.

### 7. Support flow punts users to GitHub
**Severity:** Low

`HealthExporter/HealthExporter/LaunchView.swift:49-56` sends “Report a Problem” to a public GitHub issue template. That is workable for an indie utility, but for a HealthKit app it can read as lightweight or unfinished if the App Store metadata does not also provide clear end-user support.

## Verdict

I would not call this an automatic rejection today, but I would absolutely hold it for clarification unless the submission package is tight.

The two things most likely to create App Review friction are:
1. The always-on Clinical Health Records entitlement.
2. The stale `NSHealthUpdateUsageDescription` key in the project.

Fix those first. Then clean up the privacy wording and naming mismatch so the binary tells one coherent story.

## Next Steps

1. Remove `NSHealthUpdateUsageDescription` from the project build settings if the app will remain read-only.
2. Decide whether the Clinical Health Records entitlement should always ship, or only be included in builds that actually expose A1C export.
3. Update privacy/disclosure copy so it matches the current export flow exactly.
4. Align the displayed app name, bundle display name, screenshots, and App Store metadata.
