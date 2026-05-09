# R77 Scenario Truth Foundation v1

## Milestone purpose/scope recap
- Establish one practical World1-only scenario truth contract foundation.
- Separate validation-time truth from temporary runtime safety normalization.
- Prevent future bug-fix drift toward non-authoritative branches.
- Scope: foundation + boundaries + validator/normalizer plan + migration path.
- Out of scope: broad runtime rewrite, broad content rewrite, Worlds2-10 migration, archive/delete work.

## STEP A — Scenario Truth Foundation v1 (World1 pilot)

### Canonical scenario contract (minimal, practical)
Required fields for covered World1 pilot families:
- `world_id`: integer; must be `1` for R77 pilot records.
- `module_id`: pack/module id (for example `world1_act0_table_literacy`, `world1_spine_campaign_v1`).
- `session_id`: deterministic session key when applicable.
- `step_id`: deterministic per-scenario step key.
- `scenario_kind`: one of `seat_quiz`, `action_decision`, `hand_loop_mismatch`, `result_handoff`.
- `learning_objective`: short learner objective for the step/family.
- `state_snapshot_v1`: normalized action state inputs (at minimum `street`, `pot`, `current_bet`, `to_call`, `acting_seat`, `allowed_actions`).
- `visible_affordances_v1`: ordered visible action affordance list for UI comparison.
- `expected_action_family_v1`: normalized expected action family (`fold|check|call|bet|raise`).
- `acceptable_actions_v1`: optional deterministic list of legal-but-secondary actions (sorted, deduped).
- `why_v1`: single-line factual explanation text.
- `feedback_correct_v1`: deterministic success line.
- `feedback_incorrect_v1`: deterministic incorrect line.
- `error_class_v1`: deterministic error class for mismatch taxonomy.
- `progression_tags_v1`: bounded tags (for example `intro`, `spine`, `review_due_candidate`).
- `required_focus_label_v1`: required contextual focus/route reason label for covered training flows.

### Practical invariants
- `expected_action_family_v1` must be legal for `state_snapshot_v1`.
- `why_v1` must semantically match `expected_action_family_v1` family.
- `visible_affordances_v1` must be legal for state and consistent with runtime action chips.
- Covered pilot records must include `required_focus_label_v1`; no dry/no-context records.

## STEP B — Ownership boundaries and anti-regression rules

### Truth ownership split
- Scenario contract owns:
  - expected/acceptable/why/feedback/error-class truth and required focus context.
- Runtime owns (temporary migration-era safety):
  - legality normalization and contradiction clamps when content metadata drifts.
- Runtime/UI must not be long-term primary authority for:
  - pedagogical expected-action truth,
  - why-family semantics,
  - focus/context intent.

### Must preserve
- Deterministic Start Now route resolution via map and `ProgressService`.
- Authoritative World1 runner phase ownership in `world1_foundations_microtask_runner_screen.dart`.
- Result CTA semantics in `session_result_screen.dart`.
- Existing green contracts in map/runner/result surfaces.

### Must not regress
- Facing-bet legality semantics (`CHECK`/generic `BET` suppression families).
- Expected/why coherence families fixed in R75 and R76.
- Act0-first first-user launch and progression return continuity.
- Existing prompt-leak and contradictory feedback detection already in validators.

### Temporary runtime guards allowed during migration
- `world1SpineExpectedActionKindV1(...)` legality normalization.
- `world1SpineMismatchExpectedActionKindV1(...)` mismatch-branch normalization.
- Action-chip facing-bet semantics guard in `_buildCampaignActionChips(...)`.

### Future source of truth after migration
- World1 pilot scenario contract + validator output become primary truth.
- Runtime guards remain as defensive fallback, not truth-defining policy.

## STEP F — Validator/Normalizer plan (bounded)

### Validation-time truth responsibilities (pilot)
- Illegal expected-action detection against normalized state snapshot.
- Expected/why coherence checks.
- Acceptable/legal coherence checks.
- Prompt leak detection (including `Focus: <action>` family).
- Contradictory success feedback detection (`worse than our recommended play`).
- Required focus field presence for covered pilot families.
- Pilot completeness checks (required fields populated for included families).

### Runtime migration-era normalization responsibilities
- Clamp illegal explicit expected action families to legal normalized family.
- Keep mismatch branch expected-family aligned with normalized legality.
- Preserve deterministic behavior outside selected family.

### Suggested implementation order (R78+)
1. Add World1 pilot schema validator entrypoint for included families only.
2. Add legality + expected/why coherence checks using normalized state snapshot.
3. Add required focus-label presence check for included families.
4. Keep existing runtime safety guards until pilot validation proves clean.

## STEP H — Migration path (World1 only)
- Phase A: foundation complete (this milestone).
- Phase B: migrate highest-EV World1 families to scenario-truth contract.
- Phase C: run fresh-install validation route against migrated pilot families.
- Phase D: only after clean World1 pilot, consider bounded rollout strategy.

### Explicit out-of-scope statements
- Worlds2-10 migration: out of scope now.
- Broad runtime rewrite: out of scope now.
- Broad content rewrite: out of scope now.
- Archive/delete execution: out of scope now.
- No value discarded before extraction review.
