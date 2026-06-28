# Volume I World Readiness Ledger v1

Status: ACTIVE control-plane ledger for W1-W12 launch readiness.
Created: 2026-06-28.
Last refreshed: 2026-06-28 after W2-W6 Route/Content Normalization v1.

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
| W1 | Foundation | Poker from Zero | learner_playable | strong W1 source plus Act0/spine packs | canonical with schema-legacy active content | one L0 fixture and one L1 migrated sample; active content still schema legacy | strong but mostly inferred | present but mostly inferred | runtime/feedback plus one L1 repair field | strong W1 payoff, not human-validated | review needed before premium/public claims | not done | safe as W1 foundation, not 10/10 claim | high; first value proof | 6.5 | 6.5 | +0.0 | active content lacks schema-owned coverage fields and human QA | W1 schema migration/coverage after W2-W6 normalization | L2 report; Wave 6.3 L1 sample |
| W2 | Foundation bridge | Hand Discipline | learner_playable via campaign path; Act0 card locked | broad table-reading bridge source | bridge_or_legacy | no content-world schema fields; no L1 sample | partial/inferred | bridge transfer inferred | feedback/review patterns, no source-owned repair field | campaign progression exists | review needed | not done | safe only as bridge/foundation support, not hand-discipline mastery | medium; teaches prerequisite reads | 4.3 | 4.4 | +0.1 | source job is broader than route title | Schema-normalize W2 as bridge_or_legacy before authoring | L2 report; Wave 5.3; W2-W6 normalization |
| W3 | Foundation bridge | Position Thinking | learner_playable via campaign path; Act0 card locked | Preflop Framework source | bridge_or_legacy | no content-world schema fields; no L1 sample | strong/inferred preflop chain arc | chain transfer inferred | feedback exists, no source-owned repair field | campaign progression exists | review needed | not done | safe only as routed bridge, not position mastery | medium-high; useful preflop bridge | 4.8 | 4.9 | +0.1 | source job differs from route title | Schema-normalize W3 as bridge_or_legacy before coverage claims | L2 report; Wave 5.3; W2-W6 normalization |
| W4 | Foundation bridge | Preflop Framework | learner_playable via campaign path; Act0 card locked | Bet Purpose and Price source | bridge_or_legacy | no content-world schema fields; no L1 sample | strong/inferred purpose-price coverage | action/size transfer inferred | feedback exists, no source-owned repair field | campaign progression exists | sizing/purpose review needed | not done | safe only as routed bridge, not preflop-framework mastery | medium-high; strong paid-depth value once normalized | 5.0 | 5.1 | +0.1 | route title and content job are offset | Schema-normalize W4 as bridge_or_legacy before migration | L2 report; Wave 5.3; W2-W6 normalization |
| W5 | Developing bridge | Bet Purpose And Price | learner_playable via campaign path; Act0 card locked | Board Awareness source | bridge_or_legacy | no content-world schema fields; no L1 sample | strong/inferred board texture coverage | texture-to-action transfer inferred | recap/feedback exists, no source-owned repair field | campaign progression exists | board/draw review needed | not done | safe only as routed bridge, not bet-purpose mastery | high future premium value | 5.0 | 5.1 | +0.1 | route title and content job are offset | Schema-normalize W5 as bridge_or_legacy before factory migration | L2 report; Wave 5.3; W2-W6 normalization |
| W6 | Developing bridge | Board And Draws | learner_playable via campaign path; terminal before W7 gate | Range Thinking source | bridge_or_legacy | no content-world schema fields; no L1 sample | strong/inferred range aggregate; direct range bucket usable but fragile | range/board transfer inferred | feedback exists, no source-owned repair field | W6 terminal gate exists | range advice review needed | not done | safe only as routed bridge, not board/draw mastery | high future premium value | 4.8 | 4.9 | +0.1 | route title and content job are offset | Schema-normalize W6 as bridge_or_legacy and preserve W6 terminal gate | L2 report; Wave 5.3; W2-W6 normalization |
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
| W1 | 7 | 7 | 4 | 7 | 6 | 5 | 7 | 7 | 5 | 0 | 6 | 7 |
| W2 | 5 | 4 | 1 | 4 | 4 | 3 | 6 | 4 | 4 | 0 | 4 | 5 |
| W3 | 5 | 4 | 1 | 6 | 5 | 3 | 6 | 4 | 4 | 0 | 4 | 6 |
| W4 | 5 | 4 | 1 | 6 | 5 | 3 | 6 | 4 | 4 | 0 | 4 | 7 |
| W5 | 5 | 4 | 1 | 6 | 5 | 3 | 6 | 4 | 4 | 0 | 4 | 7 |
| W6 | 5 | 4 | 1 | 5 | 5 | 3 | 6 | 4 | 3 | 0 | 4 | 7 |
| W7 | 1 | 3 | 0 | 3 | 3 | 2 | 4 | 1 | 2 | 0 | 1 | 6 |
| W8 | 1 | 3 | 0 | 3 | 3 | 2 | 4 | 1 | 2 | 0 | 1 | 6 |
| W9 | 1 | 3 | 0 | 3 | 3 | 2 | 4 | 1 | 2 | 0 | 1 | 6 |
| W10 | 1 | 3 | 0 | 3 | 3 | 2 | 4 | 1 | 2 | 0 | 1 | 7 |
| W11 | 1 | 3 | 1 | 1 | 1 | 2 | 3 | 1 | 2 | 0 | 1 | 5 |
| W12 | 1 | 3 | 1 | 1 | 1 | 2 | 3 | 1 | 2 | 0 | 1 | 5 |

## 5. Current Score Movement

World scores moved this wave:

- W2: `4.3 -> 4.4` because the bridge/legacy migration posture is now explicit.
- W3: `4.8 -> 4.9` because the bridge/legacy migration posture is now explicit.
- W4: `5.0 -> 5.1` because the bridge/legacy migration posture is now explicit.
- W5: `5.0 -> 5.1` because the bridge/legacy migration posture is now explicit.
- W6: `4.8 -> 4.9` because the bridge/legacy migration posture is now explicit.

World scores did not move where no readiness risk moved:

- W1 did not gain new schema coverage, QA, or correctness evidence.
- W7-W10 remain locked.
- W11-W12 remain authored but not routed.

Aggregate score proposal:

- W1-W12 Volume I Premium Product Readiness: `5.3 -> 5.4`.
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall Top-1 Readiness: `5.1 -> 5.2`.
- Architecture scalability: `7.3 -> 7.4`.
- Content depth: unchanged at `4.5`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

Reason: this wave removes migration-target ambiguity for W2-W6 but does not
author, migrate, validate, route-admit, QA, or correctness-review content.

## 6. Active Next Action

Recommended next step:

`Tiny Content Factory Import/Export MVP`

Why:

- W2-W6 now have stable migration posture:
  `route_world_id=<same world>`, active route title as `display_world_title`,
  current source folder as `content_owner_world_id`, `source_truth_status` as
  `bridge_or_legacy`, and `route_gate_status` as `learner_playable` only for
  the campaign path.
- A tiny factory/import-export proof can now preserve route title and source
  job separately without pretending content is launch-coverage-ready.

Must not skip:

- Keep factory proof tiny.
- Do not author new content.
- Do not bulk-migrate W1-W6.
- Do not open W7-W12.
- Do not claim coverage-ready from bridge/legacy content.
- Do not make W13-W36 launch claims.
