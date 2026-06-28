# W2-W6 Canonical/Bridge Decision v1

Status: ACCEPTED decision artifact.
Date: 2026-06-28.
Branch: `codex/w2-w6-canonical-bridge-decision-v1`.
Baseline: `547625a3` (`docs: certify w1 payoff progression`).

## 1. Verdict

`w2_w6_canonical_bridge_decision_ready`

Decision:

- W2-W6 cannot become launch-grade while remaining `bridge_or_legacy`.
- Current W2-W6 bridge fixtures are useful migration and claim-safety proof, not
  canonical launch coverage.
- No route title, learner-facing title, route order, Act0 card state, W7-W12
  gate, content source, fixture, validator, UI, telemetry, monetization, or
  runtime behavior changes in this wave.
- The next active implementation wave should be:

`W2 Canonical Certification Pilot`

Rationale:

W2 is the first post-W1 learner route, has an existing three-task bridge pilot,
and is the smallest place to prove the W1-style canonical certification pattern
outside W1. Broad W2-W6 migration or route-title realignment would be premature
until one W2 canonical slice proves the path from bridge-limited evidence to
route-owned certification evidence.

## 2. Source Truth

Focused sources inspected:

- `AGENTS.md`: active repo boundary, Act0 route truth, graphify rules, and
  validation constraints.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  Act0 as canonical learner-facing runtime.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Volume I launch target,
  W1-W12/W13-W36 boundary, and W2-W6 learner-facing titles.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: current score ledger,
  blocker register, and active next wave.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: W2-W6 readiness rows,
  scoring rules, score caps, and current bridge limits.
- `docs/_reviews/w1_payoff_progression_certification_v1.md`: accepted W1
  technical `8.5` state and handoff to this decision.
- `docs/_reviews/w1_human_qa_protocol_v1.md`: hard Human QA boundary.
- `docs/_reviews/w1_8_0_certification_review_v1.md`: W1-style certification
  bar and W2-W6 bridge exclusion.
- `docs/_reviews/l2_volume_i_w1_w12_world_coverage_report_v1.md`: accepted
  route/content drift baseline.
- `docs/_reviews/w2_w6_route_content_normalization_v1.md`: accepted
  route-title/source-job separation policy.
- `docs/_reviews/w1_w6_schema_migration_pilot_v1.md`: W1 canonical plus W2
  bridge pilot baseline.
- `docs/_reviews/w2_w6_bridge_coverage_expansion_v1.md`: W3-W6 bridge fixture
  proof and launch-claim blocking proof.
- `test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`
- `tools/content_schema_l2_l3_validator_v1.dart`
- `tools/content_schema_foundation_validator_v1.dart`

Why fixtures were inspected:

- to confirm the current bridge fixture task count, `source_truth_status`,
  `safe_claim_status`, `launch_coverage_claimed`, concept family, transfer
  surfaces, repair focus, and migration source posture for W2-W6.

Advisory navigation:

- `graphify query "W2 W3 W4 W5 W6 bridge_or_legacy route title source job canonical launch coverage route content normalization"`

## 3. Current W2-W6 State

Shared facts:

- W2-W6 have active campaign-route ownership through the current learner path.
- W2-W6 Act0 cards remain locked preview cards.
- Current fixtures are `bridge_or_legacy`, `safe_claim_status:
  limited_bridge`, and `launch_coverage_claimed: false`.
- Current bridge fixtures report useful transfer surfaces and repair focus, but
  they are three-task bridge pilots, not six-task W1-style canonical concept
  families.
- L2/L3 validation reports bridge-limited posture and blocks launch coverage
  claims for the current fixtures.
- Existing route titles remain canonical learner-facing route truth until a
  deliberate route-title wave changes them.

Route/content drift:

- W2 route title is `Hand Discipline`; current source job is broad table-reading
  bridge.
- W3 route title is `Position Thinking`; current source job is Preflop
  Framework.
- W4 route title is `Preflop Framework`; current source job is Bet Purpose and
  Price.
- W5 route title is `Bet Purpose And Price`; current source job is Board
  Awareness.
- W6 route title is `Board And Draws`; current source job is Range Thinking.

Answer to the primary question:

W2-W6 cannot become launch-grade while remaining `bridge_or_legacy`. They can
remain useful bridge support with limited claims, but launch-grade status
requires route-owned canonical source truth, W1-style same-signal coverage,
transfer coverage, repair coverage, poker correctness, payoff/progression
evidence, and later Human QA.

## 4. W2-W6 Decision Matrix

| World | Current route title | Source content job | Current source_truth_status | Bridge fixture status | Canonical launch coverage allowed yes/no | Main mismatch | Recommended path | Required next implementation wave | Risk | Score impact |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W2 | Hand Discipline | Broad table-reading bridge: position, initiative, texture, outs, price, and action defaults | `bridge_or_legacy` | 3 tasks; `position_btn_vs_early`; transfer/repair present; launch claim blocked | No | The route wants hand-discipline certification, but current source is a broad table-reading bridge. | `canonicalize_existing_source` for one narrow W2 hand-discipline slice; keep the rest bridge-limited. | `W2 Canonical Certification Pilot` | Medium: easiest post-W1 candidate, but source must be selected narrowly and poker-reviewed. | `+0.0` now; future movement only after code-backed canonical W2 proof. |
| W3 | Position Thinking | Preflop Framework | `bridge_or_legacy` | 3 tasks; `preflop_framework_bridge`; transfer/repair present; launch claim blocked | No | Source job is preflop framework, not broad position-thinking mastery. | `defer_until_W1_W2_pattern_stable`; later decide whether to canonicalize a position slice or remap source ownership. | After W2 pilot, likely `W2-W3 Canonicalization Pilot` only if W2 pattern succeeds. | Medium-high: good source, wrong route-title claim. | `+0.0` |
| W4 | Preflop Framework | Bet Purpose and Price | `bridge_or_legacy` | 3 tasks; `bet_purpose_price_bridge`; transfer/repair present; launch claim blocked | No | Source appears closer to W5 title than W4 title. | `source_ownership_remap_needed` or `route_title_realignment_needed` later; do not canonicalize by metadata only. | No immediate implementation before W2 proves the pattern. | High: title/source offset can create false preflop-framework claims. | `+0.0` |
| W5 | Bet Purpose And Price | Board Awareness | `bridge_or_legacy` | 3 tasks; `board_awareness_bridge`; transfer/repair present; launch claim blocked | No | Source appears closer to W6-style board/draw work than W5 title. | `source_ownership_remap_needed`; preserve W5 premium-boundary title until a deliberate realignment wave. | No immediate implementation before W2 proves the pattern. | High: W5 is future premium boundary, so overclaim risk is commercially sensitive. | `+0.0` |
| W6 | Board And Draws | Range Thinking | `bridge_or_legacy` | 3 tasks; `range_thinking_bridge`; transfer/repair present; launch claim blocked | No | Source is range-thinking bridge and also owns the terminal gate before W7-W10. | `split_content_job_needed`; preserve W6 terminal route gate and defer canonicalization. | No immediate implementation before W2 proves the pattern. | High: range advice and terminal-gate semantics need correctness review. | `+0.0` |

## 5. Canonicalization Options

### Keep bridge-limited

Pros:

- claim-safe;
- already supported by current fixtures and validators;
- avoids route/title churn.

Cons:

- cannot produce launch-grade W2-W6 worlds;
- cannot close Volume I readiness beyond limited bridge support;
- leaves W2-W6 below canonical certification threshold.

Decision:

Use this as the default safety posture for all existing W2-W6 bridge fixtures.

### Canonicalize existing source

Pros:

- fastest route from W1 technical `8.5` toward Volume I readiness;
- reuses existing source where the route/source concept truly overlaps;
- can replicate the W1-style six-task/same-signal/transfer/repair proof shape.

Cons:

- unsafe as a metadata-only flip;
- requires selecting source tasks that actually match the route claim;
- requires validator-backed evidence and later correctness/Human QA gates.

Decision:

Use only for W2 first, and only for a narrow W2 hand-discipline slice. Do not
canonicalize W3-W6 by metadata only.

### Realign route title

Pros:

- would make route labels match current source jobs more directly;
- may reduce future content ownership ambiguity.

Cons:

- cascades through Act0 labels, Learn copy, monetization boundaries, W7-W10
  sequence, and prior SSOT claims;
- broad route changes are not admitted by this wave.

Decision:

Defer. Route-title realignment is a later control-plane option if W2
canonicalization fails or if W4-W6 source ownership remains irreconcilable.

### Remap source ownership

Pros:

- may put W4-W6 source jobs under the worlds where they naturally belong;
- prevents false mastery claims from route-title/source-job offsets.

Cons:

- likely requires broader migration planning;
- could destabilize W5 premium-boundary semantics if done too early.

Decision:

Likely needed for W4-W6 later, but not before the W2 pilot establishes the
canonical certification pattern.

### Defer

Pros:

- avoids overclaiming, route churn, and content sprawl;
- keeps W7-W12 closed while W2-W6 route truth is unresolved.

Cons:

- does not improve Volume I readiness by itself.

Decision:

Defer W3-W6 canonicalization until W2 proves or falsifies the W1-style
certification path outside W1.

## 6. Recommended Path

Block strategy:

- Keep all existing W2-W6 bridge fixtures as `bridge_or_legacy` and
  claim-limited.
- Do not count bridge fixtures as canonical launch coverage.
- Do not rename routes or learner-facing titles in this wave.
- Do not broad-migrate W2-W6.
- Use W2 as the first post-W1 canonical certification pilot.
- Treat W3-W6 as deferred until the W2 pilot proves the smallest repeatable
  pattern.

Per-world strategy:

- W2: run a `W2 Canonical Certification Pilot` that selects one narrow
  route-owned hand-discipline concept family from existing source, migrates it
  as canonical source truth, and proves W1-style validation. Existing bridge
  fixture remains bridge-limited.
- W3: defer until W2 proves the pattern; likely next candidate only if a
  position-thinking slice can be separated from preflop-framework source.
- W4: do not canonicalize current bet-purpose source as Preflop Framework by
  metadata only; expect source ownership remap or title realignment later.
- W5: protect the premium boundary; do not make board-awareness source carry a
  Bet Purpose and Price claim.
- W6: protect the W6 terminal gate; split range-thinking bridge from Board and
  Draws claim before any canonical certification.

## 7. Next Implementation Wave

Chosen next implementation wave:

`W2 Canonical Certification Pilot`

Why this wave:

- It is the smallest step that can move one W2-W6 world from bridge-limited
  toward W1-style canonical certification.
- It avoids broad W2-W6 migration.
- It avoids W7-W12 admission before W2-W6 route truth is resolved.
- It tests whether existing source can support canonical launch coverage when
  selected narrowly and validated rigorously.

Initial acceptance shape for the next wave:

- one W2 canonical concept family only;
- six source-derived coverage-countable tasks;
- `source_truth_status: migrated` or the currently accepted canonical source
  truth value, not `bridge_or_legacy`;
- `safe_claim_status` compatible with canonical W2 proof, not
  `limited_bridge`;
- `launch_coverage_claimed: false` unless the validator contract explicitly
  permits the claim;
- L2/L3 route admission should move the selected W2 slice toward
  route-ready/canonical evidence while preserving bridge-limited status for all
  existing bridge fixtures;
- no runtime route/title change;
- no new broad content authoring;
- no W3-W6 migration in the same wave.

Not selected:

- `W2-W3 Canonicalization Pilot`: too broad before W2 alone proves the pattern.
- `W2-W6 Route Title Realignment Plan`: may be needed later, but it does not
  turn one world toward W1-style certification as directly as W2.
- `W2-W6 Source Ownership Remap`: premature before one canonical pilot proves
  migration semantics.
- `W2-W6 Bridge PR2`: current bridge proof already covers W2-W6 and more
  bridge proof would not answer canonical launch readiness.
- `W7-W12 Admission/Content Lock`: blocked until W2-W6 canonical/bridge path is
  resolved.

## 8. Ledger Impact

No score movement.

Reason:

- This is a docs-only decision wave.
- It changes the active implementation pointer but adds no new validator-backed
  fixture, route admission, source migration, poker correctness, Human QA,
  learner-facing payoff, or runtime behavior.
- W1 remains technical `8.5`.
- W2 remains `4.7`.
- W3 remains `5.1`.
- W4 remains `5.3`.
- W5 remains `5.3`.
- W6 remains `5.1`.
- W1-W12 Volume I Premium Product Readiness remains `6.3`.
- Overall Top-1 Readiness remains `6.1`.

Status labels may update from "decision pending" to "decision accepted; W2
canonical pilot next." Existing bridge/claim limits remain.

## 9. Route Impact

- No route changes.
- No learner-facing title changes.
- W2-W6 remain bridge-limited unless and until a future implementation wave
  creates canonical validator evidence.
- W7-W10 remain locked/not learner-playable.
- W11-W12 remain authored-but-not-routed.
- W13-W36 remain post-launch/deferred.
- No Act0 card state changed.
- No content ownership changed.
- No monetization, store, public beta, UI, telemetry, screenshots, or Modern
  Table work occurred.

## 10. Active Repair Queue Update

Closed:

- W2-W6 Canonical/Bridge Decision v1.
- Decision that W2-W6 cannot become launch-grade while remaining
  `bridge_or_legacy`.
- Decision that current W2-W6 bridge fixtures stay claim-limited.

Active:

- W2 Canonical Certification Pilot.

Must-not-skip:

- Keep W2-W6 migration validator-led.
- Keep all existing bridge fixtures claim-limited.
- Preserve route titles separately from source jobs.
- Preserve W1 technical `8.5` boundary; W1 is not 9.0 until Human QA and
  remaining learning-effect proof.
- Human QA execution before external beta or public learning claims.
- W1-W12 correctness review before premium launch claims.

Deferred:

- W2-W6 route/title runtime changes.
- W2-W6 broad migration.
- W3-W6 canonicalization.
- W4-W6 source ownership remap.
- W7-W12 opening.
- W13-W36 launch dependency.
- New broad content authoring.
- Monetization.
- Store/public beta.

Blockers:

- W2 lacks a canonical six-task W1-style concept-family fixture.
- W3-W6 route-title/source-job offsets remain unresolved.
- W2-W6 poker correctness and Human QA have not executed.
- Durable learning-effect proof beyond W1 remains absent.

## 11. Evidence DoD Status

Docs-only validation required:

- `graphify hook-check`
- `git diff --check`
- direct ASCII check on edited docs
- direct trailing-whitespace and CRLF check on edited docs

Tooling changes:

- None.

Therefore no Dart format, Flutter test, Flutter analyze, screenshot, or runtime
capture is required by this wave.

## 12. Anti-Theater Check

What risk moved:

- The route now has an explicit decision: W2-W6 bridge fixtures are not a path
  to launch-grade status by themselves.
- The next step is narrowed to one W2 canonical certification pilot instead of
  broad W2-W6 migration, title churn, or more bridge proof.

What did not move:

- No score moved.
- No route changed.
- No content changed.
- No validator output changed.
- No learner-facing claim changed.
- No W2-W6 world became launch-grade.

Is this docs-only or code-backed?

- This wave is docs-only.
- The decision is evidence-backed by prior code/fixture/validator work, but it
  adds no new code-backed proof.

Did this change routes/content?

- No.

Does this select a safer implementation step?

- Yes. `W2 Canonical Certification Pilot` is the smallest next implementation
  wave that can test W1-style canonical certification outside W1 while keeping
  bridge fixtures claim-limited and W7-W12 closed.
