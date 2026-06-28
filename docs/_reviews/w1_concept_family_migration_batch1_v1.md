# W1 Concept Family Migration Batch 1 v1

Status: ACCEPTED implementation artifact.
Date: 2026-06-28.

## 1. Verdict

`w1_concept_family_migration_batch1_ready`

W1 now has a second real source-derived, schema-shaped, validator-backed concept
family fixture. The new family is `starting_hand_discipline`, with six
coverage-countable tasks in one same-signal group, three transfer surfaces, one
repair focus, preserved source metadata, foundation validation, and L2/L3 route
readiness.

## 2. Source truth

Focused docs inspected:

- `AGENTS.md`: repo boundary, route constraints, graphify, and validation
  expectations.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: top-1 scope and launch
  claim boundaries.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active long-horizon
  ledger and W1-W12 launch target.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W1 score, scoring rules,
  and active next action.
- `docs/_reviews/w1_full_coverage_certification_plan_v1.md`: accepted
  certification plan and selected target concept family.
- `docs/_reviews/w1_world_coverage_expansion_pilot_v1.md`: existing W1
  positive-control pilot evidence.
- `docs/_reviews/l2_l3_content_validator_expansion_v1.md`: L2/L3 validation
  contract.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: schema-owned task fields.
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`: L0/L1/L2/L3 validation
  rules.

Focused tools/tests inspected:

- `tools/content_factory_import_export_mvp_v1.dart`: factory exporter seam.
- `tools/content_schema_l2_l3_validator_v1.dart`: L2/L3 report and route gate.
- `tools/content_schema_foundation_validator_v1.dart`: foundation validator.
- `test/tools/content_factory_import_export_mvp_v1_test.dart`: exporter tests.
- `test/tools/content_schema_l2_l3_validator_v1_test.dart`: L2/L3 tests.

Focused W1 source files inspected and used:

- `content/worlds/world1/v1/world.md`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_cutoff_raise_clean_start_v1.json`
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_small_blind_fold_weak_start_v1.json`
- `content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_raise_clean_first_in_checkpoint_v1.json`
- `content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_big_blind_call_oop_defend_focus_v1.json`
- `content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_raise_when_action_folds_to_you_focus_v1.json`
- `content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_fold_when_pressure_and_position_fail_focus_v1.json`

Focused W1 source files inspected but not used:

- `content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_fold_oop_pressure_checkpoint_v1.json`
- `content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_small_blind_raise_oop_clean_start_v1.json`
- `content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_small_blind_fold_oop_focus_v1.json`
- `content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_call_when_open_reaches_you_focus_v1.json`

Reason for exclusion: the selected six-task set already met the same-signal,
transfer, repair, and route-readiness bars without expanding into redundant
or less focused repetitions.

## 3. Problem statement

The W1 certification plan was necessary but not sufficient. It identified
`starting_hand_discipline` as the next certification gap, but W1 still had only
one schema-backed concept family: `position_action_order`.

Without a second real W1 family, W1 could not honestly approach the 8.0 bar in
the certification ladder because one pilot group can prove the pipeline but not
broad W1 foundation coverage.

## 4. Batch decision

Selected concept family:

- `starting_hand_discipline`

Selected source tasks:

- `w1.s05.choose_cutoff_raise_clean_start_v1`
- `w1.s05.choose_small_blind_fold_weak_start_v1`
- `w1.s06.choose_raise_clean_first_in_checkpoint_v1`
- `w1.s08.choose_big_blind_call_oop_defend_focus_v1`
- `w1.s09.choose_raise_when_action_folds_to_you_focus_v1`
- `w1.s09.choose_fold_when_pressure_and_position_fail_focus_v1`

Same-signal group:

- `w1.starting_hand_discipline.clean_start_or_release`

Transfer surfaces:

- `clean_first_in_start_v1`
- `facing_open_continue_or_release_v1`
- `oop_weak_start_release_v1`

Repair focus:

- `release_weak_or_dominated_start`

Intentionally not built:

- full W1 migration;
- new W1 content authoring;
- W2-W6 migration;
- route changes;
- W7-W12 admission;
- L4 poker correctness review;
- human QA;
- UI/screenshots;
- telemetry, monetization, Modern Table, or store/public beta work.

## 5. Migration output summary

Output fixture:

- `test/fixtures/content_factory_mvp/w1_starting_hand_discipline_migration_batch1_v1.json`

Source files:

- six existing W1 action-choice source JSON files from `w1.s05`, `w1.s06`,
  `w1.s08`, and `w1.s09`.

Fixture summary:

- Total tasks: 6.
- Coverage-countable tasks: 6.
- `concept_family_id`: `starting_hand_discipline`.
- `same_signal_group_id`:
  `w1.starting_hand_discipline.clean_start_or_release: 6`.
- `transfer_surface_id` distribution:
  - `clean_first_in_start_v1: 3`
  - `facing_open_continue_or_release_v1: 1`
  - `oop_weak_start_release_v1: 2`
- `repair_focus_id` distribution:
  - `release_weak_or_dominated_start: 6`
- `validation_status` distribution:
  - `source_validated: 6`
- `source_truth_status` distribution:
  - `migrated: 6`
- Migration sources preserved: 6.
- Claim safety: safe as W1 schema-backed starting-hand-discipline batch, not
  full W1 certification or public learning-effect proof.

## 6. L2/L3 validation results

Direct validation of the existing W1 positive-control pilot plus the new
starting-hand batch:

- Fixtures: 2.
- Worlds: 1.
- Total tasks: 12.
- Coverage-countable tasks: 12.
- `coverage_ready=true`.
- `transfer_ready=true`.
- `repair_ready=true`.
- Route admission: `learner_playable_route_ready`.
- Validator result: `OK`.

New batch alone:

- `coverage_ready=true`.
- `transfer_ready=true`.
- `repair_ready=true`.
- Route admission: `learner_playable_route_ready`.
- `validation_status`: `source_validated: 6`.

## 7. Test coverage

Updated `test/tools/content_factory_import_export_mvp_v1_test.dart`:

- `exports W1 starting hand discipline batch from real source tasks`
  - proves deterministic export, six unique task IDs, W1 route/content fields,
    concept family, same-signal group, transfer surfaces, repair focus,
    correct actions, source validation, and migration source metadata.
- Existing factory tests still prove the W1 `position_action_order` pilot and
  W2-W6 bridge fixtures.

Updated `test/tools/content_schema_l2_l3_validator_v1_test.dart`:

- `reports real W1 starting hand discipline batch as L2 route-ready`
  - proves L2/L3 readiness for the committed fixture.
- Existing L2/L3 tests still prove the W1 positive control, thin-threshold
  failure, W2-W6 bridge claim safety, and locked/deferred route gates.

## 8. W1 certification impact

Does W1 now have multiple schema-backed concept families?

- Yes. W1 has `position_action_order` and `starting_hand_discipline` as real
  source-derived, schema-backed, validator-ready concept families.

Does this move W1 toward 8.0?

- Yes. It satisfies the "multiple schema-backed concept families" direction
  from the W1 certification ladder.

What still blocks 8.0/9.0/10.0:

- 8.0 remains blocked by incomplete W1 family breadth and no full W1 coverage
  map.
- 9.0 remains blocked by missing human QA and poker correctness proof.
- 10.0 remains blocked by incomplete W1 coverage, QA, correctness, claim
  safety, and payoff/progression certification.

## 9. Volume I ledger impact

W1 score movement is justified:

- W1 readiness: `6.9 -> 7.2` (`+0.3`).

Reason: W1 now has a second real source-derived, schema-shaped,
validator-backed concept family with six coverage-countable tasks, same-signal
threshold pass, three transfer surfaces, repair focus, and L2/L3 route
readiness.

Aggregate conservative movement:

- W1-W12 Volume I Premium Product Readiness: `5.9 -> 6.0`.
- Content depth: `4.8 -> 4.9`.
- Overall Top-1 Readiness: `5.7 -> 5.8`.
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

- W1 Concept Family Migration Batch 1.

Active:

- W1 Coverage Expansion PR2.

Must-not-skip:

- Preserve both W1 positive controls:
  - `position_action_order`
  - `starting_hand_discipline`
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

- Remaining W1 families are not schema-backed:
  - `seat_role_orientation`
  - `card_board_orientation`
  - `bet_size_vocabulary_preview`
  - `world1_checkpoint_synthesis`
- Human novice QA is not executed.
- Poker correctness review is not executed.
- W1 payoff/progression proof is not certification-linked.

## 12. Score delta proposal

| Score area | Previous | Proposed | Delta | Reason |
| --- | ---: | ---: | ---: | --- |
| W1 readiness | 6.9 | 7.2 | +0.3 | Second W1 schema-backed concept family passes foundation and L2/L3 validation |
| W1-W12 readiness | 5.9 | 6.0 | +0.1 | W1 canonical coverage depth improved, but Volume I remains incomplete |
| Architecture | 8.1 | 8.1 | +0.0 | No new schema/tooling capability, just one more fixture/exporter path |
| Content depth | 4.8 | 4.9 | +0.1 | W1 content coverage breadth improved |
| Overall Top-1 | 5.7 | 5.8 | +0.1 | Product evidence improved inside the active W1-W12 scope |
| Learning effect | 6.0 | 6.0 | +0.0 | No human or cross-session learning measurement |
| Monetization readiness | 2.0 | 2.0 | +0.0 | No monetization work |

## 13. Evidence DoD status

Validation results:

- `dart format --set-exit-if-changed tools/content_factory_import_export_mvp_v1.dart test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: passed after formatting; 0 files changed on final run.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: passed; 22 tests passed.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: passed; wrote the new W1 starting-hand fixture with 6 tasks and 6 coverage-countable tasks.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json test/fixtures/content_factory_mvp/w1_starting_hand_discipline_migration_batch1_v1.json`: passed; world_1 coverage_ready=true, transfer_ready=true, repair_ready=true, route_admission=learner_playable_route_ready.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w1_starting_hand_discipline_migration_batch1_v1.json test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`: passed; both fixtures OK.
- `flutter analyze`: passed; no issues found.
- `graphify hook-check`: passed.
- `git diff --check`: passed.
- direct ASCII check: passed.
- direct trailing-whitespace/CRLF check: passed.

No screenshots.

## 14. Anti-theater check

What risk moved:

- W1 now has two independent schema-backed concept-family proofs instead of
  one. The new proof is code/test-backed and validator-backed.

What did not move:

- Full W1 certification did not complete.
- Human QA did not run.
- Poker correctness review did not run.
- W2-W6 did not become canonical coverage.
- W7-W12 did not open.
- Learning-effect and monetization readiness did not move.

Is this code/test-backed?

- Yes. The exporter, committed fixture, foundation validation, L2/L3 validation,
  and focused tests all back the batch.

Is PR2 needed?

- Yes. W1 still needs additional schema-backed family coverage before full
  certification. The next implementation slice should be `W1 Coverage Expansion
  PR2`, with `seat_role_orientation` as the likely low-risk next family unless
  a later prompt selects otherwise.
