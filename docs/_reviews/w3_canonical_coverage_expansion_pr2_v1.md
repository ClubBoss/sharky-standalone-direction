# W3 Canonical Coverage Expansion PR2 v1

Status: Accepted.
Date: 2026-06-29.
Verdict: `w3_canonical_coverage_expansion_pr2_one_family_ready`.

## 1. Verdict

W3 PR2 adds a second honest schema-backed canonical concept family:
`hand_bucket_action_frame_discipline`.

This is still not W3 8.0, 9.0, launch-ready, broad W3 migration, W4-W6
migration, or route-title realignment. It proves that a second existing W3
source cluster can be canonicalized while the bridge fixture remains separated
and claim-limited.

## 2. Source Truth

Inspected focused authority and evidence:

- `AGENTS.md`: repo scope, active SSOT order, Act0/route boundaries, and test
  policy.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: document authority map.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: W3 launch-facing title and
  locked W1-W4 free-foundation boundary.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active next wave and
  long-horizon score state.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W3 score, blockers, and
  next required action.
- `docs/_reviews/w3_canonical_certification_pilot_v1.md`: accepted W3 pilot
  scope and negative-control rule.
- `docs/_reviews/w2_8_0_certification_closure_v1.md`: bounded W2 closure and
  W3 follow-on rationale.
- `docs/_reviews/w2_w6_canonical_bridge_decision_v1.md`: bridge/canonical
  separation and W3 source-title risk.
- `docs/_reviews/w2_w6_bridge_coverage_expansion_v1.md`: W3 bridge fixture
  baseline.
- `docs/_reviews/w1_w6_schema_migration_pilot_v1.md`: schema migration
  precedent.
- `test/fixtures/content_factory_mvp/w3_canonical_certification_pilot_v1.json`:
  existing canonical positive control.
- `test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json`:
  existing bridge negative control.
- W3 source files under `content/worlds/world3/v1`, limited to sessions used or
  assessed for this PR2 decision.
- `tools/content_factory_import_export_mvp_v1.dart`,
  `tools/content_schema_l2_l3_validator_v1.dart`,
  `tools/content_schema_foundation_validator_v1.dart`, and focused tests.

## 3. Current W3 State

Before PR2, W3 had:

- one canonical pilot fixture:
  `w3_canonical_certification_pilot_v1.json`;
- one bridge negative-control fixture:
  `w3_bridge_or_legacy_schema_migration_pilot_v1.json`;
- W3 score `5.5`;
- active next action `W3 Canonical Coverage Expansion PR2`;
- remaining blockers: broad migration, correctness review, payoff/progression
  proof, Human QA, durable learning proof, and unresolved source/title risk.

## 4. Candidate Source-Truth Matrix

| Candidate concept_family_id | Source tasks inspected | Alignment with W3 learner-facing job/title | Distinct from existing pilot | Task count | Transfer surface potential | Repair focus potential | Source/title risk | Decision | Reason |
| --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- |
| `hand_bucket_action_frame_discipline` | `w3.s01 d.chain_preflop_framework_intro_v1`, `w3.s02 d.chain_preflop_category_reuse_v1`, `w3.s08 d.chain_preflop_continue_fold_discipline_v1`, `w3.s10 d.chain_preflop_final_checkpoint_v1` | Good enough for PR2: source asks learners to combine hand bucket, position/basic context, and action frame into compact open/call/fold decisions under the W3 `Position Thinking` route title. | Yes. Existing pilot is `position_sensitive_preflop_decision` and starts from reading position before action. This candidate starts from hand bucket plus preflop action frame. | 6 | Six surfaces: unopened premium open, facing-open playable call, out-of-position weak release, facing-open weak release, facing-open suited continue, earlier-position weak release. | Strong: `hand_bucket_before_preflop_action`. | Medium. It uses the W3 preflop-framework source job under the `Position Thinking` route title, so broad W3 still needs source-title review before 8.0. | migrate | Meets the five-task, two-transfer, repair-focus, source metadata, beginner-safe, and no-GTO requirements. |
| `preflop_framework_bridge` | Existing W3 bridge fixture source tasks from W3 sessions 3, 6, and 10. | Partial only; it is explicitly bridge-limited. | No. Already owned by bridge negative control. | 3 | Three bridge surfaces. | Present but bridge-limited. | High if converted by metadata only. | reject | Converting the bridge fixture would violate the prompt and erase the negative control. |
| Additional position chains | W3 sessions 11-14. | Strong title alignment. | No for PR2. | Enough source exists, but already used for the pilot family. | Present. | Present. | Low. | defer | Further position-chain reuse would duplicate the existing pilot family instead of adding a distinct second family. |

## 5. PR2 Decision

Second canonical family added.

The fixture is intentionally narrow and source-backed. It does not claim broad
W3 coverage, W3 8.0, or launch readiness.

## 6. Migration Output Summary

Output fixture:

- `test/fixtures/content_factory_mvp/w3_hand_bucket_action_frame_canonical_pr2_v1.json`

Source files:

- `content/worlds/world3/v1/sessions/w3.s01/drills/d.chain_preflop_framework_intro_v1.json`
- `content/worlds/world3/v1/sessions/w3.s02/drills/d.chain_preflop_category_reuse_v1.json`
- `content/worlds/world3/v1/sessions/w3.s08/drills/d.chain_preflop_continue_fold_discipline_v1.json`
- `content/worlds/world3/v1/sessions/w3.s10/drills/d.chain_preflop_final_checkpoint_v1.json`

Output summary:

- total tasks: 6;
- coverage-countable tasks: 6;
- `concept_family_id`: `hand_bucket_action_frame_discipline`;
- `same_signal_group_id`: `w3.position_thinking.hand_bucket_action_frame`;
- `transfer_surface_id` distribution: six distinct surfaces, one task each;
- `repair_focus_id`: `hand_bucket_before_preflop_action`, six tasks;
- `source_truth_status`: `migrated`;
- `safe_claim_status`: `canonical_pilot`;
- `launch_coverage_claimed=false`;
- foundation validation: passed.

## 7. L2/L3 Validation Results

PR2 fixture alone:

```text
content_schema_l2_l3_validator_v1: fixtures=1 worlds=1 tasks=6 coverage_countable=6
content_schema_l2_l3_validator_v1: world_3 tasks=6 coverage_countable=6 coverage_ready=true transfer_ready=true repair_ready=true route_admission=learner_playable_route_ready
content_schema_l2_l3_validator_v1: OK
```

W3 canonical-only aggregate:

```text
content_schema_l2_l3_validator_v1: fixtures=2 worlds=1 tasks=12 coverage_countable=12
content_schema_l2_l3_validator_v1: world_3 tasks=12 coverage_countable=12 coverage_ready=true transfer_ready=true repair_ready=true route_admission=learner_playable_route_ready
content_schema_l2_l3_validator_v1: OK
```

W3 bridge plus canonical negative control:

```text
content_schema_l2_l3_validator_v1: fixtures=3 worlds=1 tasks=15 coverage_countable=15
content_schema_l2_l3_validator_v1: world_3 tasks=15 coverage_countable=15 coverage_ready=false transfer_ready=true repair_ready=true route_admission=bridge_or_legacy_limited
content_schema_l2_l3_validator_v1: OK
```

## 8. Test Coverage

Added/extended focused tests for:

- deterministic PR2 exporter output;
- six unique PR2 task IDs;
- W3 route/title/content-owner metadata;
- migrated source truth and canonical pilot claim status;
- concept family, same-signal group, repair focus, transfer surfaces, and
  correct-action sequence;
- preserved chain metadata and step indexes;
- PR2 fixture L2/L3 route readiness;
- W3 canonical aggregate route readiness;
- W3 bridge plus canonical aggregate remaining bridge-limited.

## 9. W3 Certification Impact

W3 now has two canonical concept families:

- `position_sensitive_preflop_decision`;
- `hand_bucket_action_frame_discipline`.

W3 is closer to an 8.0 review but not ready for one yet. W3 8.0 remains blocked
by broad source-title risk, no fixture-level correctness review, incomplete
canonical breadth, no W3-specific payoff/progression proof, no Human QA, and
the remaining bridge-limited W3 fixture.

W3 9.0 and launch-grade remain blocked by Human QA, durable learning proof,
launch claim review, and broad migration.

## 10. Ledger Impact

Conservative score movement:

- W3: `5.5 -> 5.8`.
- W1-W12 Volume I Premium Product Readiness: `6.9 -> 7.0`.
- Content depth: `5.5 -> 5.6`.
- Architecture scalability: unchanged at `8.1`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.
- Overall top-1 readiness: unchanged at `6.3`.

Reason: a second W3 canonical family reduces W3 content-depth and route-ready
schema risk, but it does not close correctness, payoff/progression, Human QA,
launch, or broad migration risk.

## 11. Route Impact

- No route changes.
- No learner-facing title changes.
- W4-W6 remain bridge-limited.
- W7-W12 remain closed/non-routed.
- W13-W36 remain post-launch/deferred.
- Existing W3 bridge evidence remains separated from canonical evidence.

## 12. Active Repair Queue Update

Closed:

- W3 Canonical Coverage Expansion PR2.

Active:

- W3 Canonical Coverage Expansion PR3 / Source-Truth Decision.

Must-not-skip:

- Keep W3 bridge fixture as a negative control.
- Preserve canonical-only and bridge-mixed L2/L3 checks.
- Run correctness/payoff review before W3 8.0.

Deferred:

- Broad W3 migration.
- W4-W6 migration.
- W7-W12 opening.
- W13-W36 production.
- Human QA execution.
- Monetization, telemetry expansion, UI, screenshots, store/public beta.

Blockers:

- W3 source/title risk remains broad-world blocker.
- W3 payoff/progression proof is not certified.
- Human QA is still not executed.

## 13. Evidence DoD Status

- `dart run tools/content_factory_import_export_mvp_v1.dart`: passed.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w3_hand_bucket_action_frame_canonical_pr2_v1.json`: passed.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w3_canonical_certification_pilot_v1.json test/fixtures/content_factory_mvp/w3_hand_bucket_action_frame_canonical_pr2_v1.json`: passed.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w3_hand_bucket_action_frame_canonical_pr2_v1.json`: passed.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w3_canonical_certification_pilot_v1.json test/fixtures/content_factory_mvp/w3_hand_bucket_action_frame_canonical_pr2_v1.json`: passed.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w3_canonical_certification_pilot_v1.json test/fixtures/content_factory_mvp/w3_hand_bucket_action_frame_canonical_pr2_v1.json`: passed.
- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: passed.

Final formatting, analyzer, graphify, diff, and text hygiene checks are tracked
in the commit/final handoff.

## 14. Anti-Theater Check

Risk moved:

- W3 now has two source-backed canonical concept families with preserved source
  metadata and route-ready canonical-only L2/L3 evidence.

Risk did not move:

- W3 correctness, payoff/progression, Human QA, launch readiness, learning
  effect, monetization, and broad migration.

This added canonical W3 coverage. It did not convert bridge evidence.

W3 remains separated from bridge evidence because the mixed bridge plus
canonical aggregate still reports `coverage_ready=false` and
`route_admission=bridge_or_legacy_limited`.

W3 8.0 review is closer, but PR3/source-truth decision is needed before a clean
8.0 review gate.
