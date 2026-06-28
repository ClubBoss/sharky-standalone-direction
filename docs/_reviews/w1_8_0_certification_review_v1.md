# W1 8.0 Certification Review v1

Status: ACCEPTED certification review artifact.
Date: 2026-06-28.

## 1. Verdict

`w1_8_0_certification_passed`

W1 legitimately holds `8.0` as a certification-review-passed candidate. It is
not launch-ready, not 9.0, and not 10.0.

## 2. Source truth

Inspected docs and why:

- `AGENTS.md`: repo scope, Act0 route truth, graphify, and validation rules.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  active app boundary.
- `docs/plan/MASTER_PLAN_v3.0.md`: day-to-day product priority and older
  product-route context.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: top-1 strategy, W1-W12
  launch target, and external claim boundaries.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active long-horizon
  route ledger and current W1 certification pointer.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W1 score, scoring rules,
  current blockers, and next required action.
- `docs/_reviews/w1_coverage_expansion_pr3_v1.md`: accepted six-family W1
  coverage candidate and explicit fixture-scope note.
- `docs/_reviews/w1_coverage_expansion_pr2_v1.md`: accepted seat-role and
  card-board W1 coverage evidence.
- `docs/_reviews/w1_concept_family_migration_batch1_v1.md`: accepted
  starting-hand W1 coverage evidence.
- `docs/_reviews/w1_full_coverage_certification_plan_v1.md`: original W1
  certification ladder and 8.0/9.0/10.0 bars.
- `docs/_reviews/l2_l3_content_validator_expansion_v1.md`: L2/L3 coverage and
  L3 route-admission contract.

Inspected tools, tests, and fixtures and why:

- `tools/content_factory_import_export_mvp_v1.dart`: W1 fixture exporter source
  and W1 fixture family definitions.
- `tools/content_schema_l2_l3_validator_v1.dart`: explicit
  `w1ContentFactoryCoverageFixturePathsV1` and L2/L3 validation semantics.
- `tools/content_schema_foundation_validator_v1.dart`: foundation field/value
  validation.
- `test/tools/content_factory_import_export_mvp_v1_test.dart`: deterministic
  W1 export and foundation validation controls.
- `test/tools/content_schema_l2_l3_validator_v1_test.dart`: positive W1 family
  controls, aggregate 36-count control, L1 tiny-sample exclusion, and route
  claim-safety controls.
- W1 factory fixtures under `test/fixtures/content_factory_mvp/`: direct W1
  schema evidence for the current certification decision.

## 3. Current W1 evidence

Concept families:

- `position_action_order`
- `starting_hand_discipline`
- `seat_role_orientation`
- `card_board_orientation`
- `bet_size_vocabulary_preview`
- `world1_checkpoint_synthesis`

Fixture paths:

- `test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w1_starting_hand_discipline_migration_batch1_v1.json`
- `test/fixtures/content_factory_mvp/w1_seat_role_orientation_migration_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w1_card_board_orientation_migration_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w1_bet_size_vocabulary_preview_migration_pr3_v1.json`
- `test/fixtures/content_factory_mvp/w1_checkpoint_synthesis_migration_pr3_v1.json`

Task counts:

- Six intended W1 L2/L3 coverage fixtures.
- 36 total tasks.
- 36 coverage-countable tasks.
- Six same-signal groups, each with six coverage-countable tasks.
- Every counted task is `preview_only: false`, `source_truth_status: migrated`,
  `validation_status: source_validated`, and `route_gate_status:
  learner_playable`.

L2/L3 status:

- `dart run tools/content_schema_l2_l3_validator_v1.dart` over the six intended
  W1 coverage fixtures reports:
  - `fixtures=6`
  - `worlds=1`
  - `tasks=36`
  - `coverage_countable=36`
  - `coverage_ready=true`
  - `transfer_ready=true`
  - `repair_ready=true`
  - `route_admission=learner_playable_route_ready`
  - `OK`

Foundation validation status:

- `dart run tools/content_schema_foundation_validator_v1.dart` over all W1
  factory fixtures, including the L1 tiny sample, reports `OK` for each
  fixture.
- The L1 tiny sample is foundation-valid but intentionally excluded from the
  L2/L3 W1 coverage fixture list.

Route status:

- W1 remains the only canonical route-safe learner-playable world with real
  source-derived L2/L3 coverage evidence.
- W2-W6 remain bridge_or_legacy limited and are not canonical launch coverage.
- W7-W10 remain locked.
- W11-W12 remain authored but not routed.
- W13-W36 remain deferred/post-launch and not launch-available.

## 4. W1 8.0 certification matrix

| Certification dimension | Evidence | Pass/Conditional/Fail | Remaining risk | Required next action |
| --- | --- | --- | --- | --- |
| concept-family breadth | Six W1 concept families have real schema-backed fixtures. | Pass | Broad W1 source is not fully schema migrated. | Preserve the six-family set during later correctness review. |
| schema-backed coverage | Foundation validator passes W1 factory fixtures; L2/L3 passes six intended W1 coverage fixtures. | Pass | The current proof is fixture-backed, not full W1 source ownership. | Keep fixture list explicit and avoid glob-based coverage claims. |
| same-signal coverage | Six same-signal groups pass at six coverage-countable tasks each. | Pass | Same-signal proof covers selected families, not every W1 source task. | Review poker correctness inside each certified same-signal group. |
| transfer coverage | Each certified family has at least two transfer surfaces; aggregate L2/L3 reports `transfer_ready=true`. | Pass | Transfer is schema-present, not yet human-validated learning transfer. | Pair correctness review with later human QA and transfer proof. |
| repair coverage | Every counted family has repair focus coverage; aggregate L2/L3 reports `repair_ready=true`. | Pass | Repair behavior is not yet externally observed for the full route. | Keep repair-focus evidence in the human QA protocol. |
| fixture-scope safety | `w1ContentFactoryCoverageFixturePathsV1` excludes `w1_import_export_sample_v1.json`; test coverage enforces the exclusion. | Pass | Future agents could reintroduce unsafe broad globs. | Keep the explicit fixture list as the W1 coverage authority. |
| route safety | L2/L3 reports W1 `learner_playable_route_ready`; W2-W6 bridge limits and W7+ route gates remain closed. | Pass | No new route was opened by this review. | Do not use this decision to admit W2-W12. |
| claim safety | Prior docs and validators frame W1 as an 8.0 candidate, not launch-ready; bridge and W13+ overclaims are blocked by tests. | Pass | External/public copy is not reviewed for 9.0/10.0 claims. | Keep external claim-safety blocked until correctness, QA, and payoff proof pass. |
| poker correctness | Fixture tasks are source-derived and `source_validated`, but no poker correctness protocol has run. | Conditional | This is the largest remaining W1 9.0 risk. | Run `W1 Poker Correctness Review Protocol`. |
| human QA | Human novice QA is not executed. | Conditional | No evidence that a novice understands the route unaided. | Run `W1 Human QA Protocol` after or alongside correctness review. |
| payoff/progression | W1 has strong product payoff evidence, but certification-linked payoff/progression proof is not complete. | Conditional | Learning effect and completion payoff are not tied to certified family progress. | Follow correctness/QA with W1 payoff/progression certification. |

## 5. W1 8.0 decision

W1 legitimately holds `8.0` because it now satisfies the conservative 8.0 bar:

- multiple schema-backed W1 concept families;
- L2/L3 coverage proof over intended W1 coverage fixtures;
- same-signal, transfer, and repair fields present across the certified family
  set;
- explicit L1 tiny-sample exclusion from L2 coverage claims;
- route safety limited to W1;
- no evidence of false launch-ready claims in the inspected W1 certification
  chain.

The decision is bounded. `8.0` means W1 is a launch-grade candidate with strong
schema and validator proof. It does not mean full W1 coverage, poker
correctness, human QA, learning-effect proof, or public launch readiness.

## 6. What blocks W1 9.0

W1 cannot move to 9.0 until these gates are satisfied:

- poker correctness review for the six certified W1 concept families;
- human novice QA over the certified W1 route or representative route sample;
- payoff/progression proof tied to certified concept-family progress;
- content/copy review for bet-size vocabulary preview so W1 does not imply
  sizing mastery;
- no unresolved P0/P1 issue in the certified W1 fixture set.

## 7. What blocks W1 10.0

W1 cannot move to 10.0 until these gates are satisfied:

- complete W1 coverage map is schema-owned and validator-backed;
- full poker correctness proof has passed;
- human QA pass exists and is recorded;
- learning-effect confidence exists beyond schema presence;
- progression/payoff proof is tied to real W1 completion and repair outcomes;
- release claim-safety is reviewed against public/store copy;
- no known P0/P1 content blockers remain.

## 8. Next implementation decision

Chosen next wave:

`W1 Poker Correctness Review Protocol`

Reason:

- The schema and validator risks required for 8.0 moved enough to pass.
- The highest remaining 9.0 risk is whether the certified W1 advice, especially
  starting-hand and bet-size vocabulary tasks, is poker-correct and
  claim-safe.
- Human QA is also a hard gate, but it is less efficient to ask novice testers
  to review content before the poker advice and copy boundaries are formally
  checked.

Not selected:

- `W1 Human QA Protocol`: still required, but better after correctness review.
- `W1 Payoff/Progression Certification`: still required, but depends on safe
  correctness and QA framing.
- `W1 PR4 Coverage Patch`: not justified by current evidence; no 8.0 coverage
  gap was found.
- `W2-W6 Canonical Realignment Plan`: premature until W1 8.0 is certified and
  W1's 9.0 blockers are explicitly queued.

## 9. Ledger impact

- W1 score remains `8.0`.
- No score movement is proposed.
- W1's next required action should move from `W1 8.0 Certification Review` to
  `W1 Poker Correctness Review Protocol`.
- W1-W12 Volume I Premium Product Readiness remains `6.2`.
- Overall Top-1 Readiness remains `6.0`.
- Learning effect remains `6.0`.
- Monetization readiness remains `2.0`.

## 10. Route impact

- No route changes.
- No learner-facing title changes.
- W2-W6 remain bridge-limited.
- W7-W12 remain closed/non-routed according to the current route truth split.
- W13-W36 remain deferred/post-launch.

## 11. Active repair queue update

Closed:

- W1 8.0 certification decision.
- Six-family W1 fixture-scope review.
- L1 tiny-sample exclusion review.

Active:

- W1 Poker Correctness Review Protocol.

Must-not-skip:

- Human novice QA.
- Certification-linked payoff/progression proof.
- Explicit fixture-list preservation.
- External claim-safety review before launch/store copy.

Deferred:

- W1 PR4 coverage patch unless correctness review finds a concrete content gap.
- W2-W6 canonical realignment.
- W7-W12 admission.
- W13-W36 expansion.
- Monetization, telemetry, UI, Modern Table, and store/public beta work.

Blockers:

- No human QA participants were run in this wave.
- No L4 poker correctness review was run in this wave.
- No complete W1 source migration was performed.

## 12. Evidence DoD status

Completed:

- `dart run tools/content_schema_l2_l3_validator_v1.dart` over intended W1
  coverage fixtures: PASS.
- `dart run tools/content_schema_foundation_validator_v1.dart` over W1 factory
  fixtures: PASS.
- Existing `test/tools/content_schema_l2_l3_validator_v1_test.dart` includes
  the explicit aggregate W1 coverage fixture list test and L1 sample exclusion
  test.
- `graphify hook-check`: PASS.
- `git diff --check`: PASS.
- Direct ASCII check over changed docs: PASS.
- Direct trailing-whitespace/CRLF check over changed docs: PASS.

No tooling or Dart test changes were made, so no new Dart tests, `dart format`,
focused Flutter test, or `flutter analyze` are required for this docs-only
certification wave.

## 13. Anti-theater check

What risk moved?

- W1's 8.0 decision risk moved from candidate to certified-passed because the
  six-family schema, L2/L3, route-safety, claim-safety, and fixture-scope
  evidence was checked directly.

What did not move?

- Poker correctness, human QA, full W1 migration, learning-effect confidence,
  payoff/progression proof, W2-W6 bridge limits, W7-W12 route locks,
  monetization, telemetry, UI, Modern Table, store/public beta, and W13-W36 did
  not move.

Is this docs-only or code/test-backed?

- This wave is docs-only, backed by existing validator commands and existing
  tests. No new tooling was needed.

Does this justify W1 8.0?

- Yes. It justifies W1 `8.0` as a certification-passed candidate, not as
  launch-ready or externally claimable mastery.

What is the fastest safe next step toward W1 9.0?

- `W1 Poker Correctness Review Protocol`.
