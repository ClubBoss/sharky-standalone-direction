# Volume I World Readiness Ledger v1

Status: ACTIVE control-plane ledger for W1-W12 launch readiness.
Created: 2026-06-28.
Last refreshed: 2026-06-28 after W1 Bet-Size Vocabulary Correctness Repair v1.

## 1. Purpose

This ledger tracks world-level readiness for the Perfect W1-W12 Volume I
Premium Product launch target.

It is not a learner-facing dashboard and not a release claim. It is a compact
control-plane score map for future Codex waves.

Authority order:

1. `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
2. `docs/plan/MASTER_PLAN_v3.0.md`
3. `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
4. `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`
5. `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`
6. `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`
7. This ledger

## 2. Scoring Rules

- `0-2`: not launch-usable.
- `2-4`: source exists but route/content/claim safety is not ready.
- `4-6`: useful but blocked by schema, route, QA, or correctness gaps.
- `6-8`: close to launch-grade but missing validation, QA, correctness, or
  progression proof.
- `8-9`: launch-grade candidate, still needs final proof.
- `9+`: launch-ready only after human QA and final evidence.

Anti-theater constraints:

- Every score needs an evidence source and primary blocker.
- Every delta must say what risk moved.
- No score may reach `8.0` without schema/validator evidence and route safety.
- No score may reach `9.0` without human QA and correctness review where
  applicable.
- Locked worlds cannot exceed `4.0`.
- Authored-but-not-routed worlds cannot exceed `4.0`.
- Worlds with route/content drift cannot exceed `6.0`.
- Worlds without schema-owned coverage fields cannot exceed `7.0`.
- Worlds without human QA cannot be marked launch-ready.
- Content file count alone never increases readiness.

Delta rules:

- Docs-only classification: `+0.0` to `+0.1` max.
- Route/content normalization accepted: `+0.1` to `+0.3` for affected worlds.
- Validator-backed migration sample: `+0.1` to `+0.3` for affected world.
- L2/L3 validator evidence: `+0.2` to `+0.5`.
- Real content authoring with validation: `+0.3` to `+0.8`.
- Route admission/opening with tests: `+0.5` to `+1.0`.
- Human novice QA passed: `+0.5` to `+1.0`.
- Poker correctness protocol passed: `+0.4` to `+0.8`.
- Monetization/store readiness should not increase world content scores unless
  it changes launch claim safety.

## 3. W1-W12 Readiness Ledger

| World ID | Band | Launch-facing title | Current route status | Content/source status | Source truth status | Schema/validator status | Same-signal coverage | Transfer coverage | Repair path | Progression/payoff | Poker correctness | Human QA | Launch claim safety | Premium value contribution | Previous score | Current score | Delta | Primary blocker | Next required action | Evidence source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---: | ---: | ---: | --- | --- | --- |
| W1 | Foundation | Poker from Zero | learner_playable | strong W1 source plus Act0/spine packs | canonical/migrated with schema-legacy active content | one L0 fixture, one L1 migrated sample, one factory-exported W1 sample, one synthetic L2/L3 coverage-ready fixture, and six real six-task W1 concept-family coverage fixtures; active content still not fully schema migrated | six real same-signal groups passed at 6 tasks each; broader W1 still not fully migrated | six W1 groups have at least 2 transfer surfaces each; broader W1 still not fully migrated | runtime/feedback plus L1/factory/L2 repair fields and six W1 migrated repair-focus groups | strong W1 payoff, not human-validated | conditional pass: no P0 found and P1 bet-size vocabulary source boundary repaired | not done | safe as W1 8.0 certification-passed schema proof, not full W1/10-10 claim | high; first value proof | 7.6 | 8.0 | +0.4 | human QA, full migration, and certification-linked payoff proof remain incomplete | W1 Human QA Protocol | L2 report; Wave 6.3 L1 sample; Tiny factory MVP; L2/L3 validator; W1 coverage pilot; W1-W6 consolidation; W1 certification plan; W1 starting-hand batch; W1 Coverage Expansion PR2; W1 Coverage Expansion PR3; W1 8.0 Certification Review; W1 Poker Correctness Review Protocol; W1 Bet-Size Vocabulary Correctness Repair |
| W2 | Foundation bridge | Hand Discipline | learner_playable via campaign path; Act0 card locked | broad table-reading bridge source | bridge_or_legacy | one tiny factory bridge sample plus one three-task W2 bridge schema migration pilot; L2/L3 reports it as bridge-limited, not canonical coverage | real bridge pilot at 3 same-signal tasks; not canonical threshold coverage | bridge pilot has 3 transfer surfaces; still claim-limited | feedback/review patterns plus factory repair fields | campaign progression exists | review needed | not done | safe only as bridge/foundation support, not hand-discipline mastery | medium; teaches prerequisite reads | 4.5 | 4.7 | +0.2 | source job is broader than route title and W2 remains bridge-limited | W2-W6 Canonical Realignment Plan after W1 certification planning | L2 report; Wave 5.3; W2-W6 normalization; Tiny factory MVP; L2/L3 validator; W1-W6 schema migration pilot; W1-W6 consolidation |
| W3 | Foundation bridge | Position Thinking | learner_playable via campaign path; Act0 card locked | Preflop Framework source | bridge_or_legacy | one three-task W3 bridge schema migration pilot; L2/L3 reports it as bridge-limited, not canonical coverage | real bridge pilot at 3 same-signal tasks; not canonical threshold coverage | bridge pilot has 3 transfer surfaces; still claim-limited | factory repair focus present for pilot | campaign progression exists | review needed | not done | safe only as routed bridge, not position mastery | medium-high; useful preflop bridge | 4.9 | 5.1 | +0.2 | source job differs from route title and remains bridge-limited | W2-W6 Canonical Realignment Plan after W1 certification planning | L2 report; Wave 5.3; W2-W6 normalization; W2-W6 Bridge Coverage Expansion; W1-W6 consolidation |
| W4 | Foundation bridge | Preflop Framework | learner_playable via campaign path; Act0 card locked | Bet Purpose and Price source | bridge_or_legacy | one three-task W4 bridge schema migration pilot; L2/L3 reports it as bridge-limited, not canonical coverage | real bridge pilot at 3 same-signal tasks; not canonical threshold coverage | bridge pilot has 3 transfer surfaces; still claim-limited | factory repair focus present for pilot | campaign progression exists | sizing/purpose review needed | not done | safe only as routed bridge, not preflop-framework mastery | medium-high; strong paid-depth value once normalized | 5.1 | 5.3 | +0.2 | route title and content job are offset and remain bridge-limited | W2-W6 Canonical Realignment Plan after W1 certification planning | L2 report; Wave 5.3; W2-W6 normalization; W2-W6 Bridge Coverage Expansion; W1-W6 consolidation |
| W5 | Developing bridge | Bet Purpose And Price | learner_playable via campaign path; Act0 card locked | Board Awareness source | bridge_or_legacy | one three-task W5 bridge schema migration pilot; L2/L3 reports it as bridge-limited, not canonical coverage | real bridge pilot at 3 same-signal tasks; not canonical threshold coverage | bridge pilot has 3 transfer surfaces; still claim-limited | factory repair focus present for pilot | campaign progression exists | board/draw review needed | not done | safe only as routed bridge, not bet-purpose mastery | high future premium value | 5.1 | 5.3 | +0.2 | route title and content job are offset and remain bridge-limited | W2-W6 Canonical Realignment Plan after W1 certification planning | L2 report; Wave 5.3; W2-W6 normalization; W2-W6 Bridge Coverage Expansion; W1-W6 consolidation |
| W6 | Developing bridge | Board And Draws | learner_playable via campaign path; terminal before W7 gate | Range Thinking source | bridge_or_legacy | one three-task W6 bridge schema migration pilot; L2/L3 reports it as bridge-limited, not canonical coverage | real bridge pilot at 3 same-signal tasks; not canonical threshold coverage | bridge pilot has 3 transfer surfaces; still claim-limited | factory repair focus present for pilot | W6 terminal gate exists | range advice review needed | not done | safe only as routed bridge, not board/draw mastery | high future premium value | 4.9 | 5.1 | +0.2 | route title and content job are offset and remain bridge-limited | W2-W6 Canonical Realignment Plan after W1 certification planning | L2 report; Wave 5.3; W2-W6 normalization; W2-W6 Bridge Coverage Expansion; W1-W6 consolidation |
| W7 | Locked developing | Range Thinking Lite | locked_not_learner_playable | internal authored Stack Depth source | bridge_or_legacy/internal_only | no content-world schema fields; no L1 sample | internal/inferred only | internal/inferred only | internal feedback likely, not source-owned | blocked by W6 terminal gate | stack-depth review needed | not done | not launch-claimable | future premium depth | 2.8 | 2.8 | +0.0 | locked route gate | W7-W12 admission/content lock after W2-W6 schema path | L2 report; W7-W10 route alignment |
| W8 | Locked developing | Stack Depth And Risk | locked_not_learner_playable | internal authored Tournament/ICM source | bridge_or_legacy/internal_only | no content-world schema fields; no L1 sample | internal/inferred only | internal/inferred only | internal feedback likely, not source-owned | blocked by W6 terminal gate | tournament/ICM review needed | not done | not launch-claimable | future premium depth | 2.7 | 2.7 | +0.0 | locked route gate | W7-W12 admission/content lock after W2-W6 schema path | L2 report; W7-W10 route alignment |
| W9 | Locked developing | Tournament Pressure | locked_not_learner_playable | internal authored Exploit Thinking source | bridge_or_legacy/internal_only | no content-world schema fields; no L1 sample | internal/inferred only | internal/inferred only | internal feedback likely, not source-owned | blocked by W6 terminal gate | exploit review needed | not done | not launch-claimable | future premium depth | 2.7 | 2.7 | +0.0 | locked route gate | W7-W12 admission/content lock after W2-W6 schema path | L2 report; W7-W10 route alignment |
| W10 | Locked developing | Player Adjustment | locked_not_learner_playable | internal authored specialization/track source | bridge_or_legacy/internal_only | no content-world schema fields; no L1 sample | internal/inferred only | internal/inferred only | internal feedback likely, not source-owned | blocked by W6 terminal gate; track handoff unresolved | track correctness review needed | not done | not launch-claimable | future premium depth and track value | 3.0 | 3.0 | +0.0 | locked route gate and track handoff | W7-W12 admission/content lock after W2-W6 schema path | L2 report; W7-W10 route alignment |
| W11 | Planned proof | Real Play Transfer | authored_but_not_routed | one source/proof session | authored_but_not_routed | source/proof fixtures, not L1 Content Schema sample | insufficient | insufficient | process proof only | no active handoff | review needed | not done | not launch-claimable | future transfer payoff | 2.2 | 2.2 | +0.0 | no active route or handoff | W11 route admission after W7-W10 and W10 handoff | L2 report; W11 route-proof guard |
| W12 | Planned proof | Mindset Bridge | authored_but_not_routed | one source/proof session | authored_but_not_routed | source/proof fixtures, not L1 Content Schema sample | insufficient | insufficient | process proof only | no active handoff; W13 gateway risk | review needed | not done | not launch-claimable | future Volume I closure | 2.0 | 2.0 | +0.0 | no active route or W11 handoff | W12 boundary/admission after W11 route truth | L2 report; W12 route-proof guard |

## 4. Dimension Scores

These are conservative evidence scores for decision-making, not public claims.

| World | Route | Source truth | Schema | Same-signal | Transfer | Repair | Feedback | Payoff | Correctness | Human QA | Claim safety | Premium value |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| W1 | 7 | 7 | 8 | 8 | 8 | 8 | 7 | 7 | 5 | 0 | 7 | 7 |
| W2 | 5 | 4 | 2 | 5 | 5 | 4 | 6 | 4 | 4 | 0 | 4 | 5 |
| W3 | 5 | 4 | 2 | 6 | 5 | 4 | 6 | 4 | 4 | 0 | 5 | 6 |
| W4 | 5 | 4 | 2 | 6 | 5 | 4 | 6 | 4 | 4 | 0 | 5 | 7 |
| W5 | 5 | 4 | 2 | 6 | 5 | 4 | 6 | 4 | 4 | 0 | 5 | 7 |
| W6 | 5 | 4 | 2 | 5 | 5 | 4 | 6 | 4 | 3 | 0 | 5 | 7 |
| W7 | 1 | 3 | 0 | 3 | 3 | 2 | 4 | 1 | 2 | 0 | 1 | 6 |
| W8 | 1 | 3 | 0 | 3 | 3 | 2 | 4 | 1 | 2 | 0 | 1 | 6 |
| W9 | 1 | 3 | 0 | 3 | 3 | 2 | 4 | 1 | 2 | 0 | 1 | 6 |
| W10 | 1 | 3 | 0 | 3 | 3 | 2 | 4 | 1 | 2 | 0 | 1 | 7 |
| W11 | 1 | 3 | 1 | 1 | 1 | 2 | 3 | 1 | 2 | 0 | 1 | 5 |
| W12 | 1 | 3 | 1 | 1 | 1 | 2 | 3 | 1 | 2 | 0 | 1 | 5 |

## 5. Current Score Movement

World scores reflected in the current ledger:

- W1 moved `6.6 -> 6.9` because a real six-task W1 factory coverage pilot now
  passes foundation validation and L2/L3 validation as one same-signal group
  with three transfer surfaces and a repair focus.
- W1 moved `6.9 -> 7.2` because a second real six-task W1 factory coverage
  batch now passes foundation validation and L2/L3 validation for
  `starting_hand_discipline` with one same-signal group, three transfer
  surfaces, repair focus, preserved migration metadata, and learner-playable
  route readiness.
- W1 moved `7.2 -> 7.6` because two more real six-task W1 factory coverage
  fixtures now pass foundation validation and L2/L3 validation for
  `seat_role_orientation` and `card_board_orientation`, each with same-signal
  threshold pass, transfer surfaces, repair focus, preserved migration
  metadata, and learner-playable route readiness.
- W1 moved `7.6 -> 8.0` because two more real six-task W1 factory coverage
  fixtures now pass foundation validation and L2/L3 validation for
  `bet_size_vocabulary_preview` and `world1_checkpoint_synthesis`, each with
  same-signal threshold pass, transfer surfaces, repair focus, preserved
  migration metadata, and learner-playable route readiness. This makes W1 an
  8.0 certification-review candidate, not a launch-ready world.
- W1 8.0 Certification Review v1 confirmed that W1 legitimately holds `8.0`
  as a certification-passed candidate. It proposes no score movement because
  poker correctness review, human QA, full W1 migration, and
  certification-linked payoff proof remain incomplete.
- W1 Poker Correctness Review Protocol v1 found no P0 correctness blocker, but
  found one P1 source-linked bet-size vocabulary acceptable-preset boundary
  issue. It proposes no score movement and routes the next action to a narrow
  bet-size correctness repair before Human QA Protocol.
- W1 Bet-Size Vocabulary Correctness Repair v1 removed broad source-level
  acceptable substitutes from strict W1 bet-size preview prompts, regenerated
  the PR3 fixture with beginner-safe label wording, and cleared the P1
  bet-size blocker. It proposes no score movement because human QA, full
  migration, and payoff/progression proof remain incomplete.
- W2 moved `4.5 -> 4.7` because a real three-task W2 bridge_or_legacy schema
  migration pilot now passes foundation validation and L2/L3 reporting while
  remaining blocked from canonical launch coverage.
- W3 moved `4.9 -> 5.1`, W4 moved `5.1 -> 5.3`, W5 moved `5.1 -> 5.3`,
  and W6 moved `4.9 -> 5.1` because each now has a real three-task
  bridge_or_legacy schema migration pilot with foundation validation, L2/L3
  reporting, three transfer surfaces, repair focus, and explicit launch-claim
  blocking.

Remaining constraints after the current movement:

- W1 still lacks full schema-owned world migration, human QA, poker
  correctness review, and certification-linked payoff proof, so it remains
  below launch-ready status.
- W2 remains bridge-limited and cannot be counted as canonical Hand Discipline
  launch coverage.
- W3-W6 remain bridge-limited and cannot be counted as canonical launch
  coverage.
- W7-W10 remain locked.
- W11-W12 remain authored but not routed.

Aggregate score proposal:

- W1-W12 Volume I Premium Product Readiness: `5.8 -> 5.9`.
- W1-W12 Volume I Premium Product Readiness after W1 Concept Family Migration
  Batch 1: `5.9 -> 6.0`.
- W1-W12 Volume I Premium Product Readiness after W1 Coverage Expansion PR2:
  `6.0 -> 6.1`.
- W1-W12 Volume I Premium Product Readiness after W1 Coverage Expansion PR3:
  `6.1 -> 6.2`.
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall Top-1 Readiness: `5.6 -> 5.7`.
- Overall Top-1 Readiness after W1 Concept Family Migration Batch 1:
  `5.7 -> 5.8`.
- Overall Top-1 Readiness after W1 Coverage Expansion PR2: `5.8 -> 5.9`.
- Overall Top-1 Readiness after W1 Coverage Expansion PR3: `5.9 -> 6.0`.
- Architecture scalability: `8.0 -> 8.1`.
- Content depth: `4.7 -> 4.8`.
- Content depth after W1 Concept Family Migration Batch 1: `4.8 -> 4.9`.
- Content depth after W1 Coverage Expansion PR2: `4.9 -> 5.0`.
- Content depth after W1 Coverage Expansion PR3: `5.0 -> 5.1`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

Reason: this wave extends executable W1 canonical coverage proof from four to
six source-derived concept families while preserving W2-W6 bridge limits. It
reduces W1 certification-breadth and fixture-scope risk but does not complete
human QA, full W1 migration, payoff/progression proof, route-admit new worlds,
author content, monetize, or launch-claim content.

## 6. Active Next Action

Recommended next step:

`W1 Human QA Protocol`

Why:

- W1 Bet-Size Vocabulary Correctness Repair v1 cleared the known P1
  source-linked bet-size vocabulary boundary issue.
- W1 is the only W1-W6 world with canonical route-ready coverage evidence.
- W1 has six real schema-backed concept families:
  `position_action_order`, `starting_hand_discipline`,
  `seat_role_orientation`, `card_board_orientation`,
  `bet_size_vocabulary_preview`, and `world1_checkpoint_synthesis`.
- The next bottleneck is human novice QA before payoff/progression
  certification, broad migration, W2-W6 realignment, or W7-W12 admission.

Must not skip:

- Keep W1-W6 migration validator-led.
- Preserve all six W1 positive controls during correctness review:
  `position_action_order`, `starting_hand_discipline`,
  `seat_role_orientation`, `card_board_orientation`,
  `bet_size_vocabulary_preview`, and `world1_checkpoint_synthesis`.
- Do not advance W1 to 9.0 without human QA and remaining
  payoff/progression evidence.
- Do not author new content unless a future prompt explicitly admits a tiny
  source-normalization correction.
- Do not bulk-migrate W1-W6.
- Do not count bridge_or_legacy content as canonical launch coverage.
- Do not open W7-W12.
- Do not claim coverage-ready from bridge/legacy content.
- Do not make W13-W36 launch claims.
