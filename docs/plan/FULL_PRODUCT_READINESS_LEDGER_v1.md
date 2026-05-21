# FULL_PRODUCT_READINESS_LEDGER_v1

Status: ACTIVE
Purpose: canonical full-product readiness ledger so strong Act0 route mechanics
are not mistaken for whole-product readiness.
Last updated: 2026-05-21

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
- full product readiness is still materially lower, roughly the high `70s`
- commercial / release readiness is much lower than the active EN route

This file prevents false summaries such as:

- `Act0 route mechanics is 93 / 100, therefore the whole product is 93 / 100`

## Current Layer Model

| Layer | Current score | Confidence | Why it is not the same as the others | Main blockers | Next 3 high-EV waves |
| --- | ---: | --- | --- | --- | --- |
| Act0 Route Mechanics | 93 / 100 | High | Measures the current EN Act0 route and proof floor, not the whole app. | novice proof, device proof, deeper payoff, remaining non-route systems | Human Novice QA proof packet; World Completion / Mastery Payoff v2; Prompt/context follow-up only if fresh evidence appears |
| EN Learning Experience | 84 / 100 | Medium | Includes route + content + feedback + review + practice + payoff, not only route mechanics. | novice proof, profile payoff depth beyond the compact layer, limited long-tail transfer density | Human Novice QA proof packet; Profile / You payoff v3; Content depth / transfer-density lift v2 |
| Full Product Readiness | 80 / 100 | Medium | Includes learning plus visuals, localization, telemetry, CI/device proof, long-term habit, release-facing systems. | RU/localization, telemetry, visual/device QA, novice QA, architecture/maintainability, store/release gaps | Human Novice QA proof packet; Visual Cross-Screen / Device QA audit; Telemetry Truth Map v1 |
| Commercial / Release Readiness | 43 / 100 | Medium-Low | Includes monetization, value packaging, store assets, legal/support, release operations. It is downstream from route quality. | no full store package, no release ops packet, minimal commercial framing, no production analytics loop | Store / Legal / Release Ops audit; Monetization / Commercial framing audit; Technical CI / release proof |

## Department / Block Ledger

| Block | Units | Status | Current proof / evidence | Missing to 100 | Top bottleneck | Next bounded wave | Risk if ignored | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Act0 EN Core Route Proof | 8.5 / 14 | ACTIVE | Fast loop clean; core route guarded; route mechanics strong | novice proof and broader route-human validation | human walkthrough proof | Human Novice QA proof packet | route may look stronger internally than it feels to new users | Medium |
| Home / Daily Command Center | 9 / 10 | CLOSED-WATCH | command-center composition landed and proof-backed | novice validation and device polish | avoid reopening stable composition | closed-watch only | churn risk and hierarchy regression | High |
| Learn / Route Clarity | 8.5 / 10 | ACTIVE | selected-panel path aligned; level-1 bridge and seat decode proofs aligned | novice clarity and broader route feel | human validation | Human Novice QA proof packet | route can still feel internally coherent but externally dense | Medium |
| Runner / Table / Feedback Truth | 8.5 / 12 | ACTIVE | runner proof clusters realigned; board/street truth closed | more device proof and premium polish | real-device table proof | Visual Cross-Screen / Device QA audit | hidden runtime trust regressions on real devices | Medium |
| Review / Retention / Prove | 9 / 12 | ACTIVE | deterministic repair / recheck / prove loops and proofs are green | deeper pattern coaching and long-term proof | human usefulness validation | Review / Pattern Coaching Audit v1 | repair loop may remain mechanically correct but emotionally flat | Medium |
| Practice / Daily Reps | 6 / 9 | ACTIVE | featured recommendation and payoff framing landed | more visible return value and broader practice trust | practice-to-identity proof | Practice payoff follow-through audit | Practice may still feel secondary over time | Medium |
| Content Depth / Transfer | 11.5 / 16 | ACTIVE | W1/W4/W5/W6/W8/W9/W10 lifts landed; answer labels cleaned | more transfer families and mastery-linked depth | content density beyond current slice | Content depth / transfer-density lift v2 | route can feel polished but too thin at full-ladder scale | Medium |
| First-Run / Foundation | 9.5 / 11 | ACTIVE | guide-first route, placement simplification, seat decode proof, first-start path strong | real novice confirmation | novice evidence | Human Novice QA proof packet | first-session friction may remain hidden | Medium |
| World Completion / Mastery Payoff | 6 / 9 | ACTIVE | world completion now shows stronger milestone wording, skill-in-motion, return-value, and next-unlock reason | stronger human-validated payoff and broader mastery depth | payoff still needs novice validation | World Completion / Mastery Payoff v3 or Human Novice QA proof packet | route completion may still feel lighter than the learning effort it summarizes | Medium |
| Profile / You Payoff | 5 / 10 | ACTIVE | recent progress card now shows improved, stronger-skill, fixed, and return-value evidence without dashboard bloat | deeper learner identity, novice validation, broader cross-session narrative | payoff is stronger but still compact | Profile / You payoff v3 | improvement can still feel smaller than the work the learner is doing | Medium |
| Visual Premium / Cross-Screen | 5 / 12 | ACTIVE | compact shell is coherent; no fresh cross-screen proof sweep | screenshot/device proof and premium finish | lack of device audit | Visual Cross-Screen / Device QA audit | app can read as alpha despite strong route logic | Medium-Low |
| Deep Ocean Gold / Brand Theme | 2 / 8 | FUTURE EV | theme direction exists conceptually, not as a finalized premium system | final brand-token system and confident premium finish | too early to lock final token migration | Deep Ocean Gold audit/spec v1 | visual identity can stay generic too long | Low-Medium |
| RU / Localization | 4 / 12 | DEFERRED | bounded RU proof triage landed; translation SSOT is now explicit in `docs/l10n/TRANSLATION_SSOT_v1.md` and archived handoff noise is separated from active owners | broad learner-facing RU completeness and premium-human copy | broad RU wave not yet admitted | Full RU localization wave v1 | supported-locale trust stays partial | Medium |
| Telemetry / Learning Events | 1 / 8 | DEFERRED | almost no end-to-end event truth map | event model, instrumentation, learning-loop visibility | no admitted telemetry map yet | Telemetry Truth Map v1 | product improvement loops stay intuition-only | High |
| Technical Proof / CI | 9.5 / 12 | ACTIVE | `flutter analyze` clean; fast loop clean; focused proof clusters closed | release-gate maturity, CI/reporting clarity, cleaner worktree discipline | lack of broader release proof and dirty working reality | Technical CI / release proof v1 | confidence can slip again as more waves land | High |
| Human Novice QA | 2 / 10 | BLOCKED | internal reasoning only; no durable novice proof packet | real first-user evidence | missing novice walkthrough | Human Novice QA proof packet | wrong assumptions can survive deep into release work | High |
| Monetization / Commercial | 2 / 10 | DEFERRED | value-first constraints are documented | real package, pricing, entitlement trust, commercial proposition | downstream from product proof | Monetization / Commercial framing audit | release story stays undefined | Medium |
| Store / Legal / Release Ops | 2 / 10 | DEFERRED | release-readiness reference exists only at policy level | real assets, metadata, legal/support, submission checklist | no release package audit | Store / Legal / Release Ops audit | external launch work will be underdefined and rushed | Medium |
| Long-Term Progression / Habit | 3 / 10 | FUTURE EV | soft daily checklist and weekly focus exist | long-horizon habit, resurfacing, anti-binge framing, month-scale proof | current focus stays daily-first by design | Long-Term Progression / Habit system audit v1 | retention strategy stays short-horizon | Medium |
| Architecture / Maintainability | 4 / 10 | ACTIVE | active seams are known; routing docs are clearer | very large owner files, dirty tree habits, maintainability debt | product velocity outran cleanup | Architecture / Maintainability audit v1 | future waves get slower and riskier | Medium |

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
| telemetry implementation | no event truth map exists yet | after the truth map is designed | instrumenting the wrong model | Telemetry / Learning Events |
| monetization/paywall | value proof is still downstream | after product and novice proof are stronger | pressure before value and fake commercial certainty | Monetization / Commercial |
| store/legal/release package | not needed for current bounded route work | after product/core proof is steadier | governance drift before product is ready | Store / Legal / Release Ops |
| Deep Ocean Gold token migration / visual theme finalization | visual finish is not yet ripe for global token finalization | after device QA and visual audit | expensive theme churn before surface priorities settle | Deep Ocean Gold / Brand Theme |
| visual cross-screen device QA | needs a dedicated proof pass, not incidental edits | after the next few route/payoff gaps are clearer | screenshot churn without stable target surfaces | Visual Premium / Cross-Screen |
| human novice QA | requires a deliberate proof packet | now, as a bounded audit wave | if skipped too long, route confidence becomes self-referential | Human Novice QA |
| full 30-day / monthly shell | intentionally deferred to avoid obligation UX | only after daily-first proof and long-horizon data exist | product becomes heavier before it becomes clearer | Long-Term Progression / Habit |
| long-term progression / habit system | current product is still proving daily rhythm only | after novice proof and telemetry map | architecture weight before usage proof | Long-Term Progression / Habit |
| broader content architecture beyond Act0 | the active app boundary stays Act0-first | after Act0 reaches a stronger whole-product floor | roadmap sprawl and donor-system drift | Content Depth / Transfer |
| premium / value packaging | depends on product confidence and release framing | after novice proof and commercial framing audit | fake package certainty before real proof | Monetization / Commercial |

## Readiness Update Rules

Future summaries must follow these rules:

1. Update only the blocks affected by the admitted wave.
2. Product-route proof waves mostly move `Technical Proof / CI`.
3. Content waves move `Content Depth / Transfer`, not full-app score by default.
4. Practice waves move `Practice / Daily Reps`, not route mechanics.
5. Profile/payoff waves move `Profile / You Payoff` and sometimes
   `World Completion / Mastery`.
6. RU waves move `RU / Localization`, not EN route mechanics.
7. Visual token/theme waves move `Visual Premium / Cross-Screen` and
   `Deep Ocean Gold / Brand Theme`, not learning-route scores.
8. Telemetry waves move `Telemetry / Learning Events`.
9. Monetization waves move `Monetization / Commercial`.
10. Store/legal/release waves move `Store / Legal / Release Ops`.
11. Do not increase `Act0 route mechanics` above `93` unless a genuinely broad
    route milestone lands.
12. Do not treat `full product readiness` as equal to `Act0 route mechanics`.
13. Every future summary must report:
    - percentage delta
    - unit-based block delta
    - changed blocks
    - unchanged blocks
    - confidence
14. Use confidence labels explicitly:
    - `High`
    - `Medium`
    - `Medium-Low`
    - `Low`
15. When a block is deferred, say why it is deferred and what would justify
    reopening it.

## Current Recommended Roadmap

This is the current 10-wave bounded roadmap after the fast-loop floor turned
green. It is a routing aid, not an implementation order guarantee.

| Candidate wave | Affected block | Expected unit delta | Why now / why later | Risks | Dependencies |
| --- | --- | --- | --- | --- | --- |
| World Completion / Mastery Payoff v2 | World Completion / Mastery | +1 to +2 | high EV because route finish payoff is still thin | can become decorative if not tied to real evidence | current completion truth |
| Human Novice QA proof packet | Human Novice QA, First-Run / Foundation, Learn Route Clarity | +2 to +4 | highest truth gap after fast-loop cleanup | external evidence may force uncomfortable reprioritization | stable current route |
| Profile / You payoff v3 | Profile / You Payoff | +0.5 to +1.5 | worthwhile only after observing whether the v2 compact layer is enough in practice | can drift into dashboard bloat or duplicate Home | current recent-progress truth plus novice feedback |
| Telemetry Truth Map v1 | Telemetry / Learning Events | +1 | necessary before instrumentation | overdesign risk if it tries to implement events too soon | none |
| Visual Cross-Screen / Device QA audit | Visual Premium / Cross-Screen | +1 to +2 | strongest premium-feel gap with low architecture risk | can create screenshot-polish churn if run too early | fast-loop clean baseline |
| Technical CI / release proof v1 | Technical Proof / CI | +1 | fast-loop is clean; next technical step is release confidence | may expose messy non-route infra debt | current proof floor |
| RU localization big wave v1 | RU / Localization | +2 to +3 | valuable, but only after EN route and payoff are steadier | high token cost and wide copy-surface churn | admitted broad RU scope |
| Deep Ocean Gold audit/spec v1 | Deep Ocean Gold / Brand Theme | +1 | good to spec before a future migration, not before device proof | tokenization before visual priorities settle | visual audit context |
| Store / Legal / Release Ops audit | Store / Legal / Release Ops | +1 to +2 | needed before any external launch posture | governance drift if done too early | stronger product proof |
| Monetization / Commercial framing audit | Monetization / Commercial | +1 to +2 | downstream from product/value proof | can distort product decisions if admitted too early | novice proof and package clarity |

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
