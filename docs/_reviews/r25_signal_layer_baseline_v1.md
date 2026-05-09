# R25 Signal-Layer Baseline v1

## 1) Scope and evidence sources
This baseline selects exactly one additional deterministic signal layer for personalization refinement on top of R24.
Constraints held: existing data/contracts only, no schema/dependency changes, no scoring-engine expansion.

Evidence sources:
- `docs/ROADMAP_FINAL_100_SSOT.md` (R25 scope/stop rules)
- `docs/_reviews/r24_profile_ev_baseline_v1.md`
- `docs/_reviews/r24_personalization_closeout_audit_v1.md`
- `docs/_reviews/r24_next_execution_focus_v1.md`
- Runtime:
  - `lib/services/progress_service.dart`
  - `lib/services/learning_stats_v1_service.dart`
  - `lib/personalization/phase1_error_to_focus_map_v1.dart`
  - `lib/ui_v2/screens/viral_proof_v1.dart`
- Determinism contracts:
  - `test/services/review_queue_v1_test.dart`
  - `test/guards/world1_viral_proof_contract_test.dart`
  - `test/ui_v2/session_result_screen_contract_test.dart`

## 2) Candidate next signal layers

### Candidate A: Focus-review-due layer (lesson focus + due timestamp)
- Signal inputs: `getLessonFocusLabel()` + `isFocusReviewDue(focusLabel)`.
- Current state: persisted and deterministic, used in result recommendation surfaces, not used in `ProgressService.getNextSpinePackToRunV1()` adaptive followup selection.
- EV: high; closes gap between persisted focus debt and next followup routing.
- Surface size: small (one precedence insertion in existing routing path).
- Classification: include now.

### Candidate B: Skill-tags layer from seeded pack tags
- Signal inputs: `seedSkillTagsForPackFromRulesV1(...)` + `getSkillTagsForPackV1(...)`.
- Current state: available but not part of adaptive followup selection stack.
- EV: medium; requires additional mapping policy and broader tie-break handling.
- Surface size: medium.
- Classification: maybe later.

### Candidate C: World mastery level layer
- Signal inputs: `setWorldMasteryForPackV1(...)` outputs from session outcomes.
- Current state: persisted but primarily progression/feedback oriented, not a focused weak-area selector.
- EV: medium-low for immediate personalization refinement.
- Surface size: medium.
- Classification: maybe later.

### Candidate D: Queue-depth/recency weighting
- Signal inputs: review queue depth/recency by pack.
- Current state: review queue already enforced as higher-priority routing behavior in existing flows.
- EV: low incremental value for R25; risks turning into scoring-engine growth.
- Classification: exclude from R25.

## 3) Inclusion/exclusion decisions
- Include now: Candidate A (focus-review-due layer).
- Maybe later: Candidates B, C.
- Exclude from R25: Candidate D and any weighted multi-signal scoring.

## 4) Selected single signal layer for R25 P0.2
Selected layer: **focus-review-due signal** using existing persisted lesson focus and due timestamp.

Why this is best for R25:
- highest user-EV with smallest deterministic surface area,
- already persisted and contract-adjacent,
- directly aligns with R24 transition note: one additional rule-based signal layer only.

## 5) Deterministic precedence / tie-break / fallback policy
Current R24 stack:
1) LearningStats winner (`toCall` vs `expectedAction`)
2) tie/none -> checkpoint top-error fallback
3) no mapping -> band fallback

R25 insertion policy (single added layer):
1) LearningStats winner (`toCall` vs `expectedAction`)
2) tie/none -> checkpoint top-error fallback
3) if still unresolved and `focusReviewDue == true` with non-empty `lessonFocusLabel`, map lesson focus via existing focus mapping to adaptive focus
4) if mapping fails, preserve existing band fallback behavior unchanged

Deterministic tie-break rules:
- identical input state must yield identical chosen pack id,
- if both checkpoint and focus-review-due are available in tie/none case, checkpoint fallback wins (existing higher priority preserved),
- if focus label maps to multiple possibilities, use existing fixed mapping only (no ranking).

## 6) Recommended bounded implementation slice
R25 P0.2 bounded slice:
- Add a single focus-review-due fallback branch in `ProgressService` adaptive routing resolution after checkpoint fallback and before band fallback.
- Reuse existing helpers/storage (`getLessonFocusLabel`, `isFocusReviewDue`, existing focus mapping utilities).
- Do not modify UI surfaces, schema, content, or scoring strategy.

## 7) Explicit defer list (non-included personalization ideas)
Deferred beyond R25:
- weighted/multi-factor personalization scoring,
- profile dashboards and explanatory personalization UI,
- personalization-driven content scaling,
- telemetry/schema redesign for personalization,
- ML/recommendation systems.

## 8) Anti-drift note
R25 remains a one-layer deterministic refinement milestone.
Do not pull content scaling, UX cohesion, expansion tracks, architecture redesign, or ML scope into this increment.
