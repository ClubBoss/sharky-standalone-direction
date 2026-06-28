# W3 Canonical Coverage Expansion PR3 / Source-Truth Decision v1

Status: Accepted.
Date: 2026-06-29.
Verdict: `w3_canonical_coverage_expansion_pr3_source_truth_stop`.

## 1. Verdict

W3 should stop before adding a third canonical family.

No new W3 fixture is added in PR3. The remaining existing W3 source can support
useful drills, but it does not honestly produce a third distinct canonical
Position Thinking family without either duplicating the existing pilot,
repackaging PR2 hand-bucket/action-frame evidence, or converting bridge/source
material by metadata.

Next required wave:

`W3 Source/Title Realignment Plan`

This is not W3 8.0, W3 9.0, launch readiness, broad migration, Human QA, route
rename, W4-W6 migration, W7-W12 opening, monetization, telemetry, UI, or new
content authoring.

## 2. Source Truth

Focused authority and evidence inspected:

- `AGENTS.md`: repository boundary, SSOT order, Act0 boundary, graphify rules,
  and validation posture.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: W1-W12 launch scope,
  W1-W4 foundation framing, and top-1 constraints.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active W3 PR3 wave,
  score ledger, and route handoff state.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W3 score, blockers, and
  current evidence stack.
- `docs/_reviews/w3_canonical_coverage_expansion_pr2_v1.md`: accepted PR2
  baseline and explicit PR3 source-truth handoff.
- `docs/_reviews/w3_canonical_certification_pilot_v1.md`: accepted W3
  `position_sensitive_preflop_decision` canonical pilot.
- `docs/_reviews/w2_w6_canonical_bridge_decision_v1.md`: route/source mismatch
  policy for W2-W6.
- `docs/_reviews/w2_w6_bridge_coverage_expansion_v1.md`: W3 bridge negative
  control baseline.
- W3 source files under `content/worlds/world3/v1`, focused on existing source
  candidates only.
- Existing W3 fixtures:
  `w3_canonical_certification_pilot_v1.json`,
  `w3_hand_bucket_action_frame_canonical_pr2_v1.json`, and
  `w3_bridge_or_legacy_schema_migration_pilot_v1.json`.

Advisory navigation:

- `graphify query "W3 Canonical Coverage Expansion PR3 source truth Position Thinking hand bucket action frame bridge negative control"`

## 3. Current W3 State

W3 currently has two canonical concept families:

- `position_sensitive_preflop_decision`;
- `hand_bucket_action_frame_discipline`.

Canonical-only aggregate evidence remains valid:

- tasks: `12`;
- coverage-countable tasks: `12`;
- route admission: `learner_playable_route_ready`.

The bridge plus canonical aggregate remains a negative control:

- tasks: `15`;
- coverage-countable tasks: `15`;
- route admission: `bridge_or_legacy_limited`.

W3 remains below 8.0 because broad W3 is still mixed and blocked by
source-title reconciliation, poker correctness review, payoff/progression
proof, Human QA, and broad migration.

## 4. Candidate Source-Truth Matrix

| Candidate concept_family_id | Source tasks inspected | Alignment with W3 learner-facing job/title | Distinct from existing two canonical families | Task count | Transfer surface potential | Repair focus potential | Source/title risk | Decision | Reason |
| --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- |
| `preflop_framework_checkpoint` | `w3.s03 d.chain_preflop_checkpoint_v1`, `w3.s06 d.chain_preflop_mixed_context_checkpoint_v1`, plus bridge action-choice siblings | Partial. These are preflop framework checkpoint tasks under the learner-facing `Position Thinking` title. | No. They repeat PR2's hand bucket plus action-frame shape and overlap the existing bridge negative control. | 6 chain steps plus 2 bridge siblings inspected | Raise/call/fold surfaces exist, but they are the same action-frame surfaces PR2 and bridge already own. | Present as preflop-frame action default, but not a distinct W3 Position Thinking repair. | High if promoted to canonical by metadata. | reject | Promoting this would blur the bridge/canonical boundary and count preflop-framework evidence as Position Thinking breadth. |
| `premium_strong_action_frame_reps` | `w3.s04 d.chain_preflop_premium_strong_reps_v1` | Weak-to-partial. The source teaches premium/strong hand buckets through open/call/fold decisions. | No. It is a narrower hand-strength repeat of PR2. | 3 | Three surfaces only. | Present but same repair family as PR2. | Medium-high. | reject | It fails the five-task threshold by itself and becomes a PR2 duplicate if combined with neighboring hand-bucket chains. |
| `medium_weak_release_discipline` | `w3.s05 d.chain_preflop_medium_weak_discipline_v1` | Weak-to-partial. The source teaches medium/weak hand bucket discipline. | No. It is another hand-bucket/action-frame slice. | 3 | Three surfaces only. | Present but same repair family as PR2. | Medium-high. | reject | It is useful source, but not a distinct canonical Position Thinking family. |
| `unopened_position_open_fold` | `w3.s07 d.chain_preflop_open_fold_position_v1` | Good on position language, but narrow. | No. It duplicates the existing pilot's position-before-action and same-hand position-shift logic. | 3 | Button open, cutoff fold, weak button fold. | Present as position-before-preflop-action. | Medium. | reject | It cannot reach five tasks without merging into sessions 11-14, which are already the canonical pilot family. |
| `same_hand_different_action` | `w3.s09 d.chain_preflop_same_hand_different_action_v1` | Good on W3 title. | No. It is a direct variant of the existing pilot's same-hand/context shift proof. | 3 | Unopened button raise, facing-open call, cutoff fold. | Present as position/action-frame repair. | Medium. | reject | It is the strongest title-aligned leftover, but only three tasks and materially duplicates `position_sensitive_preflop_decision`. |
| Additional position chains | `w3.s11 d.chain_position_open_call_v1`, `w3.s12 d.chain_position_continue_fold_v1`, `w3.s13 d.chain_position_open_fold_v1`, `w3.s14 d.chain_position_sensitive_open_fold_v1` | Strong. | No. These are the accepted canonical pilot source family. | Enough source exists but already consumed. | Present. | Present. | Low. | reject | Reusing them would inflate coverage count without adding a new concept family. |

## 5. PR3 Decision

Path B selected: source/title realignment decision.

No third W3 canonical fixture is safe in this wave. The two accepted canonical
families should remain separated from the bridge fixture, and W3 should not
enter 8.0 review until a source/title realignment plan decides whether W3
should remain `Position Thinking`, absorb more preflop-framework content, or
route some source ownership elsewhere.

## 6. Fixture Output Summary

No fixture was created.

Intentionally untouched:

- `test/fixtures/content_factory_mvp/w3_canonical_certification_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w3_hand_bucket_action_frame_canonical_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json`
- `tools/content_factory_import_export_mvp_v1.dart`
- focused exporter and validator tests

## 7. L2/L3 Validation Results

Canonical-only W3 remains route-ready:

```text
content_schema_l2_l3_validator_v1: fixtures=2 worlds=1 tasks=12 coverage_countable=12
content_schema_l2_l3_validator_v1: world_3 tasks=12 coverage_countable=12 coverage_ready=true transfer_ready=true repair_ready=true route_admission=learner_playable_route_ready
content_schema_l2_l3_validator_v1: OK
```

Bridge plus canonical W3 remains bridge-limited:

```text
content_schema_l2_l3_validator_v1: fixtures=3 worlds=1 tasks=15 coverage_countable=15
content_schema_l2_l3_validator_v1: world_3 tasks=15 coverage_countable=15 coverage_ready=false transfer_ready=true repair_ready=true route_admission=bridge_or_legacy_limited
content_schema_l2_l3_validator_v1: OK
```

## 8. Test Coverage

No test code changed because no fixture, exporter, validator, or runtime
behavior changed.

The existing W3 validator evidence is still the relevant executable proof:

- canonical-only W3 remains `learner_playable_route_ready`;
- bridge plus canonical remains `bridge_or_legacy_limited`;
- bridge evidence is not counted as canonical launch coverage.

## 9. W3 Certification Impact

W3 8.0 review is not justified yet.

PR3 improves decision clarity but does not improve canonical breadth. W3 should
not be certified at 8.0 while the next honest blocker is source/title
realignment and the remaining candidates either duplicate existing canonical
families or sit inside the preflop-framework bridge/source mismatch.

## 10. Ledger Impact

Score delta proposal:

- W3: unchanged at `5.8`.
- W1-W12 Volume I Premium Product Readiness: unchanged at `7.0`.
- Content depth: unchanged at `5.6`.
- Architecture scalability: unchanged at `8.1`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.
- Overall top-1 readiness: unchanged at `6.3`.

Reason: this wave reduces route-selection ambiguity but adds no canonical
fixture, no new same-signal family, no payoff/progression proof, no Human QA,
no correctness certification, and no launch claim safety movement.

## 11. Route Impact

- No route changes.
- No learner-facing title changes.
- No W3 fixture changes.
- No bridge conversion.
- No W4-W6 migration.
- No W7-W12 opening.
- No W13-W36 launch dependency.

The active next wave should move to:

`W3 Source/Title Realignment Plan`

## 12. Active Repair Queue Update

Closed:

- W3 Canonical Coverage Expansion PR3 / Source-Truth Decision.

Active:

- W3 Source/Title Realignment Plan.

Must-not-skip:

- Preserve W3 bridge fixture as a negative control.
- Keep canonical-only and bridge-mixed L2/L3 checks separated.
- Do not enter W3 8.0 review until the source/title blocker is resolved or
  explicitly accepted as a bounded certification limitation.
- Do not treat early-session preflop-framework chains as new Position Thinking
  breadth by metadata only.

Deferred:

- Third W3 canonical family.
- W3 correctness review.
- W3 payoff/progression proof.
- W3 Human QA.
- Broad W3 migration.
- W4-W6 migration.
- W7-W12 opening.
- W13-W36 production.
- Monetization, telemetry expansion, UI, screenshots, store/public beta.

## 13. Evidence DoD Status

Required evidence posture for this docs-only stop:

- source candidates inspected;
- existing canonical and bridge fixtures inspected;
- canonical-only W3 L2/L3 validation preserved;
- bridge plus canonical W3 L2/L3 negative control preserved;
- no fixture/tooling/test changes made;
- ledger and long-horizon pointer updated to the source/title next wave;
- final formatting, graphify, diff, and text hygiene checks tracked in the
  final handoff.

## 14. Anti-Theater Check

Risk moved:

- W3 no longer has an ambiguous PR3 continuation path. The next blocker is now
  explicitly source/title realignment, not another coverage-expansion attempt.

Risk did not move:

- W3 canonical breadth remains two families.
- W3 correctness, payoff/progression, Human QA, launch readiness, learning
  effect, monetization, and broad migration remain unchanged.

This did not add canonical W3 coverage. It stopped for source truth.

W3 remains separated from bridge evidence because no bridge fixture changed and
mixed bridge plus canonical validation remains `bridge_or_legacy_limited`.

W3 8.0 review is not justified now. A PR4 coverage wave is not the next safe
move unless a source/title realignment plan first identifies a non-duplicative
canonical family or deliberately remaps the route/source ownership.
