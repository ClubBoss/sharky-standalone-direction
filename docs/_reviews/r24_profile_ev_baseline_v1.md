# R24 Profile EV Baseline v1

## 1) Scope and Evidence Sources
This baseline defines the first bounded personalization layer using only existing deterministic signals and contracts.
No schema changes, no ML, and no feature-family expansion are included.

Evidence sources:
- `docs/ROADMAP_FINAL_100_SSOT.md` (R24 scope/stop rules)
- `docs/_reviews/r23_next_execution_focus_v1.md`
- Runtime:
  - `lib/services/progress_service.dart`
  - `lib/services/learning_stats_v1_service.dart`
  - `lib/services/today_router_v1.dart`
  - `lib/personalization/phase1_error_to_focus_map_v1.dart`
  - `lib/ui_v2/screens/viral_proof_v1.dart`
- Determinism/ordering tests:
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - `test/ui_v2/session_result_screen_contract_test.dart`
  - `test/guards/world1_viral_proof_contract_test.dart`

## 2) Existing Usable Signals Inventory (No Schema Change)

### A) Progress / followup routing signals
- `LearningStatsV1Service.getExpectedActionMismatchErrorCount()`
- `LearningStatsV1Service.getToCallLegalityMismatchErrorCount()`
- Used now by `ProgressService._resolveAdaptiveRoutingFocusV1()`.
- Current adaptive output: `AdaptiveRoutingFocusV1.toCall` or `AdaptiveRoutingFocusV1.expectedAction` (or null).
- Classification: include now.

### B) Checkpoint seed / error-class signals
- `ProgressService.recordSessionForCheckpointV1(...)` persists bounded history and class counts.
- `ProgressService.getCheckpointProgressStateV1()` exposes:
  - `checkpointPending`
  - `topErrorClasses` (top-3, deterministic rank by count desc then key asc).
- `ProgressService.getCheckpointSeedForPackV1(...)` / set seed exist and are contract-covered.
- Classification: include now.

### C) Review/followup context signals
- `ProgressService.getReviewQueueForPackV1(...)`, `hasReviewQueueForPackV1(...)`.
- `TodayRouterV1.resolveDeterministic(...)` with deterministic ladder priority (`gauntlet -> leaks -> practice`) and tests.
- `leaks_queue_v1` deterministic ordering/cap exists.
- Classification: include now (as routing context gate, not as broad scoring model).

### D) Focus-label signals
- `ProgressService.getLessonFocusLabel()` + `isFocusReviewDue(...)` + `scheduleFocusReviewIn24h(...)`.
- `phase1_error_to_focus_map_v1.dart` maps representative error signals to focus labels.
- `recommendedModuleIdForFocus(...)` in `viral_proof_v1.dart` already provides deterministic rule-based mapping.
- Classification: include now.

### E) Candidate but defer for first slice
- Mastery/rank visuals and cohort promotion state in map layer.
- Bankroll/backer/economy states.
- Broad telemetry event payloads not already consumed by deterministic routing logic.
- Classification: maybe later.

### F) Explicitly exclude from R24
- Any new schema keys or telemetry schema redesign.
- ML ranking/recommendation systems.
- Content scaling, UX cohesion programs, expansion/gamification/localization.
- Classification: exclude from R24.

## 3) Candidate Rule Set for Weak-Area Prioritization

Candidate rules (bounded, rule-based):
1. Review-first gate:
- If review queue exists for target pack OR focus review is due -> prioritize review-target module first.

2. Weak-area focus selection:
- Else derive focus from existing deterministic signals in order:
  - adaptive routing focus (`toCall` vs `expectedAction`) from LearningStats mismatch counters,
  - then checkpoint `topErrorClasses[0]` mapped via phase1 error->focus map,
  - then persisted lesson focus label,
  - then fallback to existing calibration-band followup.

3. Followup mapping:
- Map selected focus to existing followup/module IDs only (no new content roots).

Signal/rule classification:
- include now: rules 1-3 above.
- maybe later: weighted multi-signal scoring beyond strict precedence.
- exclude now: probabilistic/ML weighting.

## 4) Deterministic Precedence and Tie-Break Policy
Deterministic stack for identical inputs:
1) `checkpointPending == true` and checkpoint path active -> checkpoint remains highest priority (existing behavior).
2) reviewDue / reviewQueue present -> review-first module path.
3) LearningStats adaptive focus:
- if toCallMismatch > expectedActionMismatch -> `toCall`
- if expectedActionMismatch > toCallMismatch -> `expectedAction`
- if equal -> no decision at this layer.
4) Checkpoint top error classes:
- use first ranked class from `topErrorClasses` (already deterministic by count desc, key asc).
5) Lesson focus label fallback.
6) Existing fallback followup by calibration band.
7) Final tie-break:
- lexical sort by candidate moduleId/packId if two candidates remain equivalent.

## 5) Recommended Single Bounded R24 Implementation Slice (P0.2)
Exactly one slice:
- **Integrate checkpoint top-error focus into existing adaptive followup selection as a deterministic fallback layer, without changing schemas.**

Bounded target details:
- Surface: `ProgressService` next-pack selection path.
- Behavior: when LearningStats focus tie/none, use checkpoint top error class -> focus label -> existing followup/module mapping.
- Constraints:
  - use only existing persisted signals/functions,
  - no new content IDs,
  - no runtime surfaces expansion,
  - deterministic contracts required for identical state.

Why this slice:
- High EV personalization uplift with minimal surface area.
- Reuses already-tested deterministic seed/error-class infrastructure.
- Keeps scope inside rule-based adaptation.

## 6) Explicit Defer List (Non-Included Personalization Ideas)
Deferred after first slice:
- multi-objective personalization scorecards,
- dynamic UI profile dashboards,
- personalization-driven content authoring/scaling,
- store/monetization-aware personalization,
- any ML or remote-model pipeline.

## 7) Anti-Drift Note
R24 starts with one bounded rule-based adaptation slice only.
Do not pull in UX cohesion, content scaling, expansion, or architecture redesign before this slice is shipped with deterministic contracts.
