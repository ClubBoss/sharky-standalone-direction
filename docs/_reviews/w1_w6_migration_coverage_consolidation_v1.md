# W1-W6 Migration Coverage Consolidation v1

## 1. Verdict

`w1_w6_consolidation_docs_only_ready`

W1-W6 migration coverage is now consolidated into one readable readiness
layer. W1 has one canonical, validator-backed same-signal coverage pilot.
W2-W6 each have validator-backed `bridge_or_legacy` migration pilots, but
those pilots remain `bridge_or_legacy_limited` and cannot count as canonical
launch coverage.

## 2. Source truth

Focused docs, tools, tests, and fixtures inspected:

- `AGENTS.md`: active repo, route, graphify, and no-archive constraints.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Volume I launch scope and W13-W36 deferral.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: current score ledger and active next-wave state.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`: world readiness scores and score movement rules.
- `docs/_reviews/w2_w6_bridge_coverage_expansion_v1.md`: accepted W3-W6 bridge fixture proof.
- `docs/_reviews/w1_w6_schema_migration_pilot_v1.md`: accepted W1/W2 migration pilot baseline.
- `docs/_reviews/w1_world_coverage_expansion_pilot_v1.md`: accepted W1 canonical coverage pilot.
- `docs/_reviews/l2_l3_content_validator_expansion_v1.md`: executable coverage and route-admission contract.
- `docs/_reviews/w2_w6_route_content_normalization_v1.md`: W2-W6 `bridge_or_legacy` route/content normalization.
- `tools/content_schema_l2_l3_validator_v1.dart`: existing compact W1-W6 report command.
- `tools/content_schema_foundation_validator_v1.dart`: foundation fixture validation.
- `test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`: W1 canonical pilot fixture.
- `test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json` through `w6_bridge_or_legacy_schema_migration_pilot_v1.json`: W2-W6 bridge fixtures.

No broad content scan, archive read, screenshot inspection, route refactor, or
new tooling was needed.

## 3. Problem statement

W1-W6 now has real schema/factory/validator evidence, but that evidence is not
homogeneous. W1 is a canonical migrated coverage pilot that passes L2/L3 route
readiness for one same-signal group. W2-W6 are only bridge migration pilots:
they prove the factory and validators can preserve route/content truth and
claim safety, but they do not prove canonical launch coverage for their
route-facing world titles.

Therefore W1-W6 is not launch-grade content. It is a controlled migration
foundation with one canonical W1 proof and five bridge-limited W2-W6 proofs.

## 4. W1-W6 consolidation matrix

| World | Route status | Source truth status | Fixture exists | Migrated fixture tasks | Coverage-countable count | Same-signal groups | Transfer surfaces | Repair focus | L2 result | L3 route/admission result | Canonical launch coverage allowed | Primary blocker | Next required action | Current score | Proposed delta |
| --- | --- | --- | --- | ---: | ---: | --- | --- | --- | --- | --- | --- | --- | --- | ---: | ---: |
| W1 | learner_playable | migrated | yes | 6 | 6 | `w1.position_action_order.first_in_or_facing_pressure` | `first_in_action_order_v1`; `facing_open_pressure_v1`; `multiway_pressure_v1` | `position_before_action` | `coverage_ready=true`, `transfer_ready=true`, `repair_ready=true` | `learner_playable_route_ready` | yes, pilot slice only | full W1 migration, correctness, and human QA remain incomplete | W1 Full Coverage Certification Plan | 6.9 | +0.0 |
| W2 | learner_playable campaign path; Act0 card locked/non-selectable | bridge_or_legacy | yes | 3 | 3 | `w2.position_btn_vs_early.bridge_action_default` | `early_position_release_v1`; `facing_open_price_v1`; `late_position_open_v1` | `position_price_action_default` | `coverage_ready=false`, `transfer_ready=true`, `repair_ready=true` | `bridge_or_legacy_limited` | no | bridge source cannot certify Hand Discipline launch coverage | W2-W6 Canonical Realignment Plan after W1 certification planning | 4.7 | +0.0 |
| W3 | learner_playable campaign path; Act0 card locked/non-selectable | bridge_or_legacy | yes | 3 | 3 | `w3.preflop_framework.bridge_action_default` | `late_position_open_v1`; `facing_open_continue_v1`; `earlier_position_release_v1` | `preflop_frame_action_default` | `coverage_ready=false`, `transfer_ready=true`, `repair_ready=true` | `bridge_or_legacy_limited` | no | Preflop Framework source cannot certify Position Thinking launch coverage | W2-W6 Canonical Realignment Plan after W1 certification planning | 5.1 | +0.0 |
| W4 | learner_playable campaign path; Act0 card locked/non-selectable | bridge_or_legacy | yes | 3 | 3 | `w4.bet_purpose_price.bridge_action_default` | `denial_raise_v1`; `control_call_v1`; `release_when_denial_gone_v1` | `purpose_price_action_default` | `coverage_ready=false`, `transfer_ready=true`, `repair_ready=true` | `bridge_or_legacy_limited` | no | Bet Purpose and Price source cannot certify Preflop Framework launch coverage | W2-W6 Canonical Realignment Plan after W1 certification planning | 5.3 | +0.0 |
| W5 | learner_playable campaign path; Act0 card locked/non-selectable | bridge_or_legacy | yes | 3 | 3 | `w5.board_awareness.bridge_texture_action_default` | `dry_texture_pressure_v1`; `connected_texture_control_v1`; `wet_texture_release_v1` | `texture_before_action` | `coverage_ready=false`, `transfer_ready=true`, `repair_ready=true` | `bridge_or_legacy_limited` | no | Board Awareness source cannot certify Bet Purpose And Price launch coverage | W2-W6 Canonical Realignment Plan after W1 certification planning | 5.3 | +0.0 |
| W6 | learner_playable campaign path; terminal before W7 gate | bridge_or_legacy | yes | 3 | 3 | `w6.range_thinking.bridge_range_action_default` | `range_strength_raise_v1`; `equity_realization_call_v1`; `range_weak_release_v1` | `range_before_action` | `coverage_ready=false`, `transfer_ready=true`, `repair_ready=true` | `bridge_or_legacy_limited` | no | Range Thinking source cannot certify Board And Draws launch coverage | W2-W6 Canonical Realignment Plan after W1 certification planning | 5.1 | +0.0 |

## 5. What is now proven

### W1 canonical proof

- One W1 six-task real source fixture exists.
- It passes foundation validation with six migration sources.
- It passes L2/L3 as `coverage_ready=true`, `transfer_ready=true`, and `repair_ready=true`.
- It is route-admitted as `learner_playable_route_ready`.
- It proves one W1 same-signal pilot slice, not full W1 certification.

### W2-W6 bridge proof

- W2, W3, W4, W5, and W6 each have one three-task real source fixture.
- Each fixture passes foundation validation with three migration sources.
- Each fixture reports transfer and repair readiness.
- Each fixture remains `coverage_ready=false` because `bridge_or_legacy` content is not canonical launch coverage.
- Each fixture is route-admitted only as `bridge_or_legacy_limited`.

### Validator/factory proof

- Existing factory outputs cover W1 canonical pilot and W2-W6 bridge pilots.
- Existing L2/L3 validator reports W1-W6 in one command.
- Existing foundation validator validates all six fixtures directly.
- No new tool was needed for this consolidation because the validator already provides the compact report.

### Claim-safety proof

- W2-W6 records carry `safe_claim_status: limited_bridge`.
- W2-W6 records carry `launch_coverage_claimed: false`.
- Existing tests block bridge fixtures from claiming launch coverage.
- W7-W10, W11-W12, and W13-W36 route-admission constraints remain protected by the L2/L3 validator tests.

## 6. What is not proven

### Full W1 coverage

- W1 has one strong pilot group, not full-world migration.
- W1 still needs a certification plan for required concept families, thresholds, correctness review, and human QA.

### W2-W6 canonical launch coverage

- W2-W6 bridge fixtures do not certify their route-facing titles.
- W2-W6 remain `bridge_or_legacy_limited`.
- W2-W6 cannot be marked launch-ready or coverage-ready from these fixtures.

### Poker correctness

- No L4 poker correctness protocol was run.
- Existing source tasks still need correctness review before strong learning or premium claims.

### Human QA

- No novice comprehension QA was executed.
- Human QA remains a hard gate before external beta, public launch, or learning-effect claims.

### Learner-visible release value

- This consolidation adds no learner-facing route, UI, payoff, or progression value.
- It improves decision clarity, not in-app experience.

### W7-W12 admission

- W7-W10 remain locked.
- W11-W12 remain authored but not routed.
- W1-W6 still blocks W7-W12 admission planning because canonical launch coverage is not settled.

## 7. Release-readiness implications

Safe conclusions:

- W1 has the cleanest near-term path toward release-grade certification.
- W2-W6 have enough bridge evidence to avoid more bridge PRs right now.
- W2-W6 should not receive additional score movement from this docs-only consolidation.
- W1-W12 readiness should not move from this wave.

Still blocked:

- W2-W6 cannot count as canonical launch coverage.
- W1 is not fully certified.
- W7-W12 should not open.
- Human QA and poker correctness remain future hard gates.

Ledger movement:

- No world score changes.
- No aggregate score changes.
- The active next-wave pointer should move from this consolidation wave to
  `W1 Full Coverage Certification Plan`.

## 8. Next-step decision

Chosen next wave: `W1 Full Coverage Certification Plan`.

Why this has the highest release-readiness EV:

- W1 is the only W1-W6 world with canonical route-ready coverage evidence.
- A plan can define exactly what remains for full W1 certification without broad migration or authoring.
- It creates a clean release-grade anchor before debating W2-W6 canonical realignment.
- It avoids spending another PR on W2-W6 bridge thickness, because bridge proof is already consistent.
- It avoids W7-W12 admission while W1-W6 still has unresolved canonical coverage and QA blockers.

Rejected options:

- `W2-W6 Bridge Coverage Expansion PR2`: not needed; W2-W6 already have consistent three-task bridge pilots.
- `W2-W6 Canonical Realignment Plan`: important, but lower EV until W1 has a certification route.
- `W1-W6 Migration Coverage Expansion`: too close to broad migration before certification requirements are defined.
- `Human QA Protocol`: still critical, but technical scope is not yet release-certification-ready.
- `W7-W12 Admission/Content Lock`: premature while W1-W6 canonical launch coverage remains unsettled.

## 9. Route impact

- No active route truth changed.
- No learner-facing title changed.
- No world became playable, locked, or routed differently.
- W2-W6 remain `bridge_or_legacy_limited`.
- W7-W10 remain locked/not learner-playable.
- W11-W12 remain authored but not routed.
- W13-W36 remain post-launch / live expansion / advanced roadmap.
- No monetization, store, public beta, UI, telemetry, or Modern Table work occurred.

## 10. Active repair queue update

Closed:

- W1-W6 Migration Coverage Consolidation v1.
- W1-W6 matrix consolidation.
- Next-step selection from the six allowed options.

Active:

- W1 Full Coverage Certification Plan.

Must-not-skip:

- Keep W1 certification validator-led.
- Do not treat the W1 pilot as full W1 certification.
- Do not count W2-W6 bridge fixtures as canonical launch coverage.
- Do not author broad W1-W6 content before certification requirements are clear.
- Run poker correctness review and Human QA Protocol before public or premium learning claims.

Deferred:

- New W1-W6 content authoring.
- Full W1-W6 migration.
- W2-W6 canonical realignment.
- W5-W12 expansion.
- W7-W12 opening.
- W13-W36 content production.
- Monetization.
- Store/public beta.

Blockers:

- W1 full certification requirements are not defined.
- W2-W6 canonical launch coverage is blocked by bridge/source-title drift.
- Poker correctness review is unrun.
- Human QA is unrun.

## 11. Score delta proposal

- W1 readiness: unchanged at `6.9`.
- W2 readiness: unchanged at `4.7`.
- W3 readiness: unchanged at `5.1`.
- W4 readiness: unchanged at `5.3`.
- W5 readiness: unchanged at `5.3`.
- W6 readiness: unchanged at `5.1`.
- W1-W12 Volume I Premium Product Readiness: unchanged at `5.9`.
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall Top-1 Readiness: unchanged at `5.7`.
- Architecture scalability: unchanged at `8.1`.
- Content depth: unchanged at `4.8`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

Reason: this is a docs-only consolidation wave. It moves decision clarity and
next-step selection, not content coverage, route admission, correctness, QA,
or learner-visible value.

## 12. Wave DoD status

- W1-W6 matrix complete: done.
- W1 canonical proof summarized: done.
- W2-W6 bridge proof summarized: done.
- Bridge limitations stated: done.
- Next step selected: `W1 Full Coverage Certification Plan`.
- No content authored: done.
- No broad migration: done.
- No route changes: done.

## 13. Evidence DoD status

Command evidence:

- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`: OK; 6 fixtures, 6 worlds, 21 tasks, 21 coverage-countable; W1 `coverage_ready=true`, W2-W6 `coverage_ready=false`; W1 route admission `learner_playable_route_ready`; W2-W6 route admission `bridge_or_legacy_limited`.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`: OK; W1 tasks=6, W2-W6 tasks=3 each, all migration source counts match task counts.

Final graphify, diff, ASCII, whitespace, and CRLF checks are recorded in the
final Codex response for this wave.

## 14. Anti-theater check

What risk moved:

- Decision risk moved. W1-W6 status is now consolidated into one artifact, and
  the next step is selected from the allowed options.

What did not move:

- Content coverage did not move.
- Route admission did not move.
- W2-W6 canonical launch coverage did not move.
- Poker correctness did not move.
- Human QA did not move.
- Learner-visible release value did not move.

Docs-only or code/test-backed:

- This is docs-only consolidation backed by existing validator commands.
- No new tooling or tests were added because the existing validator already
  reports the W1-W6 fixture status in one place.

Safer next implementation step:

- Yes. `W1 Full Coverage Certification Plan` is safer than broad migration,
  W2-W6 authoring, or W7-W12 admission because it focuses on the only canonical
  route-ready world and defines the remaining release-grade bar before
  expanding claims.
