# W1-W6 Prerequisite Chain Repair Batch v1

Status: REVIEW ARTIFACT.
Branch: `codex/w1-w6-prerequisite-chain-repair-batch-v1`.
Baseline: `53e11f1f` (`w1_w6_learning_outcome_independent_audit_recommends_prerequisite_repair`).
Verdict: `w1_w6_prerequisite_chain_repair_partial_needs_followup`.

## 1. Verdict

The repair batch lands the executable Tier A prerequisite repairs that are safe
under existing W1-W6 source truth:

- W1 pot and defend vocabulary are clarified in generated W1 fixture feedback.
- W3 now defines IP/OOP before position-sensitive decisions.
- W4 now grounds equity and protection before purpose/action decisions.
- W5 now defines draw before draw-heavy board-texture labels.
- W5 now has a bounded `basic_outs_awareness` source repair and canonical
  prerequisite fixture for flush draw 9, open-ended straight draw 8, and
  gutshot 4.
- W6 now defines range before both accepted W6 canonical range families.

The batch does not claim full readiness for Human QA, 9.0, launch, or W7-W12
route expansion because W1 still lacks W1-owned source truth for hand ranking,
showdown resolution, best-5-of-7, and kicker. That item is source-blocked rather
than repaired by overclaiming W2 showdown source.

Recommended next wave:

`W1 Showdown Basics Source/Authorship Scope Decision v1`

## 2. Scope

In scope:

- the exact Tier A prerequisite chain from
  `docs/_reviews/w1_w6_learning_outcome_independent_audit_v1.md`;
- focused W1/W3/W4/W5/W6 generated fixtures and exporter overrides;
- one bounded W5 source repair for `basic_outs_awareness`;
- focused validator tests and copy guard tests;
- minimal ledger and long-horizon pointer updates.

Out of scope:

- W7-W12 source/content inspection or opening;
- new W1 showdown fixture without W1 source ownership;
- broad W1-W6 migration;
- UI, screenshots, telemetry expansion, monetization, Human QA execution,
  launch, solver/GTO, route-title changes, or external dependency work.

## 3. Source Truth Findings

W1 source truth:

- W1 owns seat/action/order, starting-hand discipline, bet-size labels,
  card/board orientation, checkpoint synthesis, and payoff/progression proof.
- W1 does not currently own a source task family for hand ranking, showdown
  resolution, best-5-of-7, or kicker.
- W2 has showdown source, but importing that into W1 as a W1 canonical fixture
  would be source ownership overclaim.

W3 source truth:

- W3 `w3.s11` supports the bridge from position identity into acting later, so
  the IP/OOP bridge is safely repairable in W3 fixture feedback.

W4 source truth:

- W4 accepted canonical source owns bet purpose and action discipline.
- Equity/protection language was present but under-grounded; it is safely
  reframed as beginner definitions in the generated fixture feedback.

W5 source truth:

- W5 `world.md` explicitly names board awareness, draw recognition, outs, and
  improvement counting.
- Existing W5 canonical fixtures covered texture and board shifts, but not the
  concrete beginner outs counts. This wave adds a narrow W5 source repair for
  9/8/4 outs and no action policy.

W6 source truth:

- W6 accepted canonical source owns two narrow range families:
  `range_bucket_by_board_fit` and `range_width_awareness`.
- Adding the plain range definition to the first task of each family is
  source-safe and claim-safe.

## 4. Repairs Implemented

| ID | Disposition |
| --- | --- |
| P1-01 W1 hand ranking/showdown/best-5 | Source-blocked in W1; no fixture created. |
| P1-02 kicker before W2 | Source-blocked with P1-01; no W1 kicker overclaim. |
| P1-03 IP/OOP before W3 | Repaired in W3 canonical generated fixture feedback. |
| P1-04 equity/protect before W4 | Repaired in W4 intent/action generated fixture feedback. |
| P1-05a draw before W5 | Repaired in W5 board-texture generated fixture feedback. |
| P1-05b W5 outs scope | Repaired by bounded W5 source plus canonical prerequisite fixture. |
| P1-06 range before W6 | Repaired in both W6 canonical generated fixture families. |
| P2-01 pot definition | Repaired in W1 bet-size generated fixture feedback. |
| P2-02 defend clarity | Repaired in W1 starting-hand generated fixture feedback. |

## 5. Source-Blocked Items

W1 showdown basics remain blocked by source truth:

- no W1-owned hand-ranking task;
- no W1-owned showdown-resolution task;
- no W1-owned best-5-of-7 task;
- no W1-owned kicker task.

The honest next decision is to either author a bounded W1 source family or
explicitly narrow W1 learner-outcome claims before Human QA planning.

## 6. Fixture / Source Changes

Generated fixture/source changes:

- `tools/content_factory_import_export_mvp_v1.dart` now emits the repaired
  prerequisite feedback deterministically.
- `test/fixtures/content_factory_mvp/w5_basic_outs_awareness_canonical_prerequisite_repair_v1.json`
  adds six W5 coverage-countable tasks.
- `content/worlds/world5/v1/sessions/w5.s11/` adds the bounded source repair.

Existing generated fixture repairs:

- W1 pot and defend;
- W3 IP/OOP;
- W4 equity/protection/control safe copy;
- W5 draw definition;
- W6 range definition.

## 7. Validator Results

Foundation validator:

- W1 bet-size: OK, 6 tasks.
- W1 starting-hand: OK, 6 tasks.
- W3 canonical pilot: OK, 6 tasks.
- W4 canonical PR2: OK, 6 tasks.
- W5 board texture: OK, 6 tasks.
- W5 basic outs repair: OK, 6 tasks.
- W6 range bucket: OK, 6 tasks.
- W6 range width: OK, 6 tasks.

Canonical L2/L3:

- W1 touched fixtures: `learner_playable_route_ready`.
- W3 canonical pilot: `learner_playable_route_ready`.
- W4 canonical PR2: `learner_playable_route_ready`.
- W5 board texture plus basic outs: `learner_playable_route_ready`.
- W6 bucket plus width: `learner_playable_route_ready`.

Bridge negative controls:

- W3 bridge plus canonical: `bridge_or_legacy_limited`.
- W4 bridge plus canonical: `bridge_or_legacy_limited`.
- W5 bridge plus canonical plus outs repair: `bridge_or_legacy_limited`.
- W6 bridge plus canonical: `bridge_or_legacy_limited`.

## 8. Test Coverage

Focused tests added/updated:

- `test/tools/content_schema_l2_l3_validator_v1_test.dart`
  - proves W5 basic outs repair is route-ready;
  - proves W5 bridge plus outs repair stays bridge-limited.
- `test/tools/w1_w6_prerequisite_chain_repair_batch_v1_test.dart`
  - pins W1-W6 prerequisite definitions;
  - proves W5 outs repair stays count-only;
  - scans changed W4-W6 prerequisite copy for forbidden strategy terms.

Focused test run:

- `flutter test test/tools/content_schema_l2_l3_validator_v1_test.dart test/tools/w1_w6_prerequisite_chain_repair_batch_v1_test.dart` - passed, 44 tests.

## 9. Bridge / Canonical Separation

Bridge evidence remains reportable but not canonical launch coverage. The new
W5 outs fixture is canonical-source repaired and validates route-ready only
when evaluated without bridge evidence. Mixed bridge plus canonical evidence
still resolves to `bridge_or_legacy_limited`.

No bridge fixture was converted to canonical by metadata.

## 10. W7-W12 Route-Lock Impact

W7-W12 were not opened or edited. The W9/W10 route-lock guard remains green:

- `flutter test test/guards/world10_campaign_routing_contract_test.dart test/guards/world9_campaign_routing_contract_test.dart test/guards/season1_checkpoint_pedagogy_consistency_contract_test.dart` - passed.

## 11. Score / Ledger Impact

World scores:

- W1 remains `8.5` technical candidate.
- W2-W6 remain bounded technical `8.0` candidates.
- W5 gains a third narrow validator-backed canonical prerequisite family, but
  W5 does not move above bounded technical 8.0.

Aggregate score proposal:

- W1-W12 Volume I Premium Product Readiness: unchanged at `8.1`.
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall Top-1 Readiness: unchanged at `6.6`.
- Content depth: unchanged in the ledger until the W1 showdown source gap is
  resolved or explicitly scoped out.

Reason: executable repairs landed, but the remaining W1 P1 source gap still
blocks Human QA, 9.0, public learning-outcome claims, and W7-W12 opening.

## 12. Human QA / 9.0 Impact

Human QA should not start yet as a proof of learning-outcome guarantee. The
chain is better grounded, but W1 showdown/kicker remains an obvious source gap.

9.0 remains blocked by:

- W1 showdown/kicker source gap;
- no live novice Human QA;
- no durable learner outcome proof;
- broad W1-W6 migration still incomplete.

## 13. Active Repair Queue Update

Closed or materially repaired:

- P1-03 IP/OOP bridge;
- P1-04 equity/protection bridge;
- P1-05a draw definition;
- P1-05b W5 outs scope decision;
- P1-06 range definition;
- P2-01 pot definition;
- P2-02 defend clarity.

Still active:

- P1-01 W1 hand ranking/showdown/best-5;
- P1-02 kicker before W2;
- W6 bucket dependency on W1 hand-strength language.

Recommended queue:

1. `W1 Showdown Basics Source/Authorship Scope Decision v1`.
2. Human QA planning only after W1 source gap is repaired or explicitly scoped.
3. W7-W12 opening only after prerequisite-chain and Human QA gates.

## 14. Evidence DoD Status

Completed:

- dart format on touched Dart/test files;
- focused Flutter tests;
- import/export CLI;
- W1/W3/W4/W5/W6 foundation validator;
- W1/W3/W4/W5/W6 canonical L2/L3 validator;
- W3/W4/W5/W6 bridge negative controls;
- W7-W10 route-lock guard;
- W4-W6 forbidden strategy copy scan via focused test;
- flutter analyze.
- graphify hook-check;
- git diff checks;
- ASCII/whitespace/CRLF/final-newline checks.

## 15. Anti-Theater Check

This wave does not claim W1-W6 learning outcomes are proven. It repairs concrete
missing beginner definitions and adds one narrow W5 source-owned fixture, while
leaving the W1 showdown/kicker source gap visible. The outcome is not launch,
not 9.0, not Human QA, not W7-W12 opening, and not broad W1-W6 migration.
