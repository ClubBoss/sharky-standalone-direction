# W6 Range Bucket Source Repair Plan v1

Status: REVIEW ARTIFACT.
Branch: `codex/w6-range-bucket-source-repair-plan-v1`.
Baseline: `a7da9de6` (`w6_range_correctness_posture_blocked_by_source_gap`).
Verdict: `w6_range_bucket_source_repair_ready_pilot_created`.

## 1. Verdict

W6 `w6.s01` source was minimally repaired into a safe first canonical family:
`range_bucket_by_board_fit`.

The wave creates one canonical pilot fixture:

- `test/fixtures/content_factory_mvp/w6_range_bucket_by_board_fit_canonical_pilot_v1.json`

The fixture is narrow, source-owned, and route-ready only when evaluated without
W6 bridge evidence. Broad W6 remains mixed and bridge-limited.

## 2. Accepted context

Accepted state before this wave:

- W1: technical 8.5 candidate.
- W2-W5: bounded technical 8.0 candidates.
- W6: Range Thinking, bridge-limited, score `5.3`.
- W1-W12 readiness: `7.7`.
- Overall top-1 readiness: `6.5`.

Accepted W6 posture:

- First safe family: `range_bucket_by_board_fit`.
- Source target: `w6.s01` Range Buckets Intro only.
- Exclude blockers, polarization, opponent range construction, frequencies,
  combo counting, solver/GTO language, action prescription, W7-W12, and
  W13-W36.

## 3. Source-gap diagnosis

Before this wave, `w6.s01` had zero safe board-fit classification tasks.

The six existing `range_bucket_classifier_v1` drills were not usable as
canonical classification evidence because they pre-gave the bucket and asked
the learner to choose an action:

- `d.classify_strong_raise.json`
- `d.classify_strong_call_control.json`
- `d.classify_medium_call_control.json`
- `d.classify_weak_fold_pressure.json`
- `d.classify_missed_fold.json`
- `d.classify_missed_fold_recheck.json`

Action-selection-only drills remain excluded from the canonical family:

- `d.choose_call_range.json`
- `d.choose_raise_range.json`
- `d.choose_fold_trap.json`

The blocker-risk drill remains excluded:

- `d.tap_hole_left_as.json`

The existing source intent did support minimal repair because `session.md`
already defined the learner job as choosing the broad range bucket, and the six
classifier files already owned the strong, medium, weak, and missed bucket
vocabulary.

## 4. Minimal source repair

The six classifier files were repaired from action choice into board-fit bucket
classification.

Repaired task shape:

- Given a hand category and board-fit cue.
- Classify the bucket as `strong`, `medium`, `weak`, or `missed`.
- Feedback explains made hand, draw, missed relation, and board fit.
- No bet/call/fold/raise decision is requested.

Source package cleanup:

- `session.md` now includes `missed` and names board-fit classification.
- `notes.md` states classifier reps do not ask for betting actions.
- `drills/index.md` describes the six repaired classifier reps as bucket tasks.

## 5. Canonical pilot fixture

Created:

- `test/fixtures/content_factory_mvp/w6_range_bucket_by_board_fit_canonical_pilot_v1.json`

Fixture summary:

- 6 coverage-countable tasks.
- `world_id`: `world_6`.
- `route_world_id`: `world_6`.
- `display_world_title`: `Range Thinking`.
- `concept_family_id`: `range_bucket_by_board_fit`.
- `same_signal_group_id`: `w6.range_thinking.range_bucket_by_board_fit`.
- `repair_focus_id`: `bucket_before_action`.
- `safe_claim_status`: `canonical_pilot`.
- `launch_coverage_claimed`: `false`.

Transfer surfaces:

- `made_hand_clean_fit_v1`
- `made_hand_showdown_fit_v1`
- `light_pair_fit_v1`
- `missed_no_clear_draw_v1`

## 6. Correctness posture

Allowed claim:

- W6 has one narrow canonical pilot for beginner board-fit range-bucket
  recognition.

Forbidden claim:

- W6 is not 8.0, 9.0, launch-ready, Human-QA-validated, or broad canonical.
- The pilot does not teach opponent range construction, blockers,
  polarization, solver/GTO reasoning, frequencies, combo counting, stack depth,
  tournament pressure, ICM, exploit adjustment, or format policy.

## 7. Explicit exclusions

Excluded from source repair and fixture:

- W7-W12 route/source inspection or opening.
- W13-W36 work.
- W1-W5 reopening.
- Broad W6 migration.
- Any second W6 family.
- `w6.s05` pilot.
- `w6.s08` pilot.
- Blocker reasoning.
- Polarization strategy.
- Opponent range construction.
- Combo counting.
- Frequencies or percentages.
- Stack-depth, tournament, ICM, exploit, or format policy.
- Solver/GTO/equilibrium/balance language.
- Action-prescription family.
- UI, screenshots, telemetry expansion, monetization, Human QA, launch, or
  external dependencies.

## 8. Bridge preservation

Existing W6 bridge fixture remains unchanged:

- `source_truth_status`: `bridge_or_legacy`
- `safe_claim_status`: `limited_bridge`
- `launch_coverage_claimed`: `false`

Mixed W6 bridge plus canonical validation remains bridge-limited.

## 9. Terminal gate protection

W6 terminal gate before W7-W10 preserved; no W7-W10 scope items introduced.

No W7-W10 route, title, source, or admission file was touched.

## 10. Validation

Executed:

- `dart run tools/content_factory_import_export_mvp_v1.dart`
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`

Required final evidence also includes the W6 foundation validator, W6 canonical
L2/L3 validator, W6 bridge plus canonical negative control, terminal route-lock
guard, `flutter analyze`, `graphify hook-check`, diff checks, ASCII checks,
and whitespace/newline checks.

## 11. Claim safety

Safe claims:

- One W6 canonical pilot exists for `range_bucket_by_board_fit`.
- Canonical-only W6 validation is route-ready for that narrow family.
- Bridge plus canonical W6 evidence remains bridge-limited.
- Launch coverage remains false.

Unsafe claims:

- W6 is not broad route-ready.
- W6 is not launch-ready.
- W6 is not 8.0 or 9.0.
- The pilot does not prove durable learning outcome, Human QA, or commercial
  readiness.

## 12. Score / ledger impact

Score proposal:

- W6: `5.3 -> 5.5`.
- W1-W12 readiness: `7.7 -> 7.8`.
- Content depth: `5.9 -> 6.0`.
- Overall top-1 readiness: unchanged at `6.5`.
- Progression / dopamine: unchanged at `6.5`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

Reason: this wave creates one validator-backed W6 canonical pilot, but does
not add payoff/progression proof, Human QA, learning-effect evidence, launch
claim safety beyond the narrow fixture, or broad W6 migration.

## 13. Route impact

No route/runtime/title/navigation change was made.

W6 remains `Range Thinking`.

W7-W12 remain closed/non-routed.

## 14. Evidence DoD status

Completed in-wave:

- Source repair for six `w6.s01` classifier tasks.
- W6 canonical pilot fixture.
- Factory/exporter registration.
- Focused factory and L2/L3 tests.
- Conservative ledger updates.

No screenshots were taken.

## 15. Anti-theater check

Pass.

This wave repaired the source before creating the fixture, kept the fixture
classification-only, preserved bridge negative controls, and did not convert
W6 into a broad certification or launch claim.

## 16. Next wave decision

Selected:

`W6 Range Bucket Canonical Pilot Certification Review v1`

Purpose:

- Review the one W6 canonical pilot for fixture-level correctness and claim
  safety.
- Decide whether W6 needs payoff/progression repair, a second safe canonical
  family, or continued bridge-limited status.
