# W1 World Coverage Expansion Pilot v1

## 1. Verdict

`w1_world_coverage_pilot_ready`

Six real W1 source tasks were imported/exported through the tiny content
factory into one schema-shaped coverage pilot fixture. The fixture passes L0
foundation validation and L2/L3 coverage plus route-admission validation.

## 2. Source truth

Focused sources inspected:

- `AGENTS.md` for active repo, route, graphify, and testing constraints.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` for SSOT hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` for top-1 strategy scope.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md` for active long-horizon ledger state.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md` for W1-W12 readiness scoring.
- `docs/_reviews/l2_l3_content_validator_expansion_v1.md` for accepted L2/L3 validator evidence.
- `docs/_reviews/tiny_content_factory_import_export_mvp_v1.md` for accepted factory MVP boundary.
- `docs/_reviews/w2_w6_route_content_normalization_v1.md` for W2-W6 bridge_or_legacy truth.
- `docs/_reviews/l2_volume_i_w1_w12_world_coverage_report_v1.md` for W1 launch_coverage_candidate status.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md` and `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md` for required fields and validator meaning.
- `tools/content_factory_import_export_mvp_v1.dart`, `tools/content_schema_l2_l3_validator_v1.dart`, and `tools/content_schema_foundation_validator_v1.dart` for executable behavior.
- `test/tools/content_factory_import_export_mvp_v1_test.dart` and `test/tools/content_schema_l2_l3_validator_v1_test.dart` for focused proof.

Focused W1 source tasks inspected and used:

- `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_button_open_clean_v1.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_big_blind_continue_defend_v1.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_small_blind_release_caution_v1.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_first_in_raise_after_folds_v1.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_call_when_pressure_reaches_you_v1.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_fold_when_multiway_pressure_stacks_v1.json`

## 3. Problem statement

L2/L3 validator readiness proved that coverage and route-admission checks can
run, but it did not prove real W1 source tasks can move through the factory as
a coherent same-signal group. Before W1 coverage claims expand, the pipeline
needs evidence that real source-owned tasks preserve migration metadata, pass
foundation validation, meet the L2 same-signal threshold, carry honest transfer
surfaces, and remain route-safe under W1 learner_playable admission.

## 4. Pilot decision

- Selected W1 concept family: `position_action_order`.
- Selected same-signal group: `w1.position_action_order.first_in_or_facing_pressure`.
- Selected source tasks: six existing W1 action-choice source files from `w1.s02` and `w1.s03`.
- Coverage threshold: reached with 6 coverage_countable tasks.
- Transfer claimed: yes, across `first_in_action_order_v1`, `facing_open_pressure_v1`, and `multiway_pressure_v1`.
- Repair claimed: yes, all tasks use `repair_focus_id: position_before_action`.
- Intentionally not built: full W1 migration, W2-W6 migration, W7-W12 opening, content authoring, UI, telemetry, monetization, Modern Table, L4 poker correctness, and human QA.

## 5. Import/export summary

Output fixture:

- `test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`

ID mapping:

- `choose_button_open_clean_v1` -> `w1.s02.choose_button_open_clean_v1.coverage_pilot_v1`
- `choose_big_blind_continue_defend_v1` -> `w1.s02.choose_big_blind_continue_defend_v1.coverage_pilot_v1`
- `choose_small_blind_release_caution_v1` -> `w1.s02.choose_small_blind_release_caution_v1.coverage_pilot_v1`
- `choose_first_in_raise_after_folds_v1` -> `w1.s03.choose_first_in_raise_after_folds_v1.coverage_pilot_v1`
- `choose_call_when_pressure_reaches_you_v1` -> `w1.s03.choose_call_when_pressure_reaches_you_v1.coverage_pilot_v1`
- `choose_fold_when_multiway_pressure_stacks_v1` -> `w1.s03.choose_fold_when_multiway_pressure_stacks_v1.coverage_pilot_v1`

Preserved source metadata:

- source path
- source id
- source kind
- source `intent_v1`
- source expected action
- source error class
- source job
- source transform

Claim safety:

- `world_id`, `route_world_id`, and `content_owner_world_id` stay `world_1`.
- `route_gate_status` stays `learner_playable`.
- `source_truth_status` is `migrated`.
- `preview_only` is `false` for every coverage-countable task.
- Transfer is claimed only because the group has 3 distinct transfer surfaces.

## 6. L2/L3 validation results

- Total tasks: 6.
- Coverage_countable tasks: 6.
- `concept_family_id` counts: `position_action_order: 6`.
- `same_signal_group_id` counts: `w1.position_action_order.first_in_or_facing_pressure: 6`.
- `transfer_surface_id` counts: `first_in_action_order_v1: 2`, `facing_open_pressure_v1: 3`, `multiway_pressure_v1: 1`.
- `repair_focus_id` counts: `position_before_action: 6`.
- `validation_status` distribution: `source_validated: 6`.
- `source_truth_status` distribution: `migrated: 6`.
- Route admission result: `learner_playable_route_ready`.

## 7. Test coverage

- `exports W1 world coverage pilot from real source tasks`: proves deterministic W1 pilot export, unique task IDs, required schema fields, source metadata, transfer surfaces, repair focus, and source truth.
- `reports real W1 factory coverage pilot as L2 route-ready`: proves L2/L3 metrics for the committed W1 pilot fixture.
- `real W1 pilot fails L2 threshold when trimmed below five reps`: proves the same-signal threshold is not bypassed by a thin group.
- Existing L2/L3 tests continue to protect bridge_or_legacy reporting and W7/W11/W13 negative route gates.
- Existing factory tests continue to protect deterministic tiny W1/W2 exports and source file preservation.

## 8. Volume I ledger impact

W1 score changed from `6.6` to `6.9` (`+0.3`).

Evidence: six real W1 source tasks pass factory export, foundation validation,
and L2/L3 validation as one coverage group. The delta is intentionally below a
full launch-grade jump because this is still a pilot slice, not full W1
migration, poker correctness review, or human QA.

Aggregate proposed movement:

- W1-W12 Volume I Premium Product Readiness: `5.6 -> 5.7`.
- Architecture scalability: `7.8 -> 7.9`.
- Content depth: `4.5 -> 4.6`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

## 9. Route impact

- No route changed.
- No learner-facing title changed.
- No world became playable, locked, or routed differently.
- W7-W10 remain locked_not_learner_playable.
- W11-W12 remain authored_but_not_routed.
- W13-W36 remain post-launch / live expansion / advanced roadmap.
- No monetization, store, public beta, telemetry, UI, or Modern Table work occurred.

## 10. Active repair queue update

Closed:

- W1 World Coverage Expansion Pilot v1.

Active:

- W1-W6 Schema Migration Pilot or W2-W6 Bridge-Or-Legacy Migration Pilot.

Must-not-skip:

- Keep future migration validator-led.
- Preserve W2-W6 bridge_or_legacy claim limits until migrated evidence exists.
- Keep route/content normalization before broad content claims.
- Run Human QA Protocol before external beta or learning-effect claims.

Deferred:

- New W1-W6 content authoring.
- W5-W12 expansion.
- W7-W12 opening.
- Monetization.
- Store/public beta.
- W13-W36 launch availability.

Blockers:

- Full W1 migration is not complete.
- W2-W6 remain bridge_or_legacy.
- Human QA and poker correctness review remain unrun.

## 11. Score delta proposal

- W1 world readiness score: `6.6 -> 6.9` (`+0.3`).
- W1-W12 Volume I Premium Product Readiness: `5.6 -> 5.7` (`+0.1`).
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall Top-1 Readiness: `5.4 -> 5.5` (`+0.1`).
- Architecture scalability: `7.8 -> 7.9` (`+0.1`).
- Content depth: `4.5 -> 4.6` (`+0.1`).
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

## 12. Next-step recommendation

Recommended actual next step: `W1-W6 Schema Migration Pilot`.

Why: W1 now has a real L2 coverage group, so the next control-plane bottleneck
is expanding schema migration discipline across the launch-facing W1-W6 band
without overclaiming W2-W6 bridge_or_legacy content as canonical launch
coverage.

Do not recommend broad authoring yet.

## 13. Wave DoD status

- Real W1 source tasks selected: done.
- Multiple W1 tasks imported/exported: done.
- Schema-shaped output committed: done.
- L2/L3 validation passed or blocker documented: passed.
- Source metadata preserved: done.
- No content authored: done.
- No broad migration: done.
- No route changes: done.
- Next step selected: `W1-W6 Schema Migration Pilot`.

## 14. Evidence DoD status

Command evidence:

- `dart run tools/content_factory_import_export_mvp_v1.dart`: OK; wrote W1 sample, W2 bridge sample, and W1 pilot fixture; W1 pilot tasks=6 coverage_countable=6.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: OK; 14 tests passed.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`: OK; world_1 tasks=6 coverage_countable=6 coverage_ready=true transfer_ready=true repair_ready=true route_admission=learner_playable_route_ready.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`: OK; tasks=6 coverage_countable=6 migration_sources=6.

Final formatting, analysis, graphify, diff, ASCII, whitespace, and CRLF checks
are recorded in the final Codex response for this wave.

## 15. Anti-theater check

Risk moved:

- Real W1 factory migration breadth moved from one tiny sample to one six-task
  validator-backed same-signal group.
- L2 same-signal, transfer, repair, and W1 route-admission proof now run on
  real W1 source-derived fixture data.

What did not move:

- Full W1 migration did not happen.
- W2-W6 remain bridge_or_legacy.
- W7-W12 route state did not open.
- Human QA, poker correctness review, and monetization did not happen.

Evidence type:

- Code-backed and test-backed, with a committed deterministic fixture and
  executable validators.

Broader migration readiness:

- This enables a broader W1-W6 schema migration pilot. It does not eliminate
  the need for PR2-style expansion if the next wave wants more W1 concept
  families or full W1 coverage certification.
