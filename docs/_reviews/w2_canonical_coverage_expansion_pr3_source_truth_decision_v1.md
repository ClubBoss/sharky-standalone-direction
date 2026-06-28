# W2 Canonical Coverage Expansion PR3 Source-Truth Decision v1

Status: ACCEPTED.
Created: 2026-06-29.

## 1. Verdict

`w2_canonical_coverage_expansion_pr3_one_family_ready`

PR3 takes Path A. Existing W2 source truth safely supports one additional
canonical Hand Discipline family:

`approved_raise_discipline`

The family is narrow by design: raise only when the source prompt explicitly
grants an approved, clear value, denial, or pressure-counter trigger. It is not
a broad aggression, bluffing, check-raise, river thin-value, or full W2
certification claim.

## 2. Source Truth Reviewed

Primary SSOT/docs:

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`
- `docs/_reviews/w2_canonical_coverage_expansion_pr2_v1.md`
- `docs/_reviews/w2_canonical_certification_pilot_v1.md`
- `docs/_reviews/w2_w6_canonical_bridge_decision_v1.md`
- `docs/_reviews/w2_w6_bridge_coverage_expansion_v1.md`

Implementation/test evidence:

- `tools/content_factory_import_export_mvp_v1.dart`
- `tools/content_schema_l2_l3_validator_v1.dart`
- `tools/content_schema_foundation_validator_v1.dart`
- `test/tools/content_factory_import_export_mvp_v1_test.dart`
- `test/tools/content_schema_l2_l3_validator_v1_test.dart`
- `test/fixtures/content_factory_mvp/w2_canonical_certification_pilot_v1.json`
- `test/fixtures/content_factory_mvp/w2_facing_price_discipline_canonical_pr2_v1.json`
- `test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json`

Advisory navigation:

- `graphify query "W2 PR3 source truth third canonical family Hand Discipline raise pressure price default content factory validator"`

## 3. Candidate Source-Truth Matrix

Accepted as PR3 source:

| Source path | Prompt source claim | Decision |
| --- | --- | --- |
| `content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_raise_to_facing_bet.json` | clear aggression trigger | accept |
| `content/worlds/world2/v1/sessions/w2.s07/drills/d.choose_raise_facing_open_isolation.json` | approved isolation node | accept |
| `content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_value.json` | clear value flop spot | accept |
| `content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_denial.json` | flop denial spot | accept |
| `content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_raise_bridge_pressure_counter.json` | approved pressure counter | accept |
| `content/worlds/world2/v1/sessions/w2.s10/drills/d.choose_raise_checkpoint_value_branch.json` | checkpoint value-intent node | accept |

Deferred candidates:

| Candidate family | Reason deferred |
| --- | --- |
| flop/turn/river bluff branches | too broad for beginner-safe Hand Discipline without correctness review |
| river thin-value branches | source claim is narrower than a safe W2 hand-discipline coverage claim |
| crucible 3bet/4bet and check-raise branches | useful future depth, but changes the claim surface beyond PR3 |
| broad pressure-sequence branches | source shape is more aggression/line-construction than clean Hand Discipline |

## 4. Fixture Digest

Generated fixture:

`test/fixtures/content_factory_mvp/w2_approved_raise_discipline_canonical_pr3_v1.json`

Fixture summary:

- tasks: 6
- coverage-countable tasks: 6
- `concept_family_id`: `approved_raise_discipline`
- `same_signal_group_id`: `w2.hand_discipline.approved_raise_only`
- `repair_focus_id`: `approved_raise_only_when_source_grants_trigger`
- `source_truth_status`: `migrated`
- `safe_claim_status`: `canonical_pilot`
- `launch_coverage_claimed`: `false`
- correct actions: six `raise`

Transfer surfaces:

- `clear_aggression_trigger_raise_v1`: 1
- `approved_isolation_raise_v1`: 1
- `value_intent_raise_v1`: 2
- `denial_raise_v1`: 1
- `approved_pressure_counter_raise_v1`: 1

## 5. W2 Canonical Coverage After PR3

Canonical route-ready W2 families:

- `hand_discipline_position_price_defaults`: 6 tasks
- `facing_price_continue_release_discipline`: 8 tasks
- `approved_raise_discipline`: 6 tasks

Total canonical coverage-countable W2 tasks without bridge evidence: 20.

The W2 bridge fixture remains separate and still evaluates as
`bridge_or_legacy_limited`. It is not counted as canonical coverage.

## 6. L2/L3 Result

PR3 fixture alone:

- `coverage_ready`: true
- `transfer_ready`: true
- `repair_ready`: true
- route admission: `learner_playable_route_ready`

W2 canonical pilot plus PR2 plus PR3:

- tasks: 20
- coverage-countable tasks: 20
- canonical concept families: 3
- route admission: `learner_playable_route_ready`

W2 bridge plus canonical fixtures:

- bridge remains claim-limited;
- canonical fixtures remain route-ready when evaluated without bridge evidence;
- no bridge evidence is promoted to launch coverage.

## 7. Tests Added

- `exports W2 approved raise discipline PR3 from real source tasks`
- `reports W2 canonical PR3 approved raise discipline as route-ready`
- `reports W2 canonical pilot through PR3 as multiple route-ready families`

The factory output count moved from 15 to 16 generated fixtures.

## 8. W2 Certification Impact

W2 is now a fair candidate for a bounded 8.0 certification review. It is not an
8.0 pass from PR3 alone.

Remaining W2 blockers:

- deliberate W2 certification review;
- poker correctness review;
- payoff/progression proof;
- Human QA posture;
- bridge/canonical separation and broad migration risk;
- deferred raise/bluff/thin-value source-title risk.

## 9. Score Delta Proposal

Conservative movement:

- W2: `5.4 -> 5.7`
- W1-W12 Volume I Premium Product Readiness: `6.5 -> 6.6`
- Content depth: `5.3 -> 5.4`
- Architecture scalability: unchanged at `8.1`
- Overall top-1 readiness: unchanged at `6.2`

Reason: PR3 adds one real validator-backed W2 canonical family, but it does not
close correctness, payoff, Human QA, certification, or broad migration.

## 10. Route Impact

Next active wave:

`W2 8.0 Certification Review / Correctness-Payoff Gate`

The next wave should decide whether W2 can honestly hold 8.0 review status
after three canonical families, and must separate source breadth from
correctness, payoff/progression, Human QA, and bridge/canonical blockers.

## 11. Forbidden Scope Proof

Not changed:

- no new W2 source content;
- no W3-W6 migration;
- no W7-W12 route opening;
- no runtime route change;
- no UI route change;
- no W13-W36 launch claim;
- no launch coverage claim;
- no W2 8.0/9.0/public launch claim.

## 12. Anti-Theater Check

This PR3 does not create a fixture just to increase count. The accepted tasks
were selected only where the source prompt gives an explicit approved, clear
value, denial, or pressure-counter reason to raise. Broader aggression and
bluff-adjacent branches were rejected for this wave.

PR3 improves W2 source-backed canonical breadth. It does not prove durable
learning, correctness, public product readiness, or monetization readiness.

## 13. Validation Plan

Required validation:

- focused factory tests;
- focused L2/L3 validator tests;
- factory CLI regeneration;
- PR3 L2/L3 validation;
- W2 canonical aggregate L2/L3 validation;
- W2 foundation validation;
- `flutter analyze`;
- `graphify hook-check`;
- `git diff --check`;
- `git diff --cached --check`;
- direct ASCII, trailing whitespace, CRLF, and final-newline checks.

## 14. Decision

Accepted path:

Path A: add one third W2 canonical family.

Rejected paths:

- Path B source/title stop, because a narrow safe approved-raise family exists.
- Path C partial/blocker, because the accepted PR3 family clears the same-signal,
  transfer, repair, foundation, and L2/L3 bars.
