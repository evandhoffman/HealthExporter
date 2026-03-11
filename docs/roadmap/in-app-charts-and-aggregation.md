# In-App Charts and Aggregation

## Purpose

This document explores whether HealthExporter should remain a pure CSV export tool or expand to include lightweight in-app visualization and aggregation.

The core tension is straightforward:

- The current product is simple, privacy-friendly, and flexible because it exports raw data and lets users analyze it anywhere.
- That same model creates friction for common questions like "What is my 2-year weight trend?" or "How has my resting heart rate changed month over month?"

The goal is not to turn the app into a full analytics platform. The goal is to decide whether a small amount of in-app analysis would remove high-friction steps while preserving the product's CSV-first identity.

## Current product strength

The current approach has real advantages:

- Clear mental model: pick data, export CSV, use it anywhere
- No need to design opinionated dashboards for every metric
- Easy interoperability with Excel, Google Sheets, Numbers, and BI tools
- Lower UI complexity
- Lower risk of building shallow charts that do less than spreadsheet tools

This is a meaningful differentiator. Many apps either lock users into their own dashboard or make exporting difficult. HealthExporter currently does the opposite.

## Current product friction

The main weakness is that even simple trend questions require too many steps:

1. Select metrics and export a CSV
2. Save the file
3. Open it somewhere else
4. Build a chart or pivot table
5. Repeat when the user wants a different time window or aggregation

That workflow is acceptable for power users, but it is unnecessarily heavy for basic use cases such as:

- weight trend over 6 months or 2 years
- average fasting glucose by week
- resting heart rate trend over time
- monthly step totals
- A1C history with point-to-point deltas

## Product position

If this feature is pursued, the best framing is:

- HealthExporter remains export-first
- In-app charts are a convenience layer for common questions
- Raw export remains the source of truth and the primary interoperability feature

This avoids drifting into a general-purpose health dashboard app.

## Principles

### 1. Preserve CSV-first identity

Charts and summaries should complement export, not replace it.

Good product language:

- "Preview trends before export"
- "See a quick summary in the app, export raw data for deeper analysis"

Bad product language:

- anything implying the app is now a complete analytics destination

### 2. Start with derived views, not new storage

The app should avoid inventing a parallel analytics database unless scale forces it later.

Prefer:

- fetch selected samples
- compute lightweight aggregates in memory
- render the chart
- release data when the user leaves the screen

This matches the app's current privacy-first and memory-conscious design.

### 3. Focus on low-ambiguity questions

The first in-app charts should answer obvious questions with obvious rollups.

Good first examples:

- weight by week or month
- steps by day or month
- resting heart rate by week
- glucose by day, week, or month
- A1C over time

Avoid early charts that need too much interpretation:

- sleep-stage dashboards
- complex workout performance analysis
- route maps
- multi-metric wellness scores

### 4. Keep aggregation explicit

Users should always know what a chart is showing.

Examples:

- daily average
- weekly average
- monthly average
- daily total
- monthly total
- minimum / maximum where applicable

Ambiguous auto-aggregation will create confusion and trust problems.

## Candidate feature slices

### Slice 1: Metric detail charts

Add a simple detail view for each supported metric with:

- time range selector
- aggregation selector
- line chart or bar chart depending on metric
- headline summary values

Examples:

- Weight: line chart, weekly or monthly average
- Steps: bar chart, daily or monthly total
- Glucose: line chart, daily average or raw points
- A1C: sparse point chart over time

Why this is the strongest first step:

- tightly scoped
- maps cleanly to existing metric model
- useful without changing the export flow

### Slice 2: Summary cards and quick insights

For selected metrics, show lightweight summaries such as:

- latest value
- 30-day average
- change vs prior period
- highest / lowest in selected window

Examples:

- "Weight is down 4.2 lb over 90 days"
- "Average resting heart rate is 3 bpm lower than the previous 30 days"

This gives users immediate value even before they open a chart.

### Slice 3: Pre-export preview

Before export, show a preview of the selected data:

- approximate record count
- date span
- simple sparkline or small chart
- expected aggregation if the user chooses a summarized export later

This preserves the export-centric workflow while reducing blind exports.

### Slice 4: Aggregated export options

Once charts exist, the next logical step is optionally exporting summarized CSVs in addition to raw CSVs.

Examples:

- raw rows
- daily summary
- weekly summary
- monthly summary

This is especially useful for very large datasets such as heart rate or active energy.

Important constraint:

- raw export should remain available and probably remain the default

### Slice 5: Multi-metric comparison

Later, add limited side-by-side trend comparison for compatible metrics.

Examples:

- weight and resting heart rate
- glucose and A1C
- steps and active energy

This should be later because comparison UIs get complicated quickly.

## Recommended scope boundaries

To keep this feature from sprawling, explicitly avoid the following in the first phase:

- custom dashboard builders
- arbitrary spreadsheet-style formulas
- route maps
- ECG waveform viewers
- PDF report generation
- AI-generated interpretations
- cross-metric composite scoring

Those are separate products or much later features.

## UX direction

The cleanest product shape is probably:

1. User selects a supported metric
2. User can choose either `View Trend` or `Export CSV`
3. `View Trend` opens a simple metric detail screen
4. Screen shows:
   - range selector
   - aggregation selector
   - chart
   - summary stats
   - optional `Export Raw CSV` action

This keeps charting subordinate to export rather than replacing the current flow.

Another viable option is a dedicated `Trends` tab, but that risks shifting the product identity from exporter to dashboard.

## Aggregation model

The app should define simple per-metric aggregation rules.

Examples:

- Weight (`HKQuantityTypeIdentifierBodyMass`): average by week/month
- Steps (`HKQuantityTypeIdentifierStepCount`): total by day/week/month
- Blood Glucose (`HKQuantityTypeIdentifierBloodGlucose`): average by day/week/month, optionally raw points
- Hemoglobin A1C (`HKClinicalTypeIdentifierLabResultRecord` with LOINC `4548-4`): raw points only, maybe no rollup needed
- Resting Heart Rate (`HKQuantityTypeIdentifierRestingHeartRate`): average by week/month
- Active Energy Burned (`HKQuantityTypeIdentifierActiveEnergyBurned`): total by day/week/month

This should be metric-specific rather than one aggregation model applied blindly to everything.

## Benefits

If done well, this feature could:

- remove the most tedious part of the current workflow
- make the app more useful for everyday checking, not just export events
- improve retention by giving users a reason to open the app more often
- still preserve the core value of raw CSV export

## Risks

### Product risk

The biggest risk is identity drift. If the app becomes "a basic dashboard plus a basic exporter," it may be worse at both.

### UX risk

Weak charts or unclear aggregation rules can reduce trust. Health data is sensitive, and users need to understand exactly what is being shown.

### Engineering risk

High-frequency metrics can be expensive to fetch, aggregate, and render on-device. Heart rate and cycling metrics are especially likely to surface memory and performance issues.

### Scope risk

Once charts exist, users may immediately expect:

- comparisons
- annotations
- moving averages
- goals
- alerts
- derived metrics

That expansion needs to be resisted unless the product deliberately changes direction.

## Suggested rollout

### Phase 1

- Add trend view for existing exported metrics only
- Support weight, steps, glucose, and A1C
- Add simple range selector and chart
- Add clear aggregation labels

### Phase 2

- Add summary stats
- Add trend view for near-term roadmap metrics like resting heart rate and active energy
- Add optional aggregated export modes

### Phase 3

- Evaluate whether the feature is increasing usefulness without diluting the export-first model
- Only then consider multi-metric comparison or a dedicated trends area

## Recommendation

This is worth exploring, but only if it stays intentionally small.

The best version of this idea is not "build analytics into the app." The best version is:

- make common longitudinal questions easy to answer inside the app
- keep raw CSV export central
- avoid becoming a generic health dashboard

## Open product question

Should HealthExporter add a lightweight `View Trend` experience for a small set of metrics, or should it remain strictly export-only and rely on better downstream templates or documentation for spreadsheet-based analysis?
