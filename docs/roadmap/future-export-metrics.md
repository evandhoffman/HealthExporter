# Future Export Metrics

## Purpose

This document captures candidate Apple Health export metrics for future enhancement work.

The current app exports:

- Weight
- Steps
- Blood Glucose
- Hemoglobin A1C

The list below is based on a review of a full Apple Health export dump from a real iPhone backup (`~/Dropbox/apple_health_export`). The goal is to prioritize exports that are both useful to users and compatible with the app's CSV-first workflow.

## Data snapshot from the sampled export

Notable counts from the reviewed dump:

- Active Energy Burned: 1,797,912 records
- Heart Rate: 1,041,445 records
- Distance Walking/Running: 538,972 records
- Step Count: 496,510 records
- Blood Glucose: 262,751 records
- Apple Exercise Time: 155,343 records
- Apple Stand Time: 124,718 records
- Sleep Analysis: 4,327 records
- Heart Rate Variability (SDNN): 14,509 records
- Oxygen Saturation: 9,981 records
- Respiratory Rate: 3,942 records
- Resting Heart Rate: 2,517 records
- Walking Heart Rate Average: 2,461 records
- Body Mass: 2,164 records
- Body Fat Percentage: 993 records
- Lean Body Mass: 722 records
- VO2 Max: 548 records
- Workouts: 3,638 records

The dump also contains:

- Clinical records, including document references, conditions, allergies, and diagnostic reports
- Electrocardiogram CSV files
- Workout route GPX files

## Candidate metrics by theme

### Cardio and recovery

Strong near-term candidates with broad user appeal:

- Heart Rate
- Resting Heart Rate
- Walking Heart Rate Average
- Heart Rate Variability (SDNN)
- Respiratory Rate
- Oxygen Saturation
- VO2 Max
- Heart Rate Recovery

Why this theme matters:

- High user value for fitness, recovery, illness tracking, and trend analysis
- Clean fit with the current timestamped-sample CSV model
- Present in meaningful volume in the sampled export

### Sleep and overnight health

- Sleep Analysis
- Respiratory Rate during sleep
- Oxygen Saturation during sleep

Why:

- Sleep is a widely understandable export category
- Basic sleep-session export is valuable even without complex sleep-stage analysis
- Pairs naturally with cardio and recovery metrics

### Activity rings and movement

- Active Energy Burned
- Basal Energy Burned
- Apple Exercise Time
- Apple Stand Time
- Apple Stand Hour
- Distance Walking/Running
- Flights Climbed
- Time in Daylight

Why:

- These are core Apple Watch metrics users already recognize
- They provide useful longitudinal analysis outside the Apple Health UI
- They complement steps rather than duplicating it

### Body composition

- Body Mass Index
- Body Fat Percentage
- Lean Body Mass

Why:

- Good fit with the current weight and glucose audience
- Lower implementation risk than more specialized performance metrics
- Useful in spreadsheets and BI tools

### Mobility and gait

- Walking Speed
- Walking Step Length
- Walking Asymmetry Percentage
- Walking Double Support Percentage
- Apple Walking Steadiness
- Six-Minute Walk Test Distance
- Stair Ascent Speed
- Stair Descent Speed

Why:

- Valuable for aging, rehab, fall-risk, and general mobility tracking
- Distinctive HealthKit metrics that are not easy to extract elsewhere
- Best treated as a dedicated theme in the product

### Workout summaries

Rather than only exporting raw samples, support workout-level exports such as:

- Workout type
- Start time
- End time
- Duration
- Total energy burned
- Total distance
- Source

Possible follow-ons:

- Workout route linkage
- Swimming workout summaries
- Per-workout average heart rate or pace if derivable cleanly

Why:

- The sampled export contains 3,638 workouts
- Workout summaries are easier to use than very high-frequency workout-adjacent sample streams
- This is a natural extension of the CSV export model

### Cycling and training performance

- Cycling Speed
- Cycling Cadence
- Cycling Power
- Cycling Functional Threshold Power
- Distance Cycling
- Physical Effort

Why:

- Clearly present in the sampled export
- Relevant for advanced Apple Watch and bike computer users
- Better framed as an advanced/performance theme because record volume is high and aggregation may need more design

### Hearing and environmental exposure

- Headphone Audio Exposure
- Environmental Audio Exposure
- Audio Exposure Events
- Environmental Sound Reduction

Why:

- Distinctive Apple ecosystem data
- Useful for hearing-health and lifestyle analysis
- Differentiates the app from more basic Health exporters

### Nutrition

Potentially useful, but likely not first-wave:

- Dietary Energy Consumed
- Carbohydrates
- Protein
- Total Fat
- Fiber
- Sugar
- Sodium
- Potassium
- Cholesterol

Why later:

- Present in the sampled dump, but at much lower frequency
- Nutrition tends to expand into a much broader feature surface once started
- Better handled as an intentional theme than an isolated metric addition

### Clinical records and file-backed exports

Beyond A1C, the sampled export includes:

- Diagnostic reports
- Conditions
- Allergies
- Document references
- ECG files
- Workout route files

Potential future directions:

- Generic lab-result export from clinical records
- Diagnostic report metadata export
- Condition and allergy metadata export
- ECG discovery/export
- Workout route export

Why this is later-stage:

- These are not simple quantity samples
- They likely need a separate export model and file-handling workflow
- Still worth tracking because they would materially broaden the product

## Suggested prioritization

### Near-term

- Heart Rate
- Resting Heart Rate
- Heart Rate Variability (SDNN)
- Sleep Analysis
- Active Energy Burned
- Apple Exercise Time
- Distance Walking/Running
- Oxygen Saturation
- Respiratory Rate
- Workout summaries
- Body Fat Percentage

### Mid-term

- Walking Heart Rate Average
- VO2 Max
- Flights Climbed
- Apple Stand Time and Apple Stand Hour
- Body Mass Index
- Lean Body Mass
- Mobility and gait metrics
- Hearing and environmental exposure metrics

### Later

- Cycling and training performance metrics
- Nutrition
- Generic clinical-record export
- ECG and workout-route export workflows

## Implementation notes

- Keep new metric routing centralized in `HealthMetricConfig.swift`.
- Add dedicated unit handling where needed:
  - heart rate: count/min
  - oxygen saturation: percent
  - energy: kcal
  - distance: metric or imperial
- Workouts, ECGs, routes, and clinical records should not be forced into the same path as simple `HKQuantitySample` exports without design review.
- High-frequency metrics like heart rate, cycling speed, and cadence need extra memory scrutiny and may need stricter date-range controls.

## Open product question

Should the app stay focused on flat CSV export of point-in-time health metrics, or should it also expand into richer exports for workouts, ECGs, routes, and clinical documents?
