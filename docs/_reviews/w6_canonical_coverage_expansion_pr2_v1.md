# W6 Canonical Coverage Expansion PR2 v1

## 1. Verdict

Verdict: `w6_canonical_coverage_expansion_pr2_ready_with_source_repair`.

W6 now has a second narrow canonical family:
`range_width_awareness`.

The family is safe only as a canonical PR2 pilot. It does not certify broad W6,
does not claim launch coverage, and does not merge bridge evidence into
canonical evidence.

Next wave: `W6 Certification / Payoff Gate v1`.

W6 terminal gate before W7-W10 preserved; no W7-W10 scope items introduced.

## 2. Accepted context

Latest accepted baseline:

- Branch: `codex/w6-range-bucket-pilot-review-repair-if-needed-v1`.
- Commit: `97bdc4e1`.
- Verdict: `w6_range_bucket_pilot_review_passed_recommends_pr2`.

Accepted W6 canonical family:

- `test/fixtures/content_factory_mvp/w6_range_bucket_by_board_fit_canonical_pilot_v1.json`.
- `concept_family_id`: `range_bucket_by_board_fit`.
- `session_id`: `w6.s01`.
- `safe_claim_status`: `canonical_pilot`.
- `launch_coverage_claimed`: `false`.

Bridge evidence remains separate:

- `test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`.
- `source_truth_status`: `bridge_or_legacy`.
- `safe_claim_status`: `limited_bridge`.

## 3. Candidate source review

The admitted candidate was `w6.s02` Position and Range Width.

Source basis:

- `content/worlds/world6/v1/sessions/w6.s02/session.md` teaches comparing
  simple position/range-width spots before choosing an exact hand or action.
- `content/worlds/world6/v1/sessions/w6.s02/notes.md` now states that the
  width classifier reps do not ask for bet, call, fold, or raise.
- The repaired `w6.s02` tasks ask the learner to classify relative width or
  constraint, not to prescribe a play.

The source supports a narrow family because it owns one coherent learner job:
notice when a range is wider, narrower, less constrained, or stronger on
average before action selection.

## 4. Source repair, if any

Source repair was required and performed.

Six existing `w6.s02` source tasks were converted into safe
`range_width_classifier_v1` tasks:

- `d.find_btn_realize.json` -> `classify_button_range_wider`.
- `d.find_bb.json` -> `classify_big_blind_continue_narrower`.
- `d.choose_call_realize.json` -> `classify_continue_range_narrower`.
- `d.choose_raise_blocker.json` -> `classify_button_open_less_constrained`.
- `d.tap_flop_realize.json` -> `classify_utg_range_stronger_average`.
- `d.tap_turn.json` -> `classify_late_position_more_hands`.

The legacy filename `d.choose_raise_blocker.json` remains stable source
metadata only. Its learner-facing prompt, feedback, kind, ID, and exported
fixture task do not teach blockers or raising.

The source package notes and drill index were updated to document that the
canonical family is width classification before action, not action choice.

## 5. Canonical PR2 family

Created fixture:

- `test/fixtures/content_factory_mvp/w6_range_width_awareness_canonical_pr2_v1.json`.

Fixture summary:

- 6 coverage-countable tasks.
- `world_id`: `world_6`.
- `route_world_id`: `world_6`.
- `display_world_title`: `Range Thinking`.
- `concept_family_id`: `range_width_awareness`.
- `same_signal_group_id`: `w6.range_thinking.range_width_awareness`.
- `repair_focus_id`: `width_before_action`.
- `source_truth_status`: `migrated`.
- `safe_claim_status`: `canonical_pilot`.
- `launch_coverage_claimed`: `false`.

Correct labels:

- `wider`.
- `narrower`.
- `narrower`.
- `less_constrained`.
- `stronger_on_average`.
- `wider`.

Transfer surfaces:

- `late_position_more_hands_v1`.
- `facing_open_filters_hands_v1`.
- `late_position_more_varied_v1`.
- `early_position_fewer_stronger_v1`.

## 6. Correctness / claim-safety review

Safe claim:

- W6 has two narrow canonical pilot families: range bucket by board fit and
  range width awareness.

Unsafe claims:

- W6 is not broad canonical.
- W6 is not 8.0 or 9.0.
- W6 is not launch-ready.
- W6 is not Human-QA validated.
- W6 payoff/progression is not certified.
- W6 broad range correctness is not proven.

The PR2 family avoids action prescription, blockers, polarization, opponent
combo construction, frequencies, stack depth, tournament/ICM, exploit
adjustments, solver/GTO language, monetization claims, and launch claims.

## 7. Explicit exclusions

Excluded from this wave:

- Third W6 canonical family.
- `w6.s05` or `w6.s08` pilot.
- `d.tap_hole_right_ks.json`.
- `d.tap_river_trap.json`.
- Broad W6 migration.
- W7-W12 source, route, or title work.
- W13-W36 work.
- W1-W5 reopening.
- Runtime route or title changes.
- UI, screenshots, telemetry, monetization, Human QA, 9.0, launch,
  solver/GTO, external dependency, or `output/` work.

## 8. Bridge preservation

Bridge and canonical evidence remain separated.

Canonical-only W6 evidence with both canonical families validates as
route-ready. Mixed bridge plus canonical W6 evidence remains bridge-limited
because bridge evidence still carries `bridge_or_legacy` source truth and
`limited_bridge` claim status.

No bridge task was counted as canonical coverage.

## 9. Terminal gate protection

The W6 terminal gate remains protected.

The wave did not inspect, author, route, or open W7-W10 content. The W7-W10
route-lock guard passed after the PR2 fixture and tests were added.

W6 terminal gate before W7-W10 preserved; no W7-W10 scope items introduced.

## 10. Validation

Validation results:

- `dart format tools/content_factory_import_export_mvp_v1.dart tools/content_schema_l2_l3_validator_v1.dart test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart test/tools/world6_range_cluster_wave_test.dart`: passed, `0` files changed on final run.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: passed, wrote
  `w6_range_width_awareness_canonical_pr2_v1.json` with `tasks=6` and
  `coverage_countable=6`.
- W6 foundation validator on PR2 fixture: passed, `tasks=6`,
  `coverage_countable=6`, `migration_sources=6`.
- W6 canonical L2/L3 validator on both canonical W6 families: passed,
  `tasks=12`, `coverage_countable=12`, `coverage_ready=true`,
  `transfer_ready=true`, `repair_ready=true`,
  `route_admission=learner_playable_route_ready`.
- W6 bridge plus canonical negative control: passed, `tasks=15`,
  `coverage_countable=15`, `coverage_ready=false`,
  `route_admission=bridge_or_legacy_limited`.
- Focused factory, L2/L3, and W6 source tests: passed, `65` tests.
- W7-W10 route-lock guard: passed, `3` tests.
- W6 forbidden-strategy scan: passed across `8` files, `7` learner-facing
  field names, and `33` forbidden terms.
- `flutter analyze`: passed, no issues found.

Final hygiene checks:

- `graphify hook-check`: passed.
- `git diff --check`: passed.
- `git diff --cached --check`: passed before staging.
- Direct ASCII, trailing whitespace, CRLF, and final-newline checks: passed
  across `17` changed or untracked non-output files.
- Diff-only ASCII check: passed.

## 11. Score / ledger impact

Score proposal:

- W6 Range Thinking: `5.5 -> 5.9`.
- W1-W12 Volume I Premium Product Readiness: `7.8 -> 7.9`.
- Content depth: `6.0 -> 6.1`.
- Overall Top-1 Readiness: unchanged at `6.5`.
- Launch readiness: unchanged.
- Human QA: unchanged.
- Monetization readiness: unchanged.
- Learning-effect proof: unchanged.

Reason: this wave adds a second validator-backed W6 canonical family and
improves migrated content depth, but does not certify payoff/progression,
launch claims, Human QA, or broad W6.

## 12. Route impact

No route, runtime title, navigation, or gate status changed.

W6 remains:

- `route_world_id`: `world_6`.
- Display title: `Range Thinking`.
- Route status: learner-playable through the existing campaign path.
- Terminal gate before W7-W10: preserved.

## 13. Evidence DoD status

Completed:

- One second W6 canonical family created.
- Source repair stayed inside `w6.s02` only.
- Fixture uses existing source tasks only.
- At least 5 coverage-countable tasks: `6`.
- Coherent same-signal group: `w6.range_thinking.range_width_awareness`.
- At least 2 transfer surfaces: `4`.
- Clear repair focus: `width_before_action`.
- Deterministic IDs and preserved source metadata.
- `launch_coverage_claimed=false`.
- Bridge separation preserved.
- W6 terminal gate preserved.

## 14. Anti-theater check

This is a real coverage movement because the new fixture is generated from
source-owned W6 tasks, validates with foundation and L2/L3 tooling, and has a
bridge negative control proving mixed evidence still cannot be counted as
canonical route-ready coverage.

This is still narrow:

- Two W6 canonical families are not broad W6.
- W6 is not certified at 8.0.
- W6 payoff/progression remains unproven.
- No launch, monetization, Human QA, or terminal-route claim changed.

## 15. Next wave decision

Recommended next wave:

`W6 Certification / Payoff Gate v1`

Reason: W6 now has two narrow canonical families. The next honest gate is not
more family breadth by default; it is deciding whether the existing W6 evidence
supports bounded certification movement and what payoff/progression proof is
still missing.
