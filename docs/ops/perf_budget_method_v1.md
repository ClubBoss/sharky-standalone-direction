## Performance Budget Method V1

This document captures the deterministic approach for measuring the Sharky Poker Master Plan 5.0 performance budgets for Cold Start and Session Start. Follow it before every release candidate.

### Definitions

1. **Cold Start** — time from process launch until the very first fully painted frame of `UiV2ProgressMapScreenV2` (the home/progression map) after the Flutter engine reports a stable frame. Measure on a warm app install with no cached snapshots.
2. **Session Start** — time from the user tapping “Start” (or the session entry CTA) to the first interactive frame rendered by `TrainingSessionScreen`. This includes any navigation animations but excludes loading overlays that run beyond the first interactive frame.

### Measurement Procedure

1. Build the app in **profile** or **release** mode on a target device (iPhone 12 mini / Pixel 6a or equivalent mid-range hardware).
2. Repeat each measurement **5 full runs** per device. For Cold Start, restart the app between runs. For Session Start, complete onboarding flow (if needed), then tap Start once per run.
3. Record the **p50** and **p90** durations for each measurement (per run) using a deterministic telemetry capture or manual timer.
4. Aggregate the run data and report the p50/p90 numbers per metric. Passing if the upper target is met; otherwise fail the gate.

### Instrumentation
`TrainingSessionLauncher.launch` starts `SessionStartTimingServiceV1` right before it navigates to `TrainingSessionScreen`, and the screen fires the `session_start_timing_v1` telemetry event the first time the frame callback runs. The emitted event carries `elapsed_ms`, which drives the per-run p50/p90 numbers mentioned above.

### Thresholds

| Metric         | Target (p90)        |
|----------------|--------------------|
| Cold Start     | < 2.0 seconds      |
| Session Start  | < 0.5 seconds      |

If either p90 exceeds the target, investigate lazy-loading options, splash optimization, or deferring non-critical work before re-measuring.

### Fallback Plan

Doc the refactor you would apply next if a budget fails (e.g., “Lazy-load onboarding avatars, preload session assets, and post-frame schedule heavy paints”). Capture any chosen mitigations in the release audit log before rerunning the budget.
