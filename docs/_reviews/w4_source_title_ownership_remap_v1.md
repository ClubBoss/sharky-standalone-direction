# W4 Source/Title Ownership Remap v1

Branch: `codex/w4-source-title-ownership-remap-v1`.
Baseline: `bc76b5c9` (`w4_canonical_certification_blocked_by_route_title_gap`).

## 1. Verdict

`w4_source_title_ownership_recommends_title_job_plan`

W4 source ownership is not safe for a canonical fixture PR2 under the current
learner-facing title. The source is coherent, but it teaches Bet Purpose and
Price, not a route-owned `Preflop Framework` competency.

Recommended next wave: `W4 Route Title/Job Realignment Plan`.

## 2. Source truth

Focused W4 source read:

- `content/worlds/world4/v1/world.md`
- `content/worlds/world4/v1/sessions/index.md`
- `content/worlds/world4/v1/sessions/w4.s01/session.md`
- `content/worlds/world4/v1/sessions/w4.s02/session.md`
- `content/worlds/world4/v1/sessions/w4.s03/session.md`
- `content/worlds/world4/v1/sessions/w4.s04/session.md`
- `content/worlds/world4/v1/sessions/w4.s05/session.md`
- `content/worlds/world4/v1/sessions/w4.s06/session.md`
- `content/worlds/world4/v1/sessions/w4.s07/session.md`
- `content/worlds/world4/v1/sessions/w4.s08/session.md`
- `content/worlds/world4/v1/sessions/w4.s09/session.md`
- `content/worlds/world4/v1/sessions/w4.s10/session.md`
- `test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json`

Current W4 source teaches:

- bet purpose before sizing sophistication;
- practical price awareness;
- value, protection, bluff, denial, and controlled reopen intent;
- size presets such as one-third pot, half pot, pot, and minimum raise;
- price effects after a compact betting decision.

The source explicitly says it sits before deeper preflop framework, board/range
work, or specialization policy. That makes it a strong Bet Purpose / Price
source, not current-title W4 canonical source.

## 3. Current W4 state

- Route world: `world_4`.
- Launch-facing title: `Preflop Framework`.
- Current source job: Bet Purpose and Price.
- Fixture status: one three-task bridge fixture,
  `w4_bridge_or_legacy_schema_migration_pilot_v1.json`.
- Fixture concept family: `bet_purpose_price_bridge`.
- Fixture claim posture: `source_truth_status: bridge_or_legacy`,
  `safe_claim_status: limited_bridge`, and
  `launch_coverage_claimed: false`.
- Validator posture: valid bridge evidence, not coverage-ready canonical
  evidence.

## 4. Route/title truth

Active route truth says W4 is `Preflop Framework`.

That title promises preflop-framework mastery to a learner: a structured
preflop decision frame, not merely post-action sizing purpose or price
intuition. It implies that any canonical W4 fixture must be route-owned by
preflop framework concepts and must not depend on a metadata relabel of
bet-purpose source.

Current W4 source does not satisfy that promise. Bet Purpose / Price is related
to the wider poker decision model, but it is a separate job in the active title
map, not an honest subset of W4 `Preflop Framework` under the current route
contract.

## 5. Source ownership map

| Bucket | W4 source groups | Decision |
| --- | --- | --- |
| `w4_canonical_owned` | None found under current title. | No canonical PR2 now. |
| `w4_canonical_candidate_after_title_or_source_remap` | Value-intent sizing, protection-intent sizing, bluff-intent sizing, denial-intent sizing, controlled reopen, mixed purpose-and-price checkpoints. | Candidate only if a future route/title/job decision explicitly makes Bet Purpose / Price W4-owned or changes the title contract. |
| `bridge_or_legacy_only` | Existing `bet_purpose_price_bridge` fixture and all current W4 bridge evidence. | Keep claim-limited and separated from canonical coverage. |
| `belongs_to_other_world` | Bet Purpose / Price as a route label appears naturally aligned with the active W5 title, but this wave does not inspect or change W5. | Treat as cross-world ownership candidate, not a W4 canonical source. |
| `unsafe_or_deferred` | Any W4 canonical fixture claiming `Preflop Framework` from current bet-purpose/price source. | Unsafe metadata-only overclaim; defer. |

## 6. Option matrix

| Option | Upside | Risk | Decision |
| --- | --- | --- | --- |
| Keep W4 bridge-limited and move to W5 pilot | Avoids W4 title overclaim. | W5 already has its own route/source offset in the W2-W6 decision; moving there would likely repeat the same blocker without resolving W4. | Do not choose now. |
| W4 source ownership remap then canonical PR2 | Would be valid if Bet Purpose / Price is accepted as W4-owned. | This remap found no current-title W4 canonical-owned group. PR2 would still be metadata-only. | Reject for next wave. |
| W4 title/job realignment plan | Directly decides whether W4 title, job, or source ownership should change before fixture work. | Docs-only and does not create coverage. | Choose next. |
| W4 new source authorship later | Could create true Preflop Framework source under W4. | New authorship is explicitly out of scope and premature before title/job decision. | Defer. |
| W2-W6 batch canonicalization plan | Could address multiple offsets together. | Batch work is unsafe while W4-W6 title/source ownership remains unresolved. | Reject. |

## 7. Recommended next wave

`W4 Route Title/Job Realignment Plan`

Reason:

- Bet Purpose / Price is not honestly a subset of current-title W4
  `Preflop Framework`.
- A canonical W4 PR2 would require either title/job realignment, source
  ownership remap that changes the route contract, or new Preflop Framework
  source.
- The safest next step is a docs-only title/job plan, not fixture creation,
  not W5 inspection, and not W2-W6 batch canonicalization.

## 8. W4 certification impact

W4 remains bridge-limited.

No canonical fixture, technical 8.0, launch, 9.0, Human QA, solver/GTO, or
runtime claim is added.

## 9. Ledger impact

Proposed score movement: `+0.0`.

This wave improves decision clarity but does not create executable canonical
coverage. W4 stays `5.3`, and the next required action becomes
`W4 Route Title/Job Realignment Plan`.

## 10. Route impact

No route, runtime title, Act0 card, display title, monetization boundary, or
W5-W12 state was changed.

The route/title conflict remains explicit:

- route title: `Preflop Framework`;
- source job: Bet Purpose and Price;
- next decision: title/job realignment plan before fixture work.

## 11. Active repair queue update

Replace the active next wave:

- completed wave: `W4 Source/Title Ownership Remap`;
- next wave: `W4 Route Title/Job Realignment Plan`.

Do not run `W4 Canonical Certification Pilot PR2` until that plan explicitly
proves a W4-owned Preflop Framework source slice or changes the title/job
contract.

## 12. Evidence DoD status

- W4 foundation validator: pass.
- W4 L2/L3 validator on existing bridge fixture: pass.
- `graphify hook-check`: pass.
- `git diff --check`: pass.
- `git diff --cached --check`: pass.
- direct ASCII / diff-only ASCII: pass.
- trailing whitespace / CRLF / final-newline checks: pass.

No screenshots were taken.

## 13. Anti-theater check

Pass.

This wave does not convert Bet Purpose / Price source into fake
`Preflop Framework` certification. It keeps the existing bridge fixture
claim-limited, refuses canonical PR2 under the current title, avoids W5-W12
inspection or mutation, and selects a docs-only title/job decision before any
fixture work.
