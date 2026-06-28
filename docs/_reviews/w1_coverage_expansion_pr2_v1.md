# W1 Coverage Expansion PR2 v1

Status: ACCEPTED implementation artifact.
Date: 2026-06-28.

## 1. Verdict

`w1_coverage_expansion_pr2_ready`

W1 now has two additional real source-derived, schema-shaped,
validator-backed concept-family fixtures:

- `seat_role_orientation`
- `card_board_orientation`

Each fixture has six coverage-countable tasks, one honest same-signal group,
at least two transfer surfaces, one repair focus, preserved migration source
metadata, foundation validation, and L2/L3 route readiness.

## 2. Source truth

Focused docs inspected:

- `AGENTS.md`: repo boundary, route constraints, graphify, and validation
  expectations.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy.
- `docs/plan/MASTER_PLAN_v3.0.md`: execution authority and active route
  constraints.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: top-1 scope and launch
  claim boundaries.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active
  long-horizon ledger and W1 Coverage Expansion PR2 pointer.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W1 score, scoring rules,
  and active next action.
- `docs/_reviews/w1_full_coverage_certification_plan_v1.md`: accepted W1
  certification gaps and remaining concept-family list.
- `docs/_reviews/w1_concept_family_migration_batch1_v1.md`: accepted previous
  W1 schema-backed family and validation pattern.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: schema-owned task fields.
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`: L0/L1/L2/L3 validation
  rules.

Focused tools/tests inspected:

- `tools/content_factory_import_export_mvp_v1.dart`
- `tools/content_schema_l2_l3_validator_v1.dart`
- `tools/content_schema_foundation_validator_v1.dart`
- `test/tools/content_factory_import_export_mvp_v1_test.dart`
- `test/tools/content_schema_l2_l3_validator_v1_test.dart`

Focused W1 source files inspected and used for `seat_role_orientation`:

- `content/worlds/world1/v1/sessions/w1.s01/drills/d.find_btn.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.find_sb.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.find_bb.json`
- `content/worlds/world1/v1/sessions/w1.s07/drills/d.find_btn_focus.json`
- `content/worlds/world1/v1/sessions/w1.s08/drills/d.find_sb_focus.json`
- `content/worlds/world1/v1/sessions/w1.s10/drills/d.find_btn_focus.json`

Focused W1 source files inspected and used for `card_board_orientation`:

- `content/worlds/world1/v1/sessions/w1.s01/drills/d.tap_flop_right.json`
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.tap_turn.json`
- `content/worlds/world1/v1/sessions/w1.s03/drills/d.tap_river.json`
- `content/worlds/world1/v1/sessions/w1.s04/drills/d.tap_flop_right_repeat.json`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.tap_turn_repeat.json`
- `content/worlds/world1/v1/sessions/w1.s06/drills/d.tap_river_repeat.json`

## 3. Problem statement

Before PR2, W1 had two real schema-backed concept families:

- `position_action_order`
- `starting_hand_discipline`

That was strong enough to prove the migration path, but not enough to support
broader W1 certification or approach the 8.0 W1 bar honestly. The accepted W1
certification plan still listed unproven W1 family breadth, including seat
role and card/board orientation.

## 4. Batch decision

Selected primary family:

- `seat_role_orientation`

Selected secondary family:

- `card_board_orientation`

The secondary target was safe because existing board-slot tap source files
provided six repeatable tasks across flop, turn, and river surfaces. This PR
intentionally uses the board-slot subset for the family. Hole-card taps remain
available source, but were not needed to satisfy this PR's same-signal and
transfer proof.

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

- `test/fixtures/content_factory_mvp/w1_seat_role_orientation_migration_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w1_card_board_orientation_migration_pr2_v1.json`

`seat_role_orientation` summary:

- Total tasks: 6.
- Coverage-countable tasks: 6.
- `same_signal_group_id`:
  `w1.seat_role_orientation.blind_button_seat_identity: 6`.
- `transfer_surface_id` distribution:
  - `button_role_find_v1: 3`
  - `blind_role_find_v1: 3`
- `repair_focus_id` distribution:
  - `role_before_action: 6`
- `source_truth_status` distribution:
  - `migrated: 6`

`card_board_orientation` summary:

- Total tasks: 6.
- Coverage-countable tasks: 6.
- `same_signal_group_id`:
  `w1.card_board_orientation.board_slot_identity: 6`.
- `transfer_surface_id` distribution:
  - `flop_slot_find_v1: 2`
  - `turn_slot_find_v1: 2`
  - `river_slot_find_v1: 2`
- `repair_focus_id` distribution:
  - `board_slot_before_action: 6`
- `source_truth_status` distribution:
  - `migrated: 6`

## 6. L2/L3 validation results

Both PR2 fixtures report as L2 route-ready:

- `coverage_ready=true`
- `transfer_ready=true`
- `repair_ready=true`
- Route admission: `learner_playable_route_ready`
- Validator result: `OK`

Combined W1 fixture set used for direct validator proof:

- `w1_world_coverage_pilot_v1.json`
- `w1_starting_hand_discipline_migration_batch1_v1.json`
- `w1_seat_role_orientation_migration_pr2_v1.json`
- `w1_card_board_orientation_migration_pr2_v1.json`

Combined summary:

- Four schema-backed W1 concept-family fixtures.
- 24 coverage-countable migrated W1 tasks.
- Four same-signal groups at six tasks each.
- All counted tasks preserve migration source metadata.

## 7. Test coverage

Updated `test/tools/content_factory_import_export_mvp_v1_test.dart`:

- `exports W1 seat role orientation PR2 from real source tasks`
- `exports W1 card board orientation PR2 from real source tasks`

These tests prove deterministic export, six unique task IDs per fixture,
concept family, same-signal group, transfer surfaces, repair focus, correct
action mapping, source truth status, and preserved migration source paths.

Updated `test/tools/content_schema_l2_l3_validator_v1_test.dart`:

- `reports real W1 seat role orientation PR2 as L2 route-ready`
- `reports real W1 card board orientation PR2 as L2 route-ready`

These tests prove the committed PR2 fixtures satisfy L2/L3 coverage, transfer,
repair, source-truth, validation-status, and route-admission checks.

## 8. W1 certification impact

W1 now has four schema-backed concept families:

- `position_action_order`
- `starting_hand_discipline`
- `seat_role_orientation`
- `card_board_orientation`

Does this move W1 toward 8.0?

- Yes. It materially expands real W1 family breadth using existing source and
  existing validators.

What still blocks 8.0/9.0/10.0:

- 8.0 remains blocked by incomplete W1 family breadth, especially checkpoint
  synthesis and bet-size vocabulary boundaries.
- 9.0 remains blocked by missing human QA and poker correctness proof.
- 10.0 remains blocked by incomplete W1 coverage, QA, correctness, claim
  safety, and payoff/progression certification.

## 9. Volume I ledger impact

W1 score movement is justified:

- W1 readiness: `7.2 -> 7.6` (`+0.4`).

Reason: W1 now has two additional real source-derived, schema-shaped,
validator-backed concept families. Each has six coverage-countable tasks,
same-signal threshold pass, transfer surfaces, repair focus, preserved
migration metadata, and L2/L3 route readiness.

Aggregate conservative movement:

- W1-W12 Volume I Premium Product Readiness: `6.0 -> 6.1`.
- Content depth: `4.9 -> 5.0`.
- Overall Top-1 Readiness: `5.8 -> 5.9`.
- Architecture scalability: unchanged at `8.1`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

## 10. Route impact

- No route changes.
- No learner-facing title changes.
- W1 remains learner-playable.
- W2-W6 remain bridge_or_legacy limited.
- W7-W10 remain locked/not learner-playable.
- W11-W12 remain authored but not routed.
- W13-W36 remain post-launch/live expansion/deferred roadmap.

## 11. Active repair queue update

Closed:

- W1 Coverage Expansion PR2.

Active:

- W1 Coverage Expansion PR3.

Must-not-skip:

- Preserve all four W1 positive controls:
  - `position_action_order`
  - `starting_hand_discipline`
  - `seat_role_orientation`
  - `card_board_orientation`
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

Blockers:

- Remaining W1 family breadth is not fully schema-backed:
  - `bet_size_vocabulary_preview`
  - `world1_checkpoint_synthesis`
- Hole-card orientation source exists, but this PR only migrated the safer
  board-slot same-signal subset.
- Human novice QA is not executed.
- Poker correctness review is not executed.
- W1 payoff/progression proof is not certification-linked.

## 12. Score delta proposal

| Score area | Previous | Proposed | Delta | Reason |
| --- | ---: | ---: | ---: | --- |
| W1 readiness | 7.2 | 7.6 | +0.4 | Two more W1 schema-backed concept families pass foundation and L2/L3 validation |
| W1-W12 readiness | 6.0 | 6.1 | +0.1 | W1 canonical coverage breadth improved, but Volume I remains incomplete |
| Architecture | 8.1 | 8.1 | +0.0 | No new schema/tooling capability beyond narrow exporter extension |
| Content depth | 4.9 | 5.0 | +0.1 | W1 content coverage breadth improved from two to four families |
| Overall Top-1 | 5.8 | 5.9 | +0.1 | Product evidence improved inside the active W1-W12 scope |
| Learning effect | 6.0 | 6.0 | +0.0 | No human or cross-session learning measurement |
| Monetization readiness | 2.0 | 2.0 | +0.0 | No monetization work |

## 13. Evidence DoD status

Validation results:

- `dart format --set-exit-if-changed tools/content_factory_import_export_mvp_v1.dart test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: passed; 0 files changed.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: passed; 26 tests passed.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: passed; wrote 11 factory fixtures including both PR2 W1 fixtures.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json test/fixtures/content_factory_mvp/w1_starting_hand_discipline_migration_batch1_v1.json test/fixtures/content_factory_mvp/w1_seat_role_orientation_migration_pr2_v1.json test/fixtures/content_factory_mvp/w1_card_board_orientation_migration_pr2_v1.json`: passed; fixtures=4, worlds=1, tasks=24, coverage_countable=24, coverage_ready=true, transfer_ready=true, repair_ready=true, route_admission=learner_playable_route_ready.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json test/fixtures/content_factory_mvp/w1_starting_hand_discipline_migration_batch1_v1.json test/fixtures/content_factory_mvp/w1_seat_role_orientation_migration_pr2_v1.json test/fixtures/content_factory_mvp/w1_card_board_orientation_migration_pr2_v1.json`: passed; all four W1 coverage fixtures OK.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w1_*.json`: failed as expected because the wildcard includes the existing one-task `w1_import_export_sample_v1.json`, which is an L1/tiny factory sample and intentionally not an L2 same-signal group.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w1_*.json`: passed; all five W1 factory fixtures OK at foundation level.
- `flutter analyze`: passed; no issues found.
- `graphify hook-check`: passed.
- `git diff --check`: passed.
- direct ASCII check: passed.
- direct trailing-whitespace/CRLF check: passed.

No screenshots.

## 14. Anti-theater check

What risk moved:

- W1 now has four independent schema-backed concept-family proofs instead of
  two. The two new proofs are code/test-backed and validator-backed.

What did not move:

- Full W1 certification did not complete.
- Human QA did not run.
- Poker correctness review did not run.
- W2-W6 did not become canonical coverage.
- W7-W12 did not open.
- Learning-effect and monetization readiness did not move.

Is this code/test-backed?

- Yes. The exporter, committed fixtures, foundation validation, L2/L3
  validation, and focused tests all back PR2.

Is PR3 needed?

- Yes. W1 still needs remaining family breadth and certification closure before
  broad W1 claims or W2-W6 canonical realignment.
