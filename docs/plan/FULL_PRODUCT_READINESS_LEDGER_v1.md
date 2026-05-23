# FULL_PRODUCT_READINESS_LEDGER_v1

Status: ACTIVE
Purpose: canonical full-product readiness ledger so strong Act0 route mechanics
are not mistaken for whole-product readiness.
Last updated: 2026-05-22

## Authority

Use this file beneath:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/ACT0_PRODUCT_100_EXECUTION_ROUTE_v1.md`
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`

This file is the canonical full-product readiness ledger.

Use it for:

- whole-product readiness framing
- cross-department readiness truth
- separating Act0 route strength from app-wide readiness
- future summary update rules
- bounded next-wave ordering after the fast-loop floor is green
- readiness reporting beneath the compact execution-policy wrapper in
  `docs/plan/EXECUTION_POLICY_SSOT_v1.md`

Do not use it for:

- replacing `MASTER_PLAN_v3.0.md` as product-routing authority
- daily task selection inside one narrow product seam
- pretending that every low-readiness block must be worked now

## Why This Ledger Exists

Current repo truth now makes one distinction mandatory:

- `Act0 route mechanics` can be strong
- while `full product readiness` stays materially lower

As of 2026-05-21:

- Act0 route mechanics is approximately `93 / 100`
- `./tools/fast_loop_world1_v1.sh` is now clean
- unit-based full product readiness is still materially lower, roughly the
  mid-`50s`
- commercial / release readiness is much lower than the active EN route

This file prevents false summaries such as:

- `Act0 route mechanics is 93 / 100, therefore the whole product is 93 / 100`

## Unit-Based Aggregate Calibration

This ledger now uses conservative unit-based aggregate scoring as the default
readiness model.

Formula:

- `earned_units = sum(current block units)`
- `max_units = sum(max block units)`
- `aggregate_readiness = earned_units / max_units`

Rules:

- default wave delta is `0`
- a wave does not move readiness just because it completed
- each movement must name the risk that was materially reduced
- local improvements must not inflate unrelated aggregate layers
- documentation-only waves may improve SSOT clarity, but they do not raise
  product quality unless they materially unblock execution

Delta types:

- `Product Quality Delta`
- `Proof Confidence Delta`
- `Release Readiness Delta`
- `Documentation / SSOT Clarity Delta`

Risk classes that must be named before any score movement:

- `user-facing quality risk`
- `proof / confidence risk`
- `release / commercial risk`
- `operational clarity risk`

Aggregate guardrails:

- `Act0 Route Mechanics` stays frozen at `93 / 100` until a broad route
  milestone lands
- `Full Product Readiness` must not be inflated by local Act0 proof, copy, or
  presentation wins
- `Commercial / Release Readiness` must not move from product UX waves
- low blocks such as `Telemetry`, `Monetization`, `RU`, `Visual`, `Human Novice QA`,
  `Store / Legal / Release Ops`, or broader coverage must keep aggregate scores
  conservative
- audit-only visual proof may raise evidence confidence, not visual quality, if
  no UI changed

## Current Aggregate Calibration

Current unit-derived aggregates from the block ledger below:

| Aggregate layer | Block basis | Earned / Max | Unit-based score | Confidence | Note |
| --- | --- | ---: | ---: | --- | --- |
| Act0 Route Mechanics | frozen route authority | n/a | `93 / 100` | High | frozen until a broad route milestone lands |
| W1-W12 Scale-Ready Readiness | core route + Home + Learn + Runner + Review + Practice + Content + First-Run + World Completion + Profile + Technical Proof / CI | `95 / 125` | `76.0 / 100` | Medium | recalculated route-foundation aggregate after syncing accepted prior deltas; still lower than route mechanics by design |
| EN Learning Experience | core route + Learn + Runner + Review + Practice + Content + First-Run + World Completion + Profile + Technical Proof / CI | `86 / 115` | `74.8 / 100` | Medium | recalculated learner-facing system aggregate; excludes Home command-center weight and remains below route mechanics |
| Full Product Readiness | all current block units in this ledger | `125 / 215` | `58.1 / 100` | Medium | recalculated whole-product aggregate after syncing accepted prior deltas; still conservative by design |
| Commercial / Release Readiness | Store / Legal / Release Ops + Monetization / Commercial + Telemetry / Learning Events + Technical Proof / CI | `17.5 / 40` | `43.8 / 100` | Medium-Low | recalculated downstream release aggregate after telemetry and proof-floor reconciliation |

Calibration note:

- earlier narrative percentages remain useful for quick orientation, but unit
  aggregates are now authoritative when the two disagree
- if future work changes the block set or layer membership, recompute the
  aggregates explicitly instead of carrying old percentages forward
- block-unit corrections that only sync this ledger with prior landed waves are
  not new readiness movement for the current docs-only wave
- aggregate scores are not raised by documentation-only calibration work; if
  block units are corrected later, recompute aggregates in an explicitly
  admitted recalibration wave

Reconciliation note for `2026-05-22`:

- accepted prior additive movements synced here:
  - `Technical Proof / CI: +0.5`
  - `Telemetry / Learning Events: +0.5`
- recorded as evidence-only, not new unit movement in this docs wave:
  - controlled-demo packet is now green and provisionally ready for an internal
    walkthrough only
  - compact Learn / Runner feedback / Review / Practice / Profile / World
    Completion improvements landed and should inform future next-wave selection

Foundation-depth note:

- coverage-only completion is not enough for foundation readiness
- a concept family may be present but still partial if it lacks visual table
  proof, adjacent comparison, decision transfer, best-five/showdown proof where
  relevant, misconception-specific feedback, or mistake-recovery reuse
- `Concept.md` may be used as an external benchmark/checklist to detect this
  coverage illusion, but must not be imported as a giant content backlog
- after the Hand Strength W1 owner-seam repairs, that seam is strong enough to
  park locally; broader foundation depth is still not fully proven
- the next active foundation-depth frontier is currently `Board Reading /
  Draws` plus `Pot / Stack / All-in / Side-pot` truth
- novice-prep should wait until those key depth illusions are reduced

## Readiness Coverage Map

Coverage verdict: `MOSTLY COMPLETE`.

The current block set covers the path to a serious W1-W12 foundation, controlled
demo, external novice QA, public beta / store release, and later W13-W24
expansion. The main missing piece was not a new block; it was an explicit
dependency-gate model so additive unit movement cannot be mistaken for gate
readiness.

| Readiness level | Covered by | What 100 means | Hard gates that cannot be replaced by points | Current calibration |
| --- | --- | --- | --- | --- |
| W1-W12 scale-ready foundation | Act0 EN Core Route Proof; Learn; Runner; Review; Practice; Content; First-Run; World Completion; Profile; Technical Proof / CI | W1-W12 behaves like a reusable world factory with stable route, owner seams, learning loop, payoff, and proof floor | route/proof green; content depth floor; Learn/Practice/Review/Profile/Completion payoff floor; compact visual/device floor; telemetry truth map at least defined; technical gate green | additive score is useful, but scale-ready is blocked until telemetry truth and reusable factory proof are stronger |
| Controlled internal demo | W1-W12 foundation blocks plus Visual Premium / Cross-Screen and Technical Proof / CI | the active route can be shown internally without known visual/payoff/device gaps dominating the walkthrough | fast loop and release gate green; obvious compact issues are not dominant; Home remains closed-watch; demo path is deterministic; known deferred lanes are labeled | provisionally ready for internal walkthrough; still internal only, not a substitute for novice or release proof |
| External Human QA ready | Controlled-demo floor plus Human Novice QA packet | novice feedback measures the product, not already-known unfinished tails | full controlled-demo packet green; no dominant visible UX/visual blocker; Learn -> Runner -> Feedback -> Review -> Practice -> Profile story understandable; Practice/Profile/World Completion payoff not obviously thin; compact phone presentation demo-safe; content transfer gaps not obvious in the walkthrough; task script and observation template prepared | still blocked; internal demo readiness alone is not enough, and the next EV is a visible W1-W12 demo-quality push until those visible gates are stronger |
| Public beta / store release ready | Store / Legal / Release Ops; Technical Proof / CI; Telemetry; RU if marketed; Monetization / Commercial; Visual/store screenshots | a public user can install, understand, trust, and get support from the app with clear privacy/legal/commercial posture | legal/support/store artifacts; privacy/data posture; release gate; screenshots/device proof; analytics/telemetry decision; commercial/monetization decision; broader QA | materially blocked by low release/commercial/privacy/support artifacts |
| W13-W24 expansion ready | W13-W24 / Broader World Expansion plus W1-W12 scale-ready blocks | the world factory is stable enough that expansion multiplies a good pattern rather than unfinished debt | W1-W12 scale-ready; content authoring template stable; localization handoff stable; telemetry truth stable; visual/device rules stable; no unresolved structural UX debt that would multiply | intentionally not active; keep `Calibration Pending` until W1-W12 gates are met |

## Dependency Gate Matrix

Use this matrix alongside unit scoring. A block can earn additive units without
opening the next readiness level if a hard dependency gate is still closed.

| Gate | Required evidence | Blocking conditions | Counts as |
| --- | --- | --- | --- |
| Route/proof gate | `flutter analyze`, fast loop, route/order guards, release gate when relevant | red fast loop, route-order drift, canonical entry drift, dirty proof command | additive units plus hard gate |
| Content factory gate | W1-W12 depth/transfer floor, owner seams, content authoring pattern | thin transfer density, coverage illusion, unclear content owners, one-off content patches that do not scale | additive units plus W13-W24 hard gate |
| Payoff/identity gate | Learn/Practice/Review/Profile/World Completion explain value and next reason | payoff feels procedural, utility/card-stack hierarchy dominates, learner identity is unclear | additive units plus demo/novice gate |
| Visual/device gate | compact portrait proof, safe areas, CTA hierarchy, screenshot-grade surfaces | unreadable compact states, obvious alpha visuals, store screenshots would expose unfinished theme | additive units plus demo/store gate |
| Telemetry/privacy gate | telemetry truth map, event contract, privacy posture, release decision | no event ownership, no data boundary, analytics would be improvised during release | hard gate for beta and learning-loop validation |
| Human QA gate | controlled task packet, observation map, owner-routing rules, and a visible W1-W12 demo-quality floor | known visual/payoff gaps dominate feedback, no script, no evidence capture path, or the walkthrough story is still visibly thin | hard gate for external novice QA |
| Release ops gate | legal/support/store artifacts, release checklist, rollback/proof command | no legal/support surface, no store package, no release artifact truth | hard gate for public beta/store |
| Commercial gate | value proposition, entitlement/pricing/paywall decision, non-pressure framing | monetization vague or risks distorting learning experience | hard gate for commercial release |
| Expansion gate | W1-W12 factory stable and reusable across content/localization/visual/telemetry/proof | unresolved structural UX debt would multiply into W13-W24 | hard gate for W13-W24 |

## Double-Counting / Missing-Block Audit

No new major block is required at this time. The main calibration risk is
overlap: future reports must name whether a wave moved additive units, a
dependency gate, both, or neither.

| Potential overlap | Verdict | Calibration rule |
| --- | --- | --- |
| Visual Premium / Cross-Screen vs Deep Ocean Gold / Brand Theme | distinct | Visual Premium scores screen readability and device presentation; Deep Ocean scores brand/token system readiness. A token migration can move both only if it improves real screen readability and proves brand system quality. |
| Learn/Profile/Practice/Review presentation vs Visual Premium | allowed overlap with guard | Screen-specific presentation moves the owning product block first. Visual Premium moves only when the change materially improves compact cross-screen presentation, not for every local hierarchy tweak. |
| World Completion payoff vs Profile payoff | distinct | World Completion owns the moment-of-completion milestone. Profile owns durable learner identity and evidence across sessions. Do not count the same copy as both unless each surface materially improves its own job. |
| Store screenshots vs visual readiness | distinct but dependent | Visual readiness makes screenshots viable. Store / Legal / Release Ops moves only when screenshot artifacts and store package requirements are actually produced or verified. |
| Technical Proof / CI vs Store / Legal / Release Ops | distinct | Technical Proof scores commands and proof floor. Release Ops scores packaging, checklist, rollback, submission/support/legal artifacts. A release-gate script alone is not a store package. |
| RU / Localization vs Translation SSOT | distinct | Translation SSOT clarity can move `Documentation / SSOT Clarity`; learner-facing RU quality moves only through active runtime localization work. Archived files never count as active coverage. |
| Telemetry Truth Map vs privacy/release readiness | dependent | Telemetry Truth Map can move telemetry clarity. Public beta remains blocked until privacy/data posture is decided and release artifacts reflect it. |
| Human Novice QA vs internal proof | distinct gate | Internal tests can make novice QA safer to run, but do not replace novice evidence. Human QA units move only from admitted human evidence. |

Future report rule:

- every wave summary must state whether the work affects additive readiness
  units, a dependency gate, both, or neither
- default is `neither` unless evidence shows material risk reduction
- gate movement does not automatically change unit totals, and unit movement
  does not automatically open a gate

## Current Layer Model

| Layer | Current score | Confidence | Why it is not the same as the others | Main blockers | Next 3 high-EV waves |
| --- | ---: | --- | --- | --- | --- |
| Act0 Route Mechanics | 93 / 100 | High | Measures the current EN Act0 route and proof floor, not the whole app. | novice proof, device proof, deeper payoff, remaining non-route systems | Visible W1-W12 demo-quality push or top packet blocker; Telemetry Local Sink v3 only if admitted; Store / Legal / Release Ops only if explicitly admitted |
| EN Learning Experience | 74.8 / 100 | Medium | Includes route + content + feedback + review + practice + payoff, not only route mechanics. | novice proof, profile payoff depth beyond the compact layer, limited long-tail transfer density | Visible W1-W12 demo-quality push or top packet blocker; Practice/Profile payoff follow-through only with fresh evidence; Content depth / transfer-density lift v2 only if a clear owner seam reappears |
| Full Product Readiness | 58.1 / 100 | Medium | Includes learning plus visuals, localization, telemetry, CI/device proof, long-term habit, release-facing systems. | RU/localization, broader telemetry implementation, visual/device QA, novice QA, architecture/maintainability, store/release gaps | Visible W1-W12 demo-quality push or top packet blocker; Telemetry Local Sink v3 only if admitted; Architecture / Maintainability audit v1 |
| Commercial / Release Readiness | 43.8 / 100 | Medium-Low | Includes monetization, value packaging, store assets, legal/support, release operations. It is downstream from route quality. | no full store package, no release ops packet, minimal commercial framing, no production analytics loop | Store / Legal / Release Ops audit; Technical CI / release proof; Monetization / Commercial framing audit |

## Department / Block Ledger

| Block | Units | Status | Current proof / evidence | Missing to 100 | Top bottleneck | Next bounded wave | Risk if ignored | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Act0 EN Core Route Proof | 8.5 / 14 | ACTIVE | Fast loop clean; core route guarded; route mechanics strong; controlled-demo packet is now green for the full compact internal walkthrough | novice proof and broader route-human validation | visible demo-quality threshold before rare novice time | Visible W1-W12 demo-quality push | route may look stronger internally than it feels to new users | Medium |
| Home / Daily Command Center | 9 / 10 | CLOSED-WATCH | command-center composition landed and proof-backed | novice validation and device polish | avoid reopening stable composition | closed-watch only | churn risk and hierarchy regression | High |
| Learn / Route Clarity | 9 / 10 | ACTIVE | selected-panel path aligned; level-1 bridge and seat decode proofs aligned; compact header hierarchy improved; duplicate `Lesson N` chrome is now suppressed in the observed `440`-width state | novice clarity and broader route feel | human validation | Learn presentation rebuild only if local hierarchy work stalls | route can still feel internally coherent but externally dense | Medium |
| Runner / Table / Feedback Truth | 8.5 / 12 | ACTIVE | runner proof clusters realigned; board/street truth closed; compact corrective feedback is calmer and less punitive in the demo packet | more device proof and premium polish | real-device table proof | Visual Cross-Screen / Device QA audit | hidden runtime trust regressions on real devices | Medium |
| Review / Retention / Prove | 9.5 / 12 | ACTIVE | deterministic repair / recheck / prove loops and proofs are green; compact empty-state hierarchy improved; active repair now leads above secondary support chrome | deeper pattern coaching and long-term proof | high-volume coach-feel proof | Review / Pattern Coaching Audit v1 | repair loop may remain mechanically correct but emotionally flat | Medium |
| Practice / Daily Reps | 6.5 / 9 | ACTIVE | featured recommendation, payoff framing, duplicate disabled repair cleanup, and daily return-value line landed | more visible return value and broader practice trust | repeated-session value proof | Practice payoff follow-through audit | Practice may still feel secondary over time | Medium |
| Content Depth / Transfer | 11.5 / 16 | ACTIVE | W1/W4/W5/W6/W8 lifts remain landed; W9 bubble-risk owner transfer and W11 session-plan owner transfer are now added; W10 exploit guardrails was correctly no-op audited; answer labels cleaned; Hand Strength W1 owner seam is now substantially stronger across comparison, best-five, kicker, and high-rank transfer proof | more transfer families and mastery-linked depth, especially board-reading/draws and pot/stack/all-in/side-pot truth | foundation depth illusion beyond the repaired hand-strength seam | Board reading / draws depth wave, or Pot / Stack / All-in / Side-pot truth slice | route can feel polished but too thin at full-ladder scale | Medium |
| First-Run / Foundation | 9.5 / 11 | ACTIVE | guide-first route, placement simplification, seat decode proof, first-start path strong | real novice confirmation after key foundation-depth illusions are reduced | novice evidence still risks measuring known thin concept families | Human Novice QA proof packet after board-reading/draws and pot/stack depth improve | first-session friction may remain hidden | Medium |
| World Completion / Mastery Payoff | 6.5 / 9 | ACTIVE | world completion now shows stronger milestone wording, skill-in-motion, return-value, next-unlock reason, a distinct milestone panel, and a lighter top stack after the safe compact fold | stronger human-validated payoff and broader mastery depth | payoff still needs novice validation | Human Novice QA proof packet after controlled-demo gate | route completion may still feel lighter than the learning effort it summarizes | Medium |
| Profile / You Payoff | 5.5 / 10 | ACTIVE | recent progress card now shows improved, stronger-skill, fixed, return-value evidence; hero identity and lower return-value story are stronger without dashboard bloat | deeper learner identity, novice validation, broader cross-session narrative | payoff is stronger but still compact | Profile payoff follow-through only with fresh evidence | improvement can still feel smaller than the work the learner is doing | Medium |
| Visual Premium / Cross-Screen | 8.5 / 12 | ACTIVE | compact proof packet landed and later-loop closure is green; Learn, Runner feedback, Review, Practice, Profile, and World Completion local hierarchy passes are recorded | premium consistency, device-class polish, store-grade screenshot proof | final store-grade visual proof | device proof follow-up with fresh evidence; Deep Ocean Gold audit/spec v1 only if admitted | app can still read as competent utility rather than premium product | Medium |
| Deep Ocean Gold / Brand Theme | 2 / 8 | FUTURE EV | theme direction exists conceptually, not as a finalized premium system | final brand-token system and confident premium finish | too early to lock final token migration | Deep Ocean Gold audit/spec v1 | visual identity can stay generic too long | Low-Medium |
| RU / Localization | 4 / 12 | DEFERRED | bounded RU proof triage landed; translation SSOT is now explicit in `docs/l10n/TRANSLATION_SSOT_v1.md` and archived handoff noise is separated from active owners | broad learner-facing RU completeness and premium-human copy | broad RU wave not yet admitted | Full RU localization wave v1 | supported-locale trust stays partial | Medium |
| Telemetry / Learning Events | 2.5 / 8 | DEFERRED | `docs/plan/ACT0_TELEMETRY_TRUTH_MAP_v1.md` defines W1-W12 event names, owner seams, payload rules, forbidden fields, privacy boundaries, and proof strategy; the local Act0 sink now proves `task_shown`, `task_result`, `repair_completed`, and `practice_completed` with privacy guards | broader runtime instrumentation, dashboards/reports, release privacy posture | start-of-loop coverage and broader release posture | Telemetry Local Sink v3 only if explicitly admitted | product improvement loops stay limited until more events are emitted and validated | High |
| Technical Proof / CI | 11 / 12 | ACTIVE | `flutter analyze` clean; fast loop clean; release gate made dirty-tree safer; controlled-demo browser capture is usable and later-loop packet closure now restores manifest plus all required surfaces | release-grade CI/reporting clarity and cleaner worktree discipline | release package proof | Release Gate Hygiene follow-up only with fresh evidence | confidence can slip again as more waves land | High |
| Human Novice QA | 2 / 10 | BLOCKED | internal reasoning only; no durable novice proof packet | real first-user evidence | missing novice walkthrough | Human Novice QA proof packet | wrong assumptions can survive deep into release work | High |
| Monetization / Commercial | 2 / 10 | DEFERRED | value-first constraints are documented | real package, pricing, entitlement trust, commercial proposition | downstream from product proof | Monetization / Commercial framing audit | release story stays undefined | Medium |
| Store / Legal / Release Ops | 2 / 10 | DEFERRED | release-readiness reference exists only at policy level | real assets, metadata, legal/support, submission checklist | no release package audit | Store / Legal / Release Ops audit | external launch work will be underdefined and rushed | Medium |
| Long-Term Progression / Habit | 3 / 10 | FUTURE EV | soft daily checklist and weekly focus exist | long-horizon habit, resurfacing, anti-binge framing, month-scale proof | current focus stays daily-first by design | Long-Term Progression / Habit system audit v1 | retention strategy stays short-horizon | Medium |
| Architecture / Maintainability | 4 / 10 | ACTIVE | active seams are known; routing docs are clearer | very large owner files, dirty tree habits, maintainability debt | product velocity outran cleanup | Architecture / Maintainability audit v1 | future waves get slower and riskier | Medium |

## Block DoD Breakdown

This section makes block units harder to move casually.

Use these rules when proposing or reporting unit movement:

- remaining units are readiness gaps, not exact task tickets
- do not score tiny implementation details such as one padding change as a unit
- each unit movement must name the reduced risk class and delta type
- `Done`, `Partial`, and `Missing` criteria describe evidence quality, not a
  command to work every low block immediately
- `Calibration Pending` means the current unit score is directionally useful
  but needs stronger evidence before future movement

Delta criteria types:

- `Product Quality`: learner-facing usefulness, clarity, payoff, motivation, or
  compact-device experience improved
- `Proof Confidence`: tests, guards, reproducible commands, screenshots, or
  device evidence reduce uncertainty
- `Release Readiness`: store, legal, packaging, rollback, support, or release
  artifact risk decreases
- `Documentation / SSOT Clarity`: ownership and future execution become safer,
  without claiming product quality by default

### Aggregate Layers

#### Act0 Route Mechanics

- Units: frozen `93 / 100`
- DoD criteria: EN Act0 route order is stable; route entry is canonical; core
  loop starts, teaches, runs, reviews, and returns; fast-loop proof is green;
  ownership seams are documented.
- Done: active route mechanics are strong and proof-backed.
- Partial: human novice validation, broader device proof, and final release
  posture are outside this score.
- Missing: a broad route milestone that changes the real route floor, not a
  local proof/copy/presentation improvement.
- Next unit movement rule: do not move above `93` unless a broad route
  milestone lands and is proven by route-level tests plus fast loop.
- Rebuild / reopen trigger: only fresh evidence that the active route shape is
  wrong or scale-readiness cannot be reached through local owner seams.
- Likely next bounded waves: none by default; work the lower blocks instead.

#### W1-W12 Scale-Ready Readiness

- Units: currently derived from the block set in `Current Aggregate Calibration`;
  aggregate recalculation is conservative and not raised by docs-only waves.
- DoD criteria: W1-W12 can act as a reusable world factory; route clarity,
  feedback, review, practice, content depth, first-run, completion, profile, and
  proof floors are all strong enough to scale.
- Done: fast-loop floor is green; several compact hierarchy/product-payoff
  seams have landed; W1-W12 has a clear active boundary.
- Partial: local surfaces are improving, but novice validation, premium visual
  consistency, long-term learning loop proof, and broader content architecture
  remain incomplete.
- Missing: reusable production pattern for future worlds, real novice evidence,
  runtime telemetry validation, and stronger full-ladder proof.
- Next unit movement rule: move only when one of the contributing blocks moves
  and aggregate recalculation is explicitly reported.
- Rebuild / reopen trigger: if repeated local waves leave the same factory
  blocker unresolved, propose a bounded rebuild through the High-EV Gate.
- Likely next bounded waves: Telemetry Local Sink Spike v1 only if admitted;
  Review pattern-coach audit if fresh evidence appears; controlled-demo packet
  only after current gates justify it.

### Major Blocks

#### Act0 EN Core Route Proof

- Units: `8.5 / 14`
- DoD criteria: route order is guarded; route state is deterministic; core EN
  screens and route handoffs are covered by focused tests; fast loop stays green.
- Done: core route guards and fast loop are clean.
- Partial: proof is still mostly internal and synthetic.
- Missing: novice route validation, broader device-path proof, and release-like
  route entry proof.
- Next unit movement rule: `Proof Confidence Delta` only when new route-level
  evidence reduces a real confidence gap.
- Rebuild / reopen trigger: route order, ownership, or shell entry breaks in a
  way local guards cannot repair.
- Likely next bounded waves: controlled route proof packet after visual/payoff
  blockers are lower.

#### Home / Daily Command Center

- Units: `9 / 10`
- DoD criteria: daily plan is clear; next action is obvious; checklist does not
  duplicate active route ownership; compact portrait remains readable.
- Done: command-center composition and daily checklist are proof-backed.
- Partial: final device polish and novice validation remain.
- Missing: real-user confirmation that Home feels calm and useful over repeat
  sessions.
- Next unit movement rule: no movement without fresh Home-specific blocker or
  novice/device evidence.
- Rebuild / reopen trigger: only fresh evidence that Home blocks route
  comprehension or daily return.
- Likely next bounded waves: closed-watch only.

#### Learn / Route Clarity

- Units: `9 / 10`
- DoD criteria: learner sees current route, selected lesson, primary CTA, locked
  reasons, and lesson ownership without dense utility chrome.
- Done: selected panel, level bridge, seat decode, and compact header hierarchy
  are proof-backed.
- Partial: compact world-feel and novice clarity are still inferred.
- Missing: human validation that Learn feels like a premium path, not just a
  route utility.
- Next unit movement rule: `Product Quality Delta` only for material clarity or
  compact-density reduction, not minor copy polish.
- Rebuild / reopen trigger: if local hierarchy work still leaves Learn feeling
  structurally utility-like.
- Likely next bounded waves: Learn rebuild only if the High-EV Gate is triggered.

#### Runner / Table / Feedback Truth

- Units: `8.5 / 12`
- DoD criteria: table state is truthful; prompts do not leak answers; feedback
  explains the decision; compact runner keeps table, prompt, and CTA readable.
- Done: runner proof clusters, board/street truth, and answer-label guards are
  strong.
- Partial: device-class premium feel and longer-session smoothness remain
  under-proven.
- Missing: broader real-device proof and final premium runner finish.
- Next unit movement rule: move on `Proof Confidence Delta` for stronger
  device/runtime evidence or `Product Quality Delta` for material runner clarity.
- Rebuild / reopen trigger: if table/feedback truth requires structural runner
  changes rather than local presentation repairs.
- Likely next bounded waves: runner device proof only with fresh evidence.

#### Review / Retention / Prove

- Units: `9.5 / 12`
- DoD criteria: repair, recheck, and prove ownership is clear; Review feels like
  a helpful repair coach; compact states are readable; no permanent-scar
  language leaks.
- Done: repair/recheck/prove ownership, empty-state compact hierarchy, scar
  avoidance, and fast-loop proof are green.
- Partial: active repair state density and high-volume backlog coach-feel remain
  only partly proven.
- Missing: broader coach-first proof under accumulated review pressure and
  long-term retention validation.
- Next unit movement rule: `Product Quality Delta` only when Review becomes
  materially more coach-like under real backlog/recheck/prove pressure.
- Rebuild / reopen trigger: if repair/recheck/prove still feels system-shaped
  after local hierarchy improvements.
- Likely next bounded waves: Review pattern-coach audit after fresh evidence.

#### Practice / Daily Reps

- Units: `6.5 / 9`
- DoD criteria: Practice clearly owns short reps and keep-sharp work; one best
  recommendation is dominant; locked/disabled states do not compete with CTAs.
- Done: lane routing, featured recommendation, purpose/payoff copy, and disabled
  CTA hierarchy are proof-backed.
- Partial: compact visual rhythm and repeated-session value are still only
  partly proven.
- Missing: telemetry hooks, long-term practice value proof, and final
  premium/device proof.
- Next unit movement rule: `Product Quality Delta` only when Practice clearly
  improves return value or repeated-session usefulness.
- Rebuild / reopen trigger: if Practice still reads like a catalog after local
  recommendation and disabled-state work.
- Likely next bounded waves: practice-to-identity proof after telemetry truth.

#### Content Depth / Transfer

- Units: `11.5 / 16`
- DoD criteria: W1-W12 concepts have enough true decisions, transfer variants,
  explanatory feedback, and non-punitive suboptimal branches to scale.
- Done: multiple W1-W12 content lifts and answer-label cleanup landed.
- Partial: transfer density is uneven across the full ladder.
- Missing: deeper mastery-linked transfer families and broader factory-level
  content architecture.
- Next unit movement rule: `Product Quality Delta` only for material transfer
  depth or mastery coverage, not isolated copy expansion.
- Rebuild / reopen trigger: if current world-pack architecture cannot scale
  transfer density cleanly.
- Likely next bounded waves: content depth / transfer-density lift v2.

#### First-Run / Foundation

- Units: `9.5 / 11`
- DoD criteria: first-start path is short, beginner-safe, table-adjacent, and
  hands off to the first value moment without premature complexity.
- Done: guide-first route, placement simplification, first-start path, and seat
  abbreviation decoding are proof-backed.
- Partial: true novice confidence remains unproven.
- Missing: controlled novice evidence that first-run comprehension holds.
- Next unit movement rule: move only with real novice evidence or a proven
  first-run blocker repair.
- Rebuild / reopen trigger: if novices fail the first-run handoff despite green
  internal proof.
- Likely next bounded waves: visible W1-W12 demo-quality push first; human
  novice QA only after that gate is explicitly stronger.

#### World Completion / Mastery Payoff

- Units: `6.5 / 9`
- DoD criteria: completion explains what improved, what the learner can now do,
  what to keep sharp, why returning matters, and what unlocks next.
- Done: milestone wording, skill-in-motion, return-value, and next-unlock reason
  are present and tested; the completion shell now has a distinct milestone
  panel before payoff cards.
- Partial: milestone emotion is stronger internally, but not novice-validated.
- Missing: novice-validated payoff value and broader mastery depth.
- Next unit movement rule: `Product Quality Delta` only when completion feels
  materially more like an earned milestone without fake mastery.
- Rebuild / reopen trigger: if stacked payoff cards block milestone emotion.
- Likely next bounded waves: visible W1-W12 demo-quality push first, or no
  further local World Completion wave without fresh evidence.

#### Profile / You Payoff

- Units: `5.5 / 10`
- DoD criteria: Profile shows recent improvement, skill identity, fixed leaks,
  keep-sharp value, and next-session reason without becoming a dashboard.
- Done: improved/stronger/fixed/return-value evidence and compact top hierarchy
  are present.
- Partial: learner identity still competes with stacked sections.
- Missing: deeper cross-session identity, broader payoff proof, and novice
  validation.
- Next unit movement rule: `Product Quality Delta` only when Profile evidence
  becomes materially clearer or more motivating.
- Rebuild / reopen trigger: if the card-stack model blocks learner identity.
- Likely next bounded waves: Profile payoff follow-through only after fresh
  evidence.

#### Visual Premium / Cross-Screen

- Units: `8.5 / 12`
- DoD criteria: compact portrait hierarchy is readable across key screens;
  screens feel coherent and premium; screenshot/device proof is reproducible.
- Done: compact proof packet plus Learn/Runner feedback/Review/Practice/Profile/World
  Completion local hierarchy improvements are landed.
- Partial: premium consistency and device-class polish remain uneven.
- Missing: Deep Ocean v1.1 integration, broader real-device proof, and final
  store-grade screenshots.
- Next unit movement rule: `Product Quality Delta` for UI changes that materially
  improve compact presentation; `Proof Confidence Delta` for stronger device
  evidence only.
- Rebuild / reopen trigger: if local hierarchy waves no longer reduce the same
  utility/card-stack feel.
- Likely next bounded waves: device proof follow-up only with fresh evidence.

#### Deep Ocean Gold / Brand Theme

- Units: `2 / 8`
- DoD criteria: brand palette, tokens, contrast, typography, elevation, and
  milestone treatment are final enough to apply cross-screen.
- Done: direction exists conceptually.
- Partial: token migration has not been proven readable or product-positive.
- Missing: v1.1 theme spec, contrast proof, device proof, and implementation.
- Next unit movement rule: no movement without explicit Deep Ocean admission and
  proof that theme work improves readability/product feel.
- Rebuild / reopen trigger: proven visual ceiling from current tokens.
- Likely next bounded waves: Deep Ocean Gold audit/spec v1, later.

#### RU / Localization

- Units: `4 / 12`
- DoD criteria: runtime copy uses active owners; archived files are ignored;
  learner-facing RU is complete enough to trust; broad RU wave follows
  `TRANSLATION_SSOT_v1`.
- Done: translation SSOT is explicit and archived handoff noise is separated.
- Partial: bounded RU proof exists, but coverage is incomplete.
- Missing: broad learner-facing RU completeness and premium-human copy review.
- Next unit movement rule: `Documentation / SSOT Clarity Delta` only for owner
  clarity, or `Product Quality Delta` for admitted runtime RU completion.
- Rebuild / reopen trigger: if stable-id flow cannot support broad RU safely.
- Likely next bounded waves: full RU localization wave only when admitted.

#### Telemetry / Learning Events

- Units: `2.5 / 8`
- DoD criteria: learning events have a truth map, event names, payload rules,
  privacy boundaries, implementation, and validation.
- Done: telemetry is recognized as a major missing block.
- Partial: `docs/plan/ACT0_TELEMETRY_TRUTH_MAP_v1.md` defines the W1-W12 event
  contract, owner seams, payload principles, forbidden fields, privacy
  constraints, and validation strategy; the local sink now proves
  `task_shown`, `task_result`, `repair_completed`, and `practice_completed`
  without network export.
- Missing: broader runtime instrumentation, dashboards/reports, release privacy
  posture, and any external export decision.
- Next unit movement rule: additional implementation units only after admitted
  wiring proves more owner seams or release-safe privacy/export posture.
- Rebuild / reopen trigger: if the learning loop cannot be validated without a
  telemetry spine.
- Likely next bounded waves: no broad telemetry by default; expand only with a
  separately admitted event seam such as `repair_started` and
  `practice_started`.

#### Technical Proof / CI

- Units: `11 / 12`
- DoD criteria: analyze, fast loop, release gate, diff hygiene, and selected
  proof floors are reproducible and scoped to active route truth.
- Done: `flutter analyze`, fast loop, dirty-tree-safer release gate, focused
  proof clusters, and the repaired controlled-demo packet path are strong.
- Partial: whole-product release proof and broader CI/reporting clarity remain
  weaker than route proof.
- Missing: public-release package proof and broader CI/reporting clarity.
- Next unit movement rule: `Proof Confidence Delta` only when a real proof-floor
  or release-gate risk decreases.
- Rebuild / reopen trigger: if scoped gates no longer represent active release
  truth.
- Likely next bounded waves: release proof follow-up only with fresh blocker.

#### Human Novice QA

- Units: `2 / 10`
- DoD criteria: controlled novice test packet exists; task script is stable;
  observations are recorded; findings map back to owner blocks.
- Done: internal assumptions and deferred policy are documented.
- Partial: no durable novice proof packet exists.
- Missing: actual controlled novice evidence.
- Next unit movement rule: move only after admitted novice QA produces durable
  evidence, not because internal proof improves.
- Rebuild / reopen trigger: the visible W1-W12 demo-quality gate is strong
  enough that known visible issues will not dominate rare novice feedback.
- Likely next bounded waves: still deferred by execution policy.

#### Store / Legal / Release Ops

- Units: `2 / 10`
- DoD criteria: store metadata, legal/support surfaces, screenshot package,
  release checklist, rollback, privacy labels, and artifact verification exist.
- Done: release docs and audit inventory exist.
- Partial: package truth is incomplete and several artifacts are missing.
- Missing: submission-ready metadata, legal review, support/about surface,
  screenshots, rollback proof, and release-owner packet.
- Next unit movement rule: `Release Readiness Delta` only when verifiable
  artifacts improve, not from an audit alone.
- Rebuild / reopen trigger: public beta or external release posture is admitted.
- Likely next bounded waves: Submission Metadata / Public Support Surface Audit
  v1.

#### Monetization / Commercial

- Units: `2 / 10`
- DoD criteria: product value proposition, entitlement model, pricing, paywall
  rules, store alignment, and non-pressure learner framing are ready.
- Done: value-first constraints are documented.
- Partial: no implementation or approved commercial package exists.
- Missing: package, pricing, entitlements, paywall UX, and release validation.
- Next unit movement rule: `Release Readiness Delta` only for admitted commercial
  package/proof work.
- Rebuild / reopen trigger: product proof is strong enough that commercial
  framing will not distort the learning experience.
- Likely next bounded waves: Monetization / Commercial framing audit, later.

#### Long-Term Progression / Habit

- Units: `3 / 10`
- DoD criteria: daily/weekly/monthly rhythm is useful, non-punitive, and backed
  by retention evidence.
- Done: soft daily checklist and lightweight weekly focus exist.
- Partial: long-horizon progression remains intentionally light.
- Missing: month-scale proof, habit telemetry, anti-binge policy, and sustained
  return loop.
- Next unit movement rule: move only with admitted long-horizon evidence or a
  designed habit model.
- Rebuild / reopen trigger: daily-first loop cannot sustain return value.
- Likely next bounded waves: long-term progression audit after telemetry truth.

#### Architecture / Maintainability

- Units: `4 / 10`
- DoD criteria: owner seams are clear; active route files remain maintainable;
  dormant systems do not block active proof; docs reduce future drift.
- Done: active seams and routing docs are clearer.
- Partial: large owner files and dirty-tree habits still slow work.
- Missing: targeted maintainability audit, active/dormant boundary cleanup, and
  safer long-term module shape.
- Next unit movement rule: `Proof Confidence Delta` or `Documentation / SSOT
  Clarity Delta` only when future change risk materially decreases.
- Rebuild / reopen trigger: active-route work becomes unsafe or slow because of
  file size/coupling.
- Likely next bounded waves: Architecture / Maintainability audit v1.

#### W13-W24 / Broader World Expansion

- Units: `Calibration Pending`
- DoD criteria: W1-W12 factory is scale-ready; content architecture is stable;
  route, localization, visual, telemetry, and proof patterns are reusable.
- Done: long-horizon vision exists in planning references.
- Partial: broader expansion is intentionally not active.
- Missing: W1-W12 scale-ready gates and reusable world factory proof.
- Next unit movement rule: no movement until W1-W12 scale-ready gates are met.
- Rebuild / reopen trigger: only if W1-W12 readiness proves the factory is ready
  or a strategic plan explicitly admits broader expansion.
- Likely next bounded waves: none before W1-W12 scale-ready readiness improves.

## Screen Ledger

| Screen / surface | Functional readiness | Learning readiness | Visual readiness | Copy / localization readiness | Proof / test readiness | Major missing work | Status |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| Placement | 8.5 / 10 | 8 / 10 | 7 / 10 | 7 / 10 | 8.5 / 10 | novice proof and final device sweep | ACTIVE |
| Welcome | 8 / 10 | 7.5 / 10 | 7 / 10 | 7 / 10 | 8 / 10 | preserve 2-beat minimal bridge, validate on novices | CLOSED-WATCH |
| Home | 9 / 10 | 8.5 / 10 | 7.5 / 10 | 8 / 10 | 9 / 10 | device polish and novice confidence only | CLOSED-WATCH |
| First Table Guide | 8.5 / 10 | 8.5 / 10 | 7 / 10 | 8 / 10 | 9 / 10 | novice validation of guide-first handoff | ACTIVE |
| Learn | 8.5 / 10 | 8.5 / 10 | 7 / 10 | 6.5 / 10 | 8.5 / 10 | world-feel, RU completeness, novice clarity | ACTIVE |
| Runner / Table | 9 / 10 | 8.5 / 10 | 7.5 / 10 | 7 / 10 | 9 / 10 | device-class proof and premium finish | ACTIVE |
| Practice | 8 / 10 | 7.5 / 10 | 7 / 10 | 7 / 10 | 8.5 / 10 | stronger return habit and identity linkage | ACTIVE |
| Review | 8.5 / 10 | 8.5 / 10 | 7 / 10 | 7 / 10 | 9 / 10 | deeper coaching depth and human-proofed usefulness | ACTIVE |
| World Completion | 7.5 / 10 | 7.5 / 10 | 7 / 10 | 7 / 10 | 8 / 10 | stronger mastery payoff and next-step emotion | ACTIVE |
| Profile / You | 7 / 10 | 7 / 10 | 6.5 / 10 | 7 / 10 | 8 / 10 | clearer progress identity and return value | ACTIVE |
| Bottom Nav / Shell | 9 / 10 | 8 / 10 | 7.5 / 10 | 7 / 10 | 9 / 10 | real-device shell polish | CLOSED-WATCH |
| Legal / Settings | 3 / 10 | n/a | 3 / 10 | 3 / 10 | 2 / 10 | real support/legal/settings audit | DEFERRED |
| Paywall / Monetization | 2 / 10 | 2 / 10 | 2 / 10 | 2 / 10 | 1 / 10 | value package, entitlement truth, store-ready framing | DEFERRED |

## Closed-Watch / Deferred Registry

### Closed-watch

| Item | Why closed-watch | When to reopen | Risk if reopened too early | Affected block |
| --- | --- | --- | --- | --- |
| Home composition / daily checklist | command-center contract is already coherent and proof-backed | only with fresh runtime, screenshot, or novice evidence | churn, hierarchy regressions, duplicated active route | Home / Daily Command Center |
| Fresh route-first Home | fresh-state contract is stable | only if first-start evidence shows confusion | breaks first-use clarity for marginal gain | Home / Daily Command Center |
| Activated compact route strip | activated route strip replaced the larger hero safely | only if route re-entry evidence fails | reintroduces duplicate CTA competition | Home / Daily Command Center |
| Soft daily training contract | daily mix is intentionally lightweight and non-punitive | only after long-horizon pacing proof exists | adds obligation UX before habit proof | Long-Term Progression / Habit |
| Weekly focus lightweight context | advisory-only context is sufficient today | only if daily checklist proof shows it is invisible or confusing | creates a second obligation surface | Long-Term Progression / Habit |
| Review/Nav proof cluster | cluster has already been realigned | only with fresh failing evidence | burns time on stale proof noise | Technical Proof / CI |
| Runner surface proof cluster | cluster has already been realigned | only with fresh failing evidence | reopens already-closed surface contracts | Runner / Table / Feedback Truth |
| Fast-loop residue split: closed with FAST LOOP PASS | exact residue families were split and closed one by one | only if fast loop goes red again | broad cleanup drift instead of evidence-based repair | Technical Proof / CI |

### Deferred / future

| Item | Why deferred | When to reopen | Risk if reopened too early | Affected block |
| --- | --- | --- | --- | --- |
| full RU localization wave | EN route and proof work were higher EV first | once EN route is stable and the team admits the broad wave | expensive token burn and mixed-owner churn | RU / Localization |
| telemetry implementation | event truth map exists, but no runtime sink or release privacy posture exists yet | after local sink and privacy posture are admitted | instrumenting the wrong model or exporting before privacy posture is ready | Telemetry / Learning Events |
| monetization/paywall | value proof is still downstream | after product and novice proof are stronger | pressure before value and fake commercial certainty | Monetization / Commercial |
| store/legal/release package | not needed for current bounded route work | after product/core proof is steadier | governance drift before product is ready | Store / Legal / Release Ops |
| Deep Ocean Gold token migration / visual theme finalization | visual finish is not yet ripe for global token finalization | after device QA and visual audit | expensive theme churn before surface priorities settle | Deep Ocean Gold / Brand Theme |
| visual cross-screen device QA | needs a dedicated proof pass, not incidental edits | after the next few route/payoff gaps are clearer | screenshot churn without stable target surfaces | Visual Premium / Cross-Screen |
| human novice QA | requires a deliberate proof packet | after the visible W1-W12 demo-quality gate is strong enough: full packet green, no dominant visible blocker, compact walkthrough story holds, payoff is not obviously thin, and fast loop is green | if reopened too early, known unfinished tails dominate feedback | Human Novice QA |
| full 30-day / monthly shell | intentionally deferred to avoid obligation UX | only after daily-first proof and long-horizon data exist | product becomes heavier before it becomes clearer | Long-Term Progression / Habit |
| long-term progression / habit system | current product is still proving daily rhythm only | after novice proof and telemetry map | architecture weight before usage proof | Long-Term Progression / Habit |
| broader content architecture beyond Act0 | the active app boundary stays Act0-first | after Act0 reaches a stronger whole-product floor | roadmap sprawl and donor-system drift | Content Depth / Transfer |
| premium / value packaging | depends on product confidence and release framing | after novice proof and commercial framing audit | fake package certainty before real proof | Monetization / Commercial |

## Readiness Update Rules

Future summaries must follow these rules:

1. Update only the blocks affected by the admitted wave.
2. Default wave delta is `0`.
3. No score movement is allowed without a named reduced risk class.
4. Product-route proof waves mostly move `Technical Proof / CI`.
5. Content waves move `Content Depth / Transfer`, not full-app score by default.
6. Practice waves move `Practice / Daily Reps`, not route mechanics.
7. Profile/payoff waves move `Profile / You Payoff` and sometimes
   `World Completion / Mastery`.
8. RU waves move `RU / Localization`, not EN route mechanics.
9. Visual token/theme waves move `Visual Premium / Cross-Screen` and
   `Deep Ocean Gold / Brand Theme`, not learning-route scores.
10. Audit-only visual proof may move evidence confidence without moving visual
    quality.
11. Telemetry waves move `Telemetry / Learning Events`.
12. Monetization waves move `Monetization / Commercial`.
13. Store/legal/release waves move `Store / Legal / Release Ops`.
14. Documentation-only waves may move `Documentation / SSOT Clarity Delta`;
    they do not move product quality by default.
15. Do not increase `Act0 route mechanics` above `93` unless a genuinely broad
    route milestone lands.
16. Do not treat `full product readiness` as equal to `Act0 route mechanics`.
17. Recalculate aggregates only if one or more underlying block units changed.
18. Every future summary must report:
    - changed block units
    - unchanged block units
    - delta type
    - aggregate recalculation if relevant
    - confidence
    - reason the score did or did not move
19. Use confidence labels explicitly:
    - `High`
    - `Medium`
    - `Medium-Low`
    - `Low`
20. When a block is deferred, say why it is deferred and what would justify
    reopening it.

## Current Recommended Roadmap

This is the current 10-wave bounded roadmap after the fast-loop floor turned
green. It is a routing aid, not an implementation order guarantee.

| Candidate wave | Affected block | Expected unit delta | Why now / why later | Risks | Dependencies |
| --- | --- | --- | --- | --- | --- |
| Visible W1-W12 demo-quality push | Act0 EN Core Route Proof, Learn / Route Clarity, Review / Retention / Prove, Practice / Daily Reps, Profile / You Payoff, World Completion / Mastery Payoff, Visual Premium / Cross-Screen | +0 to +2 | higher EV than spending rare novice time while known visible issues still exist; use the full controlled-demo packet to identify one top blocker only | can drift into polish churn if no single blocker dominates | stable controlled-demo route and packet |
| Telemetry Local Sink v3 | Telemetry / Learning Events | +0.5 | truth map and local completion proof now exist; next value is start-of-loop proof for `repair_started` and `practice_started` | over-wiring before privacy and release posture are ready | `docs/plan/ACT0_TELEMETRY_TRUTH_MAP_v1.md` |
| Practice/Profile payoff follow-through audit | Practice / Daily Reps, Profile / You Payoff | +0.5 to +1 | worthwhile only after observing whether the current compact payoff layer holds up under internal demo or novice feedback | can drift into copy churn without new evidence | current compact packet plus novice feedback once admitted |
| Visual Cross-Screen / Device QA follow-up | Visual Premium / Cross-Screen | +0.5 to +1 | later, only with fresh device evidence after recent local hierarchy passes | can create screenshot-polish churn if run too early | fast-loop clean baseline |
| Technical CI / release proof v1 | Technical Proof / CI | +1 | fast-loop is clean; next technical step is release confidence | may expose messy non-route infra debt | current proof floor |
| RU localization big wave v1 | RU / Localization | +2 to +3 | valuable, but only after EN route and payoff are steadier | high token cost and wide copy-surface churn | admitted broad RU scope |
| Deep Ocean Gold audit/spec v1 | Deep Ocean Gold / Brand Theme | +1 | good to spec before a future migration, not before device proof | tokenization before visual priorities settle | visual audit context |
| Store / Legal / Release Ops audit | Store / Legal / Release Ops | +1 to +2 | needed before any external launch posture | governance drift if done too early | stronger product proof |
| Monetization / Commercial framing audit | Monetization / Commercial | +1 to +2 | downstream from product/value proof | can distort product decisions if admitted too early | novice proof and package clarity |
| Architecture / Maintainability audit v1 | Architecture / Maintainability | +0.5 to +1 | useful after several product waves because active owner files are large and dirty-tree discipline matters | can become cleanup churn if not tied to active-route velocity | current active seam map |

## Current Summary Rule

When someone asks, `How close is the whole product to 100?`, do not answer
with the Act0 route score alone.

Use this order:

1. `Act0 route mechanics`
2. `EN learning experience`
3. `full product readiness`
4. `commercial / release readiness`
5. relevant block deltas
6. confidence

## Bottom Line

Current repo truth after the fast-loop cleanup:

- the active EN Act0 route is strong
- the proof floor is materially better than it was
- the whole product is still not near whole-product `93 / 100`
- the largest remaining truth gaps are novice proof, payoff depth, visual/device
  proof, telemetry truth, RU completeness, and release/commercial systems
