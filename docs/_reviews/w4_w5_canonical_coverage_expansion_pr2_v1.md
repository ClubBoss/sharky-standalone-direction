# W4-W5 Canonical Coverage Expansion PR2 v1

Status: REVIEW ARTIFACT.
Branch: `codex/w4-w5-canonical-coverage-expansion-pr2-v1`.
Baseline: `d91c694f` (`w4_w5_canonical_pilot_batch_ready`).
Verdict: `w4_w5_canonical_coverage_expansion_pr2_ready`.

## 1. Verdict

W4-W5 Canonical Coverage Expansion PR2 is ready.

This wave adds one additional existing-source canonical family for W4 and one
additional existing-source canonical family for W5. It does not create W6
canonical evidence, does not open W7-W12, does not author new content, and does
not make launch, 8.0, 9.0, Human QA, monetization, or broad W4-W6 claims.

## 2. Source truth

Authority chain used:

- `AGENTS.md`.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`.
- `docs/_reviews/w4_w5_canonical_pilot_batch_v1.md`.
- Existing W4/W5 bridge and canonical pilot fixtures.
- Focused W4 and W5 source task files only.

The accepted route/title normalization is preserved:

- W4 route title: `Bet Purpose / Price`.
- W5 route title: `Board Awareness`.
- W6 remains bridge-limited and excluded from this wave.

## 3. W4 PR2 Source Selection

Selected W4 family: `intent_action_discipline`.

This is source-honest under W4 Bet Purpose / Price because the selected tasks
ask the learner to choose the action that matches the stated betting purpose.
It is distinct from the existing W4 pilot, `price_given_before_action`, which
tests choosing a price after the action/purpose frame is already fixed.

Selected source tasks:

- `content/worlds/world4/v1/sessions/w4.s01/drills/d.choose_raise_protection.json`
- `content/worlds/world4/v1/sessions/w4.s02/drills/d.choose_raise_bluff.json`
- `content/worlds/world4/v1/sessions/w4.s02/drills/d.choose_raise_denial.json`
- `content/worlds/world4/v1/sessions/w4.s02/drills/d.choose_call_control.json`
- `content/worlds/world4/v1/sessions/w4.s03/drills/d.choose_raise_bluff.json`
- `content/worlds/world4/v1/sessions/w4.s05/drills/d.choose_raise_repeat.json`

Fixture contract:

- fixture: `test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json`
- route/world: `world_4`
- display title: `Bet Purpose / Price`
- source truth: `migrated`
- claim status: `canonical_pr2`
- launch coverage claimed: `false`
- same-signal group: `w4.bet_purpose_price.intent_action_discipline`
- repair focus: `purpose_before_action`
- transfer surfaces: `protection_raise_action_v1`, `bluff_raise_action_v1`,
  `denial_raise_action_v1`, `denial_control_call_v1`

## 4. W5 PR2 Source Selection

Selected W5 family: `board_shift_awareness`.

This is source-honest under W5 Board Awareness because the selected turn and
river tasks ask the learner to recognize board-state shifts or closure and
choose the matching action. It is distinct from the existing W5 pilot,
`board_texture_classification`, which tests broad texture recognition before
later-street shift decisions.

Selected source tasks:

- `content/worlds/world5/v1/sessions/w5.s04/drills/d.classify_turn_shift_connected_raise_v1.json`
- `content/worlds/world5/v1/sessions/w5.s04/drills/d.classify_turn_shift_wet_call_v1.json`
- `content/worlds/world5/v1/sessions/w5.s04/drills/d.classify_turn_shift_paired_fold_v1.json`
- `content/worlds/world5/v1/sessions/w5.s05/drills/d.classify_river_closure_connected_call_v1.json`
- `content/worlds/world5/v1/sessions/w5.s05/drills/d.classify_river_closure_dry_fold_v1.json`
- `content/worlds/world5/v1/sessions/w5.s05/drills/d.classify_river_closure_wet_raise_v1.json`

Fixture contract:

- fixture: `test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- route/world: `world_5`
- display title: `Board Awareness`
- source truth: `migrated`
- claim status: `canonical_pr2`
- launch coverage claimed: `false`
- same-signal group: `w5.board_awareness.board_shift_awareness`
- repair focus: `board_shift_before_action`
- transfer surfaces: `turn_connected_pressure_v1`, `turn_wet_control_v1`,
  `turn_paired_release_v1`, `river_connected_control_v1`,
  `river_dry_missed_release_v1`, `river_wet_pressure_v1`

## 5. Fixtures Created

Created:

- `test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`

Exporter/test changes:

- Added deterministic exporter functions for both fixtures.
- Added both fixtures to the W4-W5 PR2 validator fixture list.
- Added factory tests for metadata, source paths, actions, repair focus,
  same-signal grouping, transfer surfaces, and deterministic output.
- Added L2/L3 validator tests for individual route-ready reporting and
  bridge-plus-canonical negative controls.

## 6. Bridge Preservation

Bridge preservation is explicit.

- Existing W4 and W5 bridge fixtures remain `bridge_or_legacy`.
- Existing W4 and W5 canonical pilot fixtures remain unchanged.
- New PR2 fixtures use `source_truth_status=migrated`.
- New PR2 fixtures use `safe_claim_status=canonical_pr2`.
- New PR2 fixtures keep `launch_coverage_claimed=false`.
- Canonical-only W4/W5 PR2 evidence reports route-ready.
- Bridge plus canonical W4/W5 evidence remains `bridge_or_legacy_limited`.

## 7. Validation

Focused red checks were observed before implementation:

- W4 factory PR2 test failed before exporter creation.
- W5 factory PR2 test failed before exporter creation.
- W4/W5 L2 PR2 tests failed before validator fixture-list and generated
  fixture creation.

Focused passing evidence after implementation:

- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart --plain-name "exports W4 intent action discipline canonical PR2"`
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart --plain-name "exports W5 board shift awareness canonical PR2"`
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "reports W4 canonical PR2 as route-ready coverage"`
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "reports W5 canonical PR2 as route-ready coverage"`
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "reports W4-W5 canonical PR2 fixture list as route-ready by world"`
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "keeps W4 bridge plus canonical pilot and PR2 bridge-limited"`
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "keeps W5 bridge plus canonical pilot and PR2 bridge-limited"`
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart`
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart`
- `dart run tools/content_factory_import_export_mvp_v1.dart`
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w4_price_given_before_action_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_board_texture_classification_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w4_price_given_before_action_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_texture_classification_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`

Final DoD checks are recorded in section 12.

## 8. Claim Safety

Claim safety is bounded.

- W4 and W5 each gain one additional canonical family.
- W4 and W5 remain below 8.0.
- No launch coverage is claimed.
- No 9.0 claim is made.
- No Human QA claim is made.
- No W6 canonical claim is made.
- No W7-W12 route/content claim is made.
- No external dependency, monetization, UI, telemetry, screenshot, solver, or
  GTO work is included.

## 9. Score / Ledger Impact

Conservative movement:

- W4: `5.9 -> 6.2`.
- W5: `5.9 -> 6.2`.
- W1-W12 readiness: `7.4 -> 7.5`.
- Content depth: `5.8 -> 5.9`.
- Overall top-1 readiness: unchanged at `6.4`.
- Architecture scalability: unchanged at `8.2`.
- Learning effect: unchanged at `6.0`.
- Progression/dopamine: unchanged at `6.4`.
- Monetization readiness: unchanged at `2.0`.

## 10. Route Impact

No runtime route, title, copy, navigation, monetization route, or launch surface
changed in this wave.

W4 remains `Bet Purpose / Price`.
W5 remains `Board Awareness`.
W6 remains bridge-limited.
W7-W12 remain closed/non-routed.

## 11. Active Repair Queue Update

Completed current wave:

- `W4-W5 Canonical Coverage Expansion PR2`

Recommended next wave:

- `W4-W5 Certification / Payoff Gate v1`

Reason: W4 and W5 now each have two source-honest, validator-backed canonical
families. The next honest gate is certification/payoff review, not more breadth
churn, W6 canonicalization, or broad W4-W6 migration.

## 12. Evidence DoD Status

Passed local DoD:

- `dart format tools/content_factory_import_export_mvp_v1.dart tools/content_schema_l2_l3_validator_v1.dart test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`
- `dart run tools/content_factory_import_export_mvp_v1.dart`
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart`
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart`
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w4_price_given_before_action_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_board_texture_classification_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w4_price_given_before_action_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w4_intent_action_discipline_canonical_pr2_v1.json test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_texture_classification_canonical_pilot_v1.json test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`
- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`
- direct ASCII / diff-only ASCII
- trailing whitespace / CRLF / final-newline checks

## 13. Anti-Theater Check

This is not theater because both new fixture families are generated from
existing source tasks, preserve route/world/title metadata, pass foundation and
L2/L3 validation, and keep bridge evidence as a negative control.

This is still bounded because W4/W5 correctness certification,
payoff/progression proof, Human QA, broad migration, and launch claim safety
remain incomplete.

## 14. Next Wave Decision

Next wave selected:

`W4-W5 Certification / Payoff Gate v1`
