# W2 Canonical Coverage Expansion PR2 v1

Status: ACCEPTED.
Created: 2026-06-28.

## 1. Verdict

`w2_canonical_coverage_expansion_pr2_one_family_ready`

PR2 adds one additional W2 canonical concept family from existing source tasks.
The secondary raise/pressure candidates remain deferred because their source
shape is broader than the safest Hand Discipline claim for this wave.

## 2. Source Truth

Inspected:

- `AGENTS.md`: active app boundary, graphify, and validation rules.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Volume I launch scope and
  W13-W36 deferral.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active next wave,
  score ledger, and blocker register.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W2 current readiness
  row, scoring rules, and bridge/canonical separation.
- `docs/_reviews/w2_canonical_certification_pilot_v1.md`: accepted W2 pilot
  evidence and negative-control rule.
- `docs/_reviews/w2_w6_canonical_bridge_decision_v1.md`: W2-W6 bridge vs
  canonical decision.
- `docs/_reviews/w2_w6_bridge_coverage_expansion_v1.md`: bridge fixture
  posture and launch-claim blocking.
- `docs/_reviews/w1_payoff_progression_certification_v1.md`: W1 technical 8.5
  benchmark and Human QA boundary.
- `test/fixtures/content_factory_mvp/w2_canonical_certification_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json`
- `tools/content_factory_import_export_mvp_v1.dart`
- `tools/content_schema_l2_l3_validator_v1.dart`
- `tools/content_schema_foundation_validator_v1.dart`
- `test/tools/content_factory_import_export_mvp_v1_test.dart`
- `test/tools/content_schema_l2_l3_validator_v1_test.dart`

Focused W2 sources inspected because they contain direct facing-price,
continue, and release prompts:

- `content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_call_facing_bet.json`
- `content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_fold_facing_bet.json`
- `content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_call_facing_open_price_ok.json`
- `content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_fold_facing_open_price_bad.json`
- `content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_call_bridge_tocall_price_ok.json`
- `content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_fold_bridge_tocall_price_bad.json`
- `content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_call_checkpoint_tocall_price_ok.json`
- `content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_fold_checkpoint_tocall_price_bad.json`

Advisory navigation:

- `graphify query "W2 canonical coverage expansion PR2 Hand Discipline content factory source tasks same_signal transfer repair"`

## 3. Current W2 State

Before PR2:

- W2 had one canonical pilot family:
  `hand_discipline_position_price_defaults`.
- W2 bridge evidence remained `bridge_or_legacy_limited` and could not count as
  canonical launch coverage.
- W2 score was `5.1`.
- W2 was not 8.0, 9.0, launch-ready, or broad coverage-ready.

Remaining blockers before and after PR2:

- broad W2 canonical breadth;
- W2 poker correctness review;
- W2 payoff/progression proof;
- Human QA;
- bridge/canonical separation;
- no launch or 9.0 claim.

## 4. Batch Decision

Selected concept family:

`facing_price_continue_release_discipline`

Selected source tasks:

- call facing bet when price is acceptable;
- fold facing bet when price is poor;
- call facing open when price is okay;
- fold facing open when price is bad;
- call bridge toCall when price is okay;
- fold bridge toCall when price is bad;
- call checkpoint toCall when price is okay;
- fold checkpoint toCall when price is bad.

Why it aligns with Hand Discipline:

The tasks repeatedly ask the learner to continue when the offered price is
acceptable and release when the price is poor. That is a direct hand-discipline
continue/release decision, not a route title change or broad table-reading
claim.

Same-signal group:

`w2.hand_discipline.facing_price_continue_release`

Transfer surfaces:

- `facing_bet_price_continue_v1`
- `facing_bet_price_release_v1`
- `bridge_price_continue_v1`
- `bridge_price_release_v1`

Repair focus:

`facing_price_continue_release_discipline`

Safety decision:

Safe as one canonical W2 PR2 family. Not safe as a full W2 certification or
launch claim.

Intentionally not built:

- no raise/pressure PR2 family;
- no W2 bridge fixture conversion;
- no W3-W6 migration;
- no route/title change;
- no new source content.

## 5. Migration Output Summary

Output fixture:

`test/fixtures/content_factory_mvp/w2_facing_price_discipline_canonical_pr2_v1.json`

Summary:

- total tasks: 8
- coverage-countable tasks: 8
- `concept_family_id`: `facing_price_continue_release_discipline`
- `same_signal_group_id`: `w2.hand_discipline.facing_price_continue_release`
- `source_truth_status`: `migrated`
- `safe_claim_status`: `canonical_pilot`
- `launch_coverage_claimed`: `false`

Transfer distribution:

- `facing_bet_price_continue_v1`: 2
- `facing_bet_price_release_v1`: 2
- `bridge_price_continue_v1`: 2
- `bridge_price_release_v1`: 2

Repair distribution:

- `facing_price_continue_release_discipline`: 8

Validation result:

The fixture passes foundation validation and L2/L3 validation as canonical W2
coverage.

Claim safety:

This fixture is safe as canonical-pilot evidence only. It does not turn on
launch coverage claims.

## 6. L2/L3 Validation Results

PR2 fixture alone:

- `coverage_ready`: true
- `transfer_ready`: true
- `repair_ready`: true
- route admission: `learner_playable_route_ready`

W2 canonical pilot plus PR2:

- tasks: 14
- coverage-countable tasks: 14
- canonical concept families: 2
- `coverage_ready`: true
- `transfer_ready`: true
- `repair_ready`: true
- route admission: `learner_playable_route_ready`

W2 bridge plus canonical fixtures:

The bridge fixture remains separate and must still be evaluated as
`bridge_or_legacy_limited` when included. It is not mixed into canonical W2
coverage claims.

## 7. Test Coverage

- `exports W2 facing price discipline PR2 from real source tasks`: proves
  deterministic export, source paths, claim fields, transfer surfaces, repair
  focus, and action sequence.
- `reports W2 canonical PR2 facing price discipline as route-ready`: proves the
  PR2 fixture clears L2/L3 by itself.
- `reports W2 canonical pilot plus PR2 as multiple route-ready families`:
  proves W2 now has two canonical route-ready concept families without bridge
  evidence.
- Existing W2 bridge and canonical pilot tests remain active controls.

## 8. W2 Certification Impact

W2 now has two canonical concept families:

- `hand_discipline_position_price_defaults`
- `facing_price_continue_release_discipline`

W2 is closer to an 8.0 review candidate, but it is not at 8.0. The remaining
8.0 blockers are broader W2 canonical breadth, correctness review,
payoff/progression proof, and a deliberate certification review artifact.

W2 is not 9.0 or launch-grade because Human QA, full migration, durable
learning proof, and launch claim safety remain incomplete.

## 9. Ledger Impact

Recommended conservative movement:

- W2: `5.1 -> 5.4`
- W1-W12 Volume I Premium Product Readiness: `6.4 -> 6.5`
- Content depth: `5.2 -> 5.3`
- Architecture scalability: unchanged at `8.1`
- Overall Top-1 Readiness: unchanged at `6.2`
- Learning effect: unchanged at `6.0`
- Monetization readiness: unchanged at `2.0`

Reason:

One additional canonical W2 family materially reduces W2 coverage risk, but it
does not close correctness, payoff, Human QA, or broad W2 coverage.

## 10. Route Impact

- No runtime route changes.
- No learner-facing title changes.
- W3-W6 remain bridge-limited.
- W7-W12 remain closed/non-routed.
- W13-W36 remain deferred.

## 11. Active Repair Queue Update

Closed:

- W2 Canonical Coverage Expansion PR2.
- One additional W2 canonical concept family.
- Two-family W2 canonical L2/L3 proof.

Active:

- W2 Canonical Coverage Expansion PR3 / Source-Truth Decision.

Must-not-skip:

- Keep bridge evidence separated from canonical evidence.
- Keep launch coverage claims disabled until explicitly justified.
- Do not claim W2 8.0 from two canonical families.
- Run correctness, payoff/progression, and Human QA gates before higher claims.

Deferred:

- W3-W6 canonicalization.
- W7-W12 opening.
- W13-W36 launch dependency.
- Monetization.
- Telemetry.
- UI.
- Human QA execution.

Blockers:

- only two W2 canonical families;
- no W2 correctness review;
- no W2 payoff/progression proof;
- no Human QA;
- source/title realignment risk for broader W2-W6 remains.

## 12. Evidence DoD Status

Required checks for this wave:

- Dart format on touched Dart/test files.
- Focused Flutter tests for updated factory and L2/L3 tests.
- Factory regeneration.
- L2/L3 validation on W2 canonical fixtures.
- L2/L3 validation on bridge plus canonical fixtures.
- Foundation validation on W2 fixtures.
- Flutter analyze.
- graphify hook-check.
- git diff checks.
- direct ASCII and trailing-whitespace/CRLF checks.

No screenshots are required or produced.

## 13. Anti-Theater Check

Risk moved:

W2 now has two executable, validator-backed canonical concept families instead
of one.

Risk not moved:

W2 correctness, Human QA, payoff/progression, launch readiness, and broad
coverage remain open.

Did this add canonical W2 coverage or only document blockers?

It added canonical W2 coverage.

Did W2 remain separated from bridge evidence?

Yes. The bridge fixture remains `bridge_or_legacy_limited` and is not counted
inside the canonical claim.

Is PR3 needed?

Yes. PR3 should decide whether another W2 canonical source family is safe,
especially around raise/pressure candidates, or whether W2 source/title
realignment is the next honest step.
