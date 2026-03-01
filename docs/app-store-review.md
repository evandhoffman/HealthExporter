# App Store Review Assessment — HealthExporter

**Date:** 2026-03-01
**Bundle ID:** `com.evanhoffman.HealthExporter`
**Platform:** iOS 26+, iPhone & iPad
**Version:** 1.0 (Build 1)

---

## Issues

### 1. ~~Unused CocoaPods Dependencies Linked in Binary~~ ✅ RESOLVED

CocoaPods integration removed entirely via `pod deintegrate`. Podfile, Podfile.lock, and Pods/ deleted. Project now builds from `HealthExporter.xcodeproj` directly. CI workflow updated.

---

### 2. ~~Unnecessary HealthKit Write Permission Requested~~ ✅ RESOLVED

Changed `toShare:` to an empty set in `requestAuthorization()`. Removed `NSHealthUpdateUsageDescription` from both Debug and Release build settings.

---

### 3. ~~Unused Background Delivery Entitlement~~ ✅ RESOLVED

Removed `com.apple.developer.healthkit.background-delivery` from `HealthExporter.entitlements`.

---

### 4. ~~A1C / Clinical Health Records Feature Untested~~ ✅ RESOLVED

A1C export has been verified working end-to-end on a physical device with Clinical Health Records enabled.

---

### 5. ~~Misleading `NSHealthUpdateUsageDescription` Text~~ ✅ RESOLVED

Removed along with write permission (see Issue #2). The key no longer exists in build settings.

---

### 6. No App Icon Dark/Tinted Variants (Severity: 3/10)

**Finding:** The `AppIcon.appiconset` only provides a light-mode icon (`unnamed-8.jpg`). The dark and tinted icon slots are empty. Starting in iOS 18, the system supports automatic dark-mode icon tinting, but having explicit dark/tinted variants is recommended.

**Why it matters:**
- This is unlikely to cause rejection, but Apple increasingly expects polished icon presentations. The icon file is a JPEG (`unnamed-8.jpg`), which is accepted but PNG is preferred for icon assets.
- Missing variants may result in a suboptimal appearance on devices using dark mode home screens.

**Recommendation:** Provide dark and tinted icon variants. Consider using PNG format for the icon. Rename the file to something descriptive (e.g., `AppIcon.png`).

---

### 7. In-App Icon Image Missing Retina Assets (Severity: 2/10)

**Finding:** `AppIconImage.imageset` (used in `LaunchView` to display the app icon on the splash screen) only provides a 1x resolution image. No 2x or 3x variants are included.

**Why it matters:**
- On Retina and Super Retina devices (all modern iPhones/iPads), the icon will appear blurry or pixelated on the launch screen.
- Unlikely to cause rejection but contributes to a less polished user experience.

**Recommendation:** Provide 2x and 3x image assets, or use a single high-resolution image with the `scale: "single"` option in the asset catalog.

---

### 8. ~~Dead Code~~ ✅ PARTIALLY RESOLVED

Removed `fetchBloodGlucoseData()` from `HealthKitManager` and unused `ExportError.healthKitNotAvailable` / `.invalidDateRange` cases. `AccentColor` colorset remains (cosmetic only).

---

### 9. ~~No Privacy Manifest Entries for Linked Frameworks~~ ✅ RESOLVED

No longer applicable — all third-party frameworks removed with CocoaPods (see Issue #1).

---

### 10. No Localization (Severity: 1/10)

**Finding:** All user-facing strings are hardcoded in English. There is no `Localizable.strings` file or localization infrastructure.

**Why it matters:**
- Not a rejection risk, but limits the app's audience and may be noted by reviewers in markets where localization is expected.
- Apple does not require localization for App Store approval.

**Recommendation:** Consider localizing strings for key markets in future updates. This is a low priority for initial submission.

---

## Summary Table

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Unused CocoaPods (GoogleSignIn, etc.) in binary | 9/10 | ✅ Resolved |
| 2 | Unnecessary HealthKit write permission | 7/10 | ✅ Resolved |
| 3 | Unused background delivery entitlement | 6/10 | ✅ Resolved |
| 4 | A1C feature untested end-to-end | 6/10 | ✅ Resolved (verified on device) |
| 5 | Misleading `NSHealthUpdateUsageDescription` | 5/10 | ✅ Resolved |
| 6 | No dark/tinted app icon variants | 3/10 | Open |
| 7 | Missing Retina image assets | 2/10 | Open |
| 8 | Dead code | 2/10 | ✅ Partially resolved |
| 9 | Missing privacy manifests for linked SDKs | 4/10 | ✅ Resolved (frameworks removed) |
| 10 | No localization | 1/10 | Open (not required) |

---

## Verdict

**All critical and moderate issues have been resolved.** The unused CocoaPods frameworks, unnecessary HealthKit write permission, background delivery entitlement, and misleading permission description have been removed. A1C has been verified working on a physical device. The remaining open items (#6, #7, #10) are cosmetic or low priority and are not rejection risks.

The app should be ready for App Store submission.
