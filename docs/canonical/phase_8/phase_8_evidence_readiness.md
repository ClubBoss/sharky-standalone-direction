# Phase 8 Evidence Readiness Audit - SSOT

## 1) Purpose
Ensure Phase 8 decisions remain rooted in observable evidence rather than speculation by listing available signals and identifying remaining blind spots before committing to a direction.

## 2) Available signals (current state)
- `session_start`/`session_start_timing_v1` (training_session_screen + session timing service) fires on every session launch, as documented in `first_5_minutes_flow.md` and enforced by `test/contracts/session_start_timing_e2e_contract_flutter_test.dart`.  
- `session_end` + `TrainingSessionEndReasonV1.completed` (TrainingSessionOutcomeTracker dispose) fires once per successful pack; `session_end` telemetry is consumed by `TrainingPackStatsService`, `SmartReviewService`, and `test/unit/training_session_outcome_tracker_test.dart`.  
- `session_abort` + `TrainingSessionEndReasonV1.aborted` (signalEnd) fires whenever the user exits; contract tests ensure it never disappears.  
- Adaptive timing/accuracy metrics emitted via `AdaptiveProgressionService.recordSession` in `training_session_screen.dart` (accuracy, elapsed time) supplement `session_end` with per-pair performance data.

## 3) What these signals can answer
- `session_start` counts prove entry volume and whether new content is discoverable.  
- `session_end` + completion reason track completion rate, enabling `TrainingPackStatsService` to report accuracy and EV deltas.  
- `session_abort` reveals exit friction points; the same tracker logs haptics so UX friction can be correlated.  
- Adaptive accuracy/time stats answer “how quickly and accurately do first-session players act”, meeting the Learning Philosophy’s decision-first loop.

## 4) Blind spots (no new telemetry)
- We still cannot measure long-term retention or post–first-session repeat without additional signals.  
- There is no dedicated visual or UX FFI signal for the difference between entry surfaces (cycling between pack lists), so we cannot yet prioritize Visual Lift moves solely from telemetry.  
- We cannot distinguish which specific drills inside a pack drive aborts without instrumentation beyond the current pack-level telemetry.

## 5) Decision readiness rule
Phase 8 may pick a direction only after: 1) the available signals above have been reviewed for trends; 2) the expansion plan and Phase 7 completion docs remain locked; and 3) either a user-metric trigger, stakeholder review, or targeted observation confirms which blind spot matters most. Any choice must cite this audit.

## 6) Non-actions
This audit forbids any new telemetry, UX changes, content additions, or infra updates; Phase 8 must work with the existing signals until a new SSOT is written.
