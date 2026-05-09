# Phase 8.1 Observation Dashboard Spec

**Purpose**: Tie each Phase 8.1 observation signal to the existing telemetry fields listed in `phase_8_evidence_readiness.md` and show how the insights surface in current analytics stacks. This dashboard is read-only: it watches telemetry already being emitted and raises alerts when thresholds (as defined in `OBSERVATION_WINDOW_8_1.md`) are crossed. No new telemetry, alerts, or UX changes are introduced here.

## Signal 1 — Session start volume
- Source event(s): `session_start` / `session_start_timing_v1` emitted by `TrainingSessionLauncher` (see `training_session_screen.dart`) and recorded once per pack launch.
- Aggregation windows: 15-minute rolling average (short-term sensitivity) plus daily and 7-day trailing sums for baseline comparison (matches OBSERVATION_WINDOW_8_1 monitoring cadence).
- Analytics view(s): training volume dashboards that back `TrainingPackStatsService` heatmaps (per `phase_8_evidence_readiness.md`).
- Breakdowns:
  - Overall (all difficulties)
  - Difficulty tiers: levels 1–20, 21–40 grouped by pack metadata `difficultyLevel` · difficulty tier is inferred from XP level ranges emitted by `AdaptiveTrainingService`.
- Alert threshold (per OBSERVATION_WINDOW_8_1): 12% drop vs 7-day rolling average sustained for two consecutive 15-minute slices.
- Safe tuning scope: Observe how home/dashboard recommendation rotations correlate with start dips before touching personalization logic.
- Blind spots: Breakdown cannot distinguish between home entry surface vs direct training links; this dashboard only eyeballs aggregated starts.

## Signal 2 — Session completion rate
- Source event(s): `session_end` with `TrainingSessionEndReasonV1.completed` emitted by `TrainingSessionOutcomeTracker` (consumed by `TrainingPackStatsService`).
- Aggregation windows: 30-minute completion ratio (completions/starts) and 24-hour summary.
- Analytics view(s): accuracy/EV dashboards under `TrainingPackStatsService` and `SmartReviewService`.
- Breakdowns:
  - Overall
  - Difficulty tiers (1–20, 21–40)
- Alert threshold (per OBSERVATION_WINDOW_8_1): completion rate < 65% for two successive 30-minute windows.
- Safe tuning scope: Tune adaptive pack weighting only after completion dips stabilize.
- Blind spots: No ability to decompose by entry surface or drill within a pack.

## Signal 3 — Session abort rate
- Source event(s): `session_abort` emitted when `TrainingSessionService.signalEnd` reports `TrainingSessionEndReasonV1.aborted`.
- Aggregation windows: 15-minute rolling abort rate and daily rate bounded to start volume.
- Analytics view(s): abort analytics from `TrainingPackStatsService` and the `session_end` contract tests referenced in `phase_8_evidence_readiness.md`.
- Breakdowns:
  - Overall
  - Difficulty tiers 1–20 and 21–40
- Alert threshold (per OBSERVATION_WINDOW_8_1): abort rate > 15% for any 15-minute window while starts exceed 30/min.
- Safe tuning scope: Evaluate whether abort spikes follow recommendation pushes before adjusting surfaces.
- Blind spots: Cannot tell which pack or UI element triggered the abort; only pack-level abort counts are emitted.

## Signal 4 — Adaptive accuracy/time metrics (AdaptiveProgressionService)
- Source event(s): `AdaptiveProgressionService.recordSession` telemetry and `AdaptiveProgressionService.feedbackNotifier` (fields: accuracy, `sessionPi`, rolling PI, time spent, `recommendation`).
- Aggregation windows: Rolling window of last 5 sessions (per service buffer) plus 24-hour averages for accuracy and PI.
- Analytics view(s): adaptive difficulty dashboard and simulation HUD overlays (`ui_v2_hud_overlay.dart` uses these metrics per `phase_8_evidence_readiness.md`).
- Breakdowns:
  - Overall accuracy/time
  - Difficulty tiers (1–20 vs 21–40) derived from pack metadata/difficultyLevel.
  - Tier-specific rolling PI recommended adjustments (+1/0/−1) recorded via `adaptiveDifficultyUpdated` telemetry.
- Alert threshold (per OBSERVATION_WINDOW_8_1): accuracy drop of >6 percentage points or PI delta below 0.001 for two consecutive training sessions.
- Safe tuning scope: Adjust tuning thresholds when a stable trend is observed; does not require new metrics.
- Blind spots: No per-spot or per-action latency; only aggregated accuracy & PI are available.

## Dashboard guardrails
1. Dashboard consumes only the signals enumerated here and in `phase_8_evidence_readiness.md`.
2. Alert thresholds mirror `OBSERVATION_WINDOW_8_1.md`. Any future tuning must adjust that document first.
3. Difficulty tiers reuse existing difficultyLevel metadata; no new tags or context is introduced.
