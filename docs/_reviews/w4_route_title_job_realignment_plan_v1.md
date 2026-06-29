# W4 Route Title/Job Realignment Plan v1

Branch: `codex/w4-route-title-job-realignment-plan-v1`.
Baseline: `9438f246` (`w4_source_title_ownership_recommends_title_job_plan`).

## 1. Verdict

`w4_route_title_job_recommends_title_change_later`

W4 should not attempt a canonical fixture under the current
`Preflop Framework` learner-facing title. The strongest product/content path is
to plan a future W4 title/job realignment toward Bet Purpose / Price before any
W4 canonical certification PR2.

Recommended next wave: `W4 Title/Job Realignment PR2`.

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

Current W4 source is internally coherent. It teaches bet purpose and practical
price awareness through value, protection, bluff, denial, controlled reopen,
one-third pot, half-pot, pot, and minimum-raise decisions.

The source also says World 4 sits before deeper preflop framework, advanced
board/range work, or specialization policy. That line makes the source
truth stronger as Bet Purpose / Price than as current-title
`Preflop Framework`.

## 3. Current W4 state

- Route world: `world_4`.
- Launch-facing title: `Preflop Framework`.
- Current authored source job: Bet Purpose and Price.
- Existing fixture:
  `test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json`.
- Existing fixture concept family: `bet_purpose_price_bridge`.
- Existing fixture posture: `source_truth_status: bridge_or_legacy`,
  `safe_claim_status: limited_bridge`, and
  `launch_coverage_claimed: false`.
- W4 certification state: bridge-limited only; no canonical fixture exists.

## 4. Product job truth

W4's position in the W1-W12 sequence should teach the next clear foundation job
after W1 Poker from Zero, W2 Hand Discipline, and W3 Position Thinking. Both
candidate jobs have plausible learner value, but they are not equally supported
by current source.

`Preflop Framework` has learner EV at W4 only if W4 owns a structured preflop
decision framework: starting conditions, position-aware entry discipline,
open/call/fold shape, and a beginner-safe bridge from W3 position thinking into
repeatable preflop choices. Current W4 source does not provide that evidence.

Bet Purpose / Price has clearer learner EV for the existing W4 source. It
teaches a compact, high-frequency poker decision: why a bet or raise is being
made and what price it gives the opponent. It is a natural foundation bridge
from action stability into later board, range, stack, and specialization work.

Product-job conclusion:

- Keep the runtime route title unchanged in this wave.
- Do not treat Bet Purpose / Price as a bounded submodule of
  `Preflop Framework` for canonical certification.
- Plan a later title/job realignment if W4 is intended to own the existing
  source.
- If product leadership keeps W4 as `Preflop Framework`, W4 needs source
  authorship later before canonical certification.

## 5. Title/source alignment options

| Option | Decision | Reason |
| --- | --- | --- |
| Keep W4 title `Preflop Framework` and defer canonicalization until source exists | Safe fallback, but not the highest-EV next step. | It avoids overclaim, but it leaves the coherent W4 Bet Purpose / Price source stranded as bridge-only evidence. |
| Plan future title/job realignment toward Bet Purpose / Price | Recommended. | It aligns learner-facing promise with the source that already exists and preserves claim safety before any runtime title change. |
| Keep title but narrow claim to `Preflop Framework / Bet Purpose submodule` | Reject. | The source says it precedes deeper preflop framework; a submodule claim would still convert source/job mismatch into canonical evidence by wording. |
| Move Bet Purpose / Price to another world/job later | Defer. | It may be correct in a full W2-W6 normalization pass, but this wave must not inspect or mutate W5-W12 and should not create cross-world churn. |
| Pause W4 and proceed to W5 pilot | Reject for next wave. | W5 has a known route/source offset from the W2-W6 decision, so moving there would likely repeat the same blocker while W4 remains unresolved. |

## 6. Risk matrix

| Option | Learner clarity | Product EV | Implementation cost | Source truth risk | Claim safety risk | Regression risk | Launch-readiness impact | Decision |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Keep W4 title and wait for true Preflop Framework source | Medium; title is familiar but unsupported by current source. | Medium; preserves current route map. | Low now, higher later because new source is required. | Low if no fixture is created. | Low while bridge-limited. | Low now. | No movement. | Safe fallback only. |
| Future W4 title/job realignment toward Bet Purpose / Price | High; title would match the actual learning job. | High; uses coherent existing source and strengthens W4 foundation value. | Medium later because route/title control-plane and runtime copy must be deliberately changed. | Low if done before fixture creation. | Low if launch claims stay off until validators pass. | Medium; title changes can affect route expectations. | Decision risk reduced now; readiness moves only after implementation and validation. | Recommended. |
| Bounded submodule claim under current title | Medium-low; learner may not understand why preflop framework means sizing purpose. | Medium short term, poor long term. | Low. | High because source does not claim that job. | High; would invite false canonical coverage. | Medium. | Unsafe apparent movement. | Reject. |
| Move Bet Purpose / Price to another world/job later | Unknown without W5-W12 inspection. | Possibly high in a batch normalization wave. | High. | Medium; cross-world ownership must be proven. | Medium. | High. | Deferred. | Do not choose now. |
| Proceed to W5 pilot | Low for W4 because blocker remains open. | Low-medium; may find evidence elsewhere but likely repeats route/source offset. | Medium. | Medium-high. | Medium-high. | Medium. | No W4 movement. | Reject for next wave. |

## 7. Recommended next wave

`W4 Title/Job Realignment PR2`

Scope for that wave:

- decide the exact W4 learner-facing job contract;
- draft the minimal control-plane and route-title change plan if W4 should
  become Bet Purpose / Price;
- keep runtime/title mutation out unless that future prompt explicitly admits
  it;
- do not create a canonical fixture until the title/job contract is accepted;
- preserve W4 bridge evidence as bridge-limited negative control.

Do not run `W4 Canonical Certification Pilot PR2 with bounded submodule claim`.
The bounded submodule path is not honest enough under current source truth.

## 8. W4 certification impact

W4 remains bridge-limited.

No W4 canonical fixture, technical 8.0 movement, launch claim, 9.0 claim, Human
QA claim, solver/GTO claim, UI change, telemetry expansion, or runtime route
change is added.

## 9. Ledger impact

Proposed score movement: `+0.0`.

This wave improves product-job clarity but does not add executable canonical
coverage. W4 remains `5.3`, and the active next action moves from
`W4 Route Title/Job Realignment Plan` to `W4 Title/Job Realignment PR2`.

## 10. Route impact

No route, runtime title, Act0 card, display title, entitlement boundary, or
W5-W12 state changed.

Current route/title truth remains:

- W4 route title: `Preflop Framework`.
- W4 source job: Bet Purpose and Price.
- W4 fixture state: bridge-limited only.
- Future decision: title/job realignment before canonical fixture work.

## 11. Active repair queue update

Replace the active next wave:

- completed wave: `W4 Route Title/Job Realignment Plan`;
- next wave: `W4 Title/Job Realignment PR2`.

The next wave should not claim W4 canonical readiness. Its job is to convert
this plan into an accepted title/job ownership decision or a documented stop.

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

This wave does not make a fixture, does not relabel bridge evidence as
canonical evidence, does not change a runtime title, and does not smooth over
the W4 mismatch with a submodule phrase. It chooses the honest next step:
accept or reject a W4 title/job realignment before W4 canonical certification
continues.
