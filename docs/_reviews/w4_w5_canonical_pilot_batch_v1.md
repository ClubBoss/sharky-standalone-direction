# W4-W5 Canonical Pilot Batch v1

Branch: `codex/w4-w5-canonical-pilot-batch-v1`.
Baseline: `3b4d0bbf` (`w4_w6_title_runtime_normalization_pr1_ready`).

## 1. Verdict

`w4_w5_canonical_pilot_batch_ready`

W4 and W5 now each have one honest six-task canonical pilot fixture after the
accepted W4-W6 title/runtime normalization:

- W4: `price_given_before_action` under Bet Purpose / Price.
- W5: `board_texture_classification` under Board Awareness.

This wave does not create W6 canonical evidence, does not inspect W7-W12, does
not reopen W1-W3, does not author new source content, and does not make launch,
9.0, 8.0, solver, monetization, UI, telemetry, or Human QA claims.

## 2. Source truth

Authority chain:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`.
- `docs/_reviews/w4_w6_title_runtime_normalization_pr1_v1.md`.
- `docs/_reviews/w4_w6_route_content_normalization_plan_v1.md`.
- `docs/_reviews/w1_w12_route_content_cascade_map_v1.md`.
- `content/worlds/world4/v1/world.md`.
- `content/worlds/world5/v1/world.md`.

Accepted normalized ownership remains:

- W4 = Bet Purpose / Price.
- W5 = Board Awareness.
- W6 = Range Thinking, excluded from this wave.

## 3. W4 source selection

Selected source family: `price_given_before_action`.

Reason:

- W4 source explicitly owns bet purpose and basic price awareness.
- The selected tasks are existing source tasks from W4 and all name value intent
  plus concrete action or price choices.
- The family proves the learner can read the purpose/price job before choosing
  the action or size.
- It is canonical-owned now because PR1 normalized the active W4 title to Bet
  Purpose / Price, resolving the earlier route-title/source-job blocker.

Selected source examples include:

- `content/worlds/world4/v1/sessions/w4.s01/drills/d.choose_half_pot_value.json`.
- `content/worlds/world4/v1/sessions/w4.s01/drills/d.choose_raise_value.json`.
- `content/worlds/world4/v1/sessions/w4.s07/drills/d.choose_pot_value_pressure_finish.json`.

## 4. W5 source selection

Selected source family: `board_texture_classification`.

Reason:

- W5 source explicitly owns board awareness, dry/wet/paired/connected texture
  recognition, and board-shift reasoning.
- The selected tasks are existing W5 texture classifier tasks.
- The family proves texture-first action selection without importing W6 range
  reasoning or later equity/pot-odds policy.
- It is canonical-owned now because PR1 normalized the active W5 title to Board
  Awareness, resolving the earlier route-title/source-job offset.

Selected source examples include:

- `content/worlds/world5/v1/sessions/w5.s01/drills/d.classify_texture_intro_dry_raise_v1.json`.
- `content/worlds/world5/v1/sessions/w5.s03/drills/d.classify_wet_protection_connected_call_v1.json`.
- `content/worlds/world5/v1/sessions/w5.s04/drills/d.classify_turn_shift_paired_fold_v1.json`.

## 5. Fixtures created

Created:

- `test/fixtures/content_factory_mvp/w4_price_given_before_action_canonical_pilot_v1.json`.
- `test/fixtures/content_factory_mvp/w5_board_texture_classification_canonical_pilot_v1.json`.

Factory/exporter updates:

- `tools/content_factory_import_export_mvp_v1.dart` exports both fixtures.
- `tools/content_schema_l2_l3_validator_v1.dart` adds
  `w4W5CanonicalPilotFixturePathsV1` so canonical pilot validation does not
  glob bridge fixtures.

Focused tests:

- `test/tools/content_factory_import_export_mvp_v1_test.dart`.
- `test/tools/content_schema_l2_l3_validator_v1_test.dart`.

## 6. Bridge preservation

Existing W4/W5 bridge fixtures remain bridge-limited:

- `w4_bridge_or_legacy_schema_migration_pilot_v1.json`.
- `w5_bridge_or_legacy_schema_migration_pilot_v1.json`.

Preserved bridge contract:

- `source_truth_status: bridge_or_legacy`.
- `safe_claim_status: limited_bridge`.
- `launch_coverage_claimed: false`.
- Bridge same-signal groups remain three-task claim-limited controls.

Validator negative controls prove:

- W4 canonical-only is route-ready.
- W5 canonical-only is route-ready.
- W4 bridge plus W4 canonical remains `bridge_or_legacy_limited`.
- W5 bridge plus W5 canonical remains `bridge_or_legacy_limited`.

## 7. Validation

Focused checks:

- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart --plain-name "exports W4 price given before action canonical pilot"`.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart --plain-name "exports W5 board texture classification canonical pilot"`.
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "reports W4 canonical pilot as route-ready coverage"`.
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "reports W5 canonical pilot as route-ready coverage"`.
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "keeps W4 bridge plus canonical pilot bridge-limited"`.
- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart --plain-name "keeps W5 bridge plus canonical pilot bridge-limited"`.
- `dart run tools/content_factory_import_export_mvp_v1.dart`.

Final Evidence DoD checks are recorded in section 12.

## 8. Claim safety

Claim safety holds:

- No 8.0 claim.
- No 9.0 claim.
- No launch-ready claim.
- No broad W4/W5 migration claim.
- No W6 canonical fixture or W6 range correctness review.
- No W7-W12 opening or source inspection.
- No bridge evidence counted as canonical.
- No UI, screenshots, telemetry, monetization, external dependencies, or
  `output/` changes.

## 9. Score / ledger impact

Conservative score movement:

- W4: `5.5 -> 5.9`.
- W5: `5.5 -> 5.9`.
- W1-W12 readiness: `7.3 -> 7.4`.
- Content depth: `5.7 -> 5.8`.

No movement:

- W1/W2/W3/W6-W12 world scores.
- Full W1-W36 long-horizon readiness.
- Overall top-1 readiness.
- Architecture scalability.
- Learning effect.
- Progression / dopamine.
- Monetization readiness.
- Human QA.
- Launch readiness.

## 10. Route impact

W4 and W5 now have one canonical-owned pilot family each after title/runtime
normalization. This proves a bounded source-aligned canonical path, not broad
world coverage.

W6 remains bridge-limited and excluded. W7-W10 remain locked. W11-W12 remain
authored but not routed.

## 11. Active repair queue update

Completed:

- `W4-W5 Canonical Pilot Batch v1`.

Recommended next wave:

- `W4-W5 Canonical Coverage Expansion PR2`.

Reason: one six-task pilot per world is enough to prove the normalized
canonical path exists, but not enough to attempt a bounded certification/payoff
gate by default.

## 12. Evidence DoD status

- `dart format` on touched Dart/test files: pass.
- Focused factory tests: pass.
- Focused L2/L3 validator tests: pass.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: pass.
- W4/W5 canonical foundation validators: pass.
- W4/W5 canonical L2/L3 validators: pass.
- W4/W5 bridge L2/L3 negative controls: pass.
- `flutter analyze`: pass.
- `graphify hook-check`: pass.
- `git diff --check`: pass.
- `git diff --cached --check`: pass.
- direct ASCII / diff-only ASCII: pass.
- trailing whitespace / CRLF / final-newline checks: pass.

No screenshots were taken.

## 13. Anti-theater check

Pass.

The two new fixtures are source-owned, six-task, validator-backed canonical
pilots. Bridge fixtures remain bridge-limited negative controls. The wave does
not turn one pilot per world into a launch, 8.0, 9.0, broad migration, or
learning-effect claim.

## 14. Next wave decision

`W4-W5 Canonical Coverage Expansion PR2`
