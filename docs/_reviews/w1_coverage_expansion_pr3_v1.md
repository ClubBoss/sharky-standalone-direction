# W1 Coverage Expansion PR3 v1

Status: ACCEPTED implementation artifact.
Date: 2026-06-28.

## 1. Verdict

`w1_coverage_expansion_pr3_ready`

W1 now has two additional real source-derived, schema-shaped,
validator-backed concept-family fixtures:

- `bet_size_vocabulary_preview`
- `world1_checkpoint_synthesis`

Each fixture has six coverage-countable tasks, one honest same-signal group,
at least two transfer surfaces, one repair focus, preserved migration source
metadata, foundation validation, and L2/L3 route readiness.

## 2. Source truth

Focused docs inspected:

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`
- `docs/_reviews/w1_coverage_expansion_pr2_v1.md`
- `docs/_reviews/w1_full_coverage_certification_plan_v1.md`
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`

Focused tools/tests inspected:

- `tools/content_factory_import_export_mvp_v1.dart`
- `tools/content_schema_l2_l3_validator_v1.dart`
- `tools/content_schema_foundation_validator_v1.dart`
- `test/tools/content_factory_import_export_mvp_v1_test.dart`
- `test/tools/content_schema_l2_l3_validator_v1_test.dart`

Focused W1 source files used for `bet_size_vocabulary_preview`:

- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_one_third_pot_keep_price.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_half_pot_value.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_min_raise_reopen.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_pot_pressure.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json`

Focused W1 source files used for `world1_checkpoint_synthesis`:

- `content/worlds/world1/v1/sessions/w1.s02/drills/d.chain_world1_blind_button_intro_v1.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.chain_world1_action_order_checkpoint_v1.json`
- `content/worlds/world1/v1/sessions/w1.s04/drills/d.chain_world1_position_stability_v1.json`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.chain_world1_start_quality_reinforcement_v1.json`
- `content/worlds/world1/v1/sessions/w1.s06/drills/d.chain_world1_mixed_checkpoint_v1.json`
- `content/worlds/world1/v1/sessions/w1.s10/drills/d.chain_world1_final_checkpoint_v1.json`

## 3. Problem statement

Before PR3, W1 had four real schema-backed concept families:

- `position_action_order`
- `starting_hand_discipline`
- `seat_role_orientation`
- `card_board_orientation`

That proved the migration pattern, but W1 still had two high-value breadth
gaps before an honest 8.0 certification review: size-label vocabulary and
checkpoint synthesis.

## 4. Batch decision

Selected primary family:

- `bet_size_vocabulary_preview`

Selected secondary family:

- `world1_checkpoint_synthesis`

The secondary target was safe because the selected source chain roots are
authored W1 review/checkpoint chains. PR3 maps them as chain-level completion
checks using `complete_chain` as a schema action marker. It does not add new
poker advice or claim solver-grade synthesis.

Intentionally not built:

- broad W1 migration;
- new W1 content authoring;
- W2-W6 migration or realignment;
- route changes;
- W7-W12 admission;
- UI/screenshots;
- telemetry, monetization, Modern Table, or store/public beta work.

## 5. Migration output summary

Output fixtures:

- `test/fixtures/content_factory_mvp/w1_bet_size_vocabulary_preview_migration_pr3_v1.json`
- `test/fixtures/content_factory_mvp/w1_checkpoint_synthesis_migration_pr3_v1.json`

`bet_size_vocabulary_preview` summary:

- Total tasks: 6.
- Coverage-countable tasks: 6.
- Unique source paths: 5; two migrated tasks come from distinct steps in the
  same authored W1 bridge chain.
- `same_signal_group_id`:
  `w1.bet_size_vocabulary_preview.size_label_recognition: 6`.
- `transfer_surface_id` distribution:
  - `cheap_price_label_v1: 2`
  - `value_size_label_v1: 2`
  - `reopen_label_v1: 1`
  - `pressure_size_label_v1: 1`
- `repair_focus_id` distribution:
  - `size_label_before_strategy: 6`

`world1_checkpoint_synthesis` summary:

- Total tasks: 6.
- Coverage-countable tasks: 6.
- Unique source paths: 6.
- `same_signal_group_id`:
  `w1.world1_checkpoint_synthesis.seat_pressure_hand_quality_chain: 6`.
- `transfer_surface_id` distribution:
  - `blind_button_chain_v1: 1`
  - `action_order_chain_v1: 1`
  - `position_stability_chain_v1: 1`
  - `start_quality_chain_v1: 1`
  - `mixed_checkpoint_chain_v1: 1`
  - `final_checkpoint_chain_v1: 1`
- `repair_focus_id` distribution:
  - `connect_seat_pressure_hand_quality: 6`

## 6. L2/L3 validation results

Both PR3 fixtures report as L2 route-ready:

- `coverage_ready=true`
- `transfer_ready=true`
- `repair_ready=true`
- Route admission: `learner_playable_route_ready`
- Validator result: `OK`

Combined explicit W1 coverage fixture set:

- `w1_world_coverage_pilot_v1.json`
- `w1_starting_hand_discipline_migration_batch1_v1.json`
- `w1_seat_role_orientation_migration_pr2_v1.json`
- `w1_card_board_orientation_migration_pr2_v1.json`
- `w1_bet_size_vocabulary_preview_migration_pr3_v1.json`
- `w1_checkpoint_synthesis_migration_pr3_v1.json`

Combined summary:

- Six schema-backed W1 concept-family fixtures.
- 36 coverage-countable migrated W1 tasks.
- Six same-signal groups at six tasks each.
- All counted tasks preserve migration source metadata.

## 7. Fixture scope note

PR3 adds `w1ContentFactoryCoverageFixturePathsV1` as the explicit W1 L2
coverage fixture list. It intentionally excludes the existing
`w1_import_export_sample_v1.json` L1/tiny sample so broad `w1_*.json` globs do
not accidentally treat a one-task factory proof as an L2 coverage group.

Foundation validation may still run across all `w1_*.json` factory fixtures,
including the L1 sample, because foundation checks schema shape rather than
coverage sufficiency.

## 8. Test coverage

Updated `test/tools/content_factory_import_export_mvp_v1_test.dart`:

- `exports W1 bet size vocabulary preview PR3 from real source tasks`
- `exports W1 checkpoint synthesis PR3 from real chain roots`

Updated `test/tools/content_schema_l2_l3_validator_v1_test.dart`:

- `reports real W1 bet size vocabulary PR3 as L2 route-ready`
- `reports real W1 checkpoint synthesis PR3 as L2 route-ready`
- `explicit W1 coverage fixture list excludes the L1 tiny sample`

## 9. W1 certification impact

W1 now has six schema-backed concept families:

- `position_action_order`
- `starting_hand_discipline`
- `seat_role_orientation`
- `card_board_orientation`
- `bet_size_vocabulary_preview`
- `world1_checkpoint_synthesis`

This justifies moving W1 from `7.6` to `8.0` as a certification candidate.
It does not make W1 launch-ready.

What still blocks 9.0/10.0:

- human novice QA is not executed;
- poker correctness review is not executed;
- full W1 schema migration is not complete;
- payoff/progression proof is not certification-linked;
- external learning-effect claims remain blocked.

## 10. Volume I ledger impact

W1 score movement is justified:

- W1 readiness: `7.6 -> 8.0` (`+0.4`).

Reason: W1 now has two additional real source-derived, schema-shaped,
validator-backed concept families. Each has six coverage-countable tasks,
same-signal threshold pass, transfer surfaces, repair focus, preserved
migration metadata, and L2/L3 route readiness.

Aggregate conservative movement:

- W1-W12 Volume I Premium Product Readiness: `6.1 -> 6.2`.
- Content depth: `5.0 -> 5.1`.
- Overall Top-1 Readiness: `5.9 -> 6.0`.
- Architecture scalability: unchanged at `8.1`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

## 11. Route impact

- No route changes.
- No learner-facing title changes.
- W1 remains learner-playable.
- W2-W6 remain bridge_or_legacy limited.
- W7-W10 remain locked/not learner-playable.
- W11-W12 remain authored but not routed.
- W13-W36 remain post-launch/live expansion/deferred roadmap.
- Active next action changes from W1 Coverage Expansion PR3 to W1 8.0
  Certification Review.

## 12. Active repair queue update

Closed:

- W1 Coverage Expansion PR3.

Active:

- W1 8.0 Certification Review.

Must-not-skip:

- Preserve all six W1 positive controls.
- Keep every future W1 counted family validator-backed.
- Keep transfer surfaces and `repair_focus_id` on counted repairable tasks.
- Run poker correctness review before broad W1 claims.
- Run Human QA Protocol before external beta or learning-effect claims.

Deferred:

- Broad W1 migration.
- New W1 content authoring.
- W2-W6 canonical realignment.
- W7-W12 admission/opening.
- W13-W36 launch dependency.
- Monetization/store/public beta.

## 13. Score delta proposal

| Score area | Previous | Proposed | Delta | Reason |
| --- | ---: | ---: | ---: | --- |
| W1 readiness | 7.6 | 8.0 | +0.4 | Two more W1 schema-backed concept families pass foundation and L2/L3 validation |
| W1-W12 readiness | 6.1 | 6.2 | +0.1 | W1 canonical coverage breadth is now certification-review ready |
| Architecture | 8.1 | 8.1 | +0.0 | No broad new schema/tooling capability beyond narrow exporter and fixture-list hardening |
| Content depth | 5.0 | 5.1 | +0.1 | W1 content coverage breadth improved from four to six families |
| Overall Top-1 | 5.9 | 6.0 | +0.1 | Product evidence improved inside the active W1-W12 scope |
| Learning effect | 6.0 | 6.0 | +0.0 | No human or cross-session learning measurement |
| Monetization readiness | 2.0 | 2.0 | +0.0 | No monetization work |

## 14. Evidence DoD status

Validation results:

- `dart format --set-exit-if-changed tools/content_factory_import_export_mvp_v1.dart tools/content_schema_l2_l3_validator_v1.dart test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: passed.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: passed; 31 tests passed.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: passed; wrote 13 factory fixtures including both PR3 W1 fixtures.
- `dart run tools/content_schema_l2_l3_validator_v1.dart` on the explicit six-fixture W1 coverage list: passed; fixtures=6, worlds=1, tasks=36, coverage_countable=36, coverage_ready=true, transfer_ready=true, repair_ready=true, route_admission=learner_playable_route_ready.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w1_*.json`: passed; all W1 factory fixtures OK at foundation level.
- `flutter analyze`: passed; no issues found.
- `graphify hook-check`: passed.
- `git diff --check`: passed.
- direct ASCII check: passed.
- direct trailing-whitespace/CRLF check: passed.

No screenshots.

## 15. Anti-theater check

What risk moved:

- W1 now has six independent schema-backed concept-family proofs instead of
  four. The two new proofs are source-derived, code/test-backed, and
  validator-backed.
- L1/tiny fixtures are now explicitly excluded from W1 L2 coverage validation.

What did not move:

- W1 launch certification did not complete.
- Human QA did not run.
- Poker correctness review did not run.
- W2-W6 did not become canonical coverage.
- W7-W12 did not open.
- Learning-effect and monetization readiness did not move.

Is this code/test-backed?

- Yes. The exporter, committed fixtures, foundation validation, L2/L3
  validation, explicit fixture-list test, and focused tests all back PR3.

Is PR4 needed for W1 breadth?

- No immediate PR4 is needed for the current W1 family-breadth objective.
  The next higher-value step is W1 8.0 Certification Review.
