# ACT0_PRODUCT_100_EXECUTION_ROUTE_v1

Status: ACTIVE
Purpose: one practical execution file for driving the current Act0 product
route from today's mixed product/proof state toward practical `100 / 100`
with the highest-EV order, clear bottlenecks, and low token waste.
Last updated: 2026-05-14

## Authority

Use this file beneath:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/ACT0_EXECUTION_SNAPSHOT_2026_05_14_v1.md`
- `docs/plan/MINI_ROUTE_TO_100_WAVES_v1.md`
- `docs/plan/PRODUCT_100_PROOF_AUDIT_v1.md`
- `docs/plan/NOVICE_WALKTHROUGH_EVIDENCE_v1.md`
- `docs/plan/MONETIZATION_RETENTION_MODEL_RECOMMENDATION_v1.md`

This file does not replace the master plan.

Use this file for:

- one current view of the real route to practical product `100 / 100`
- current block scores and honest residue
- bottleneck-first task order
- the next execution waves after the major 6-wave product route

Do not use this file for:

- launch/store readiness scoring as the primary truth
- reopening broad old readiness ladders
- forcing architecture cleanup ahead of higher-EV product blockers

## Inputs Used

This route merges four truth sources:

1. active product route from `MASTER_PLAN_v3.0.md`
2. post-route proof framing from `PRODUCT_100_PROOF_AUDIT_v1.md`
3. code/test-first scoring from `INDEPENDENT_ACT0_AUDIT_LOG_v1.md`
4. external stress-test observations from `/Users/elmarsalimzade/Desktop/audit.md`

Rule:

- external audits are useful as stress tests
- they do not override live repo truth when current commands disagree

## Current Live Calibration

Live verification on 2026-05-14:

- `flutter analyze` -> clean
- preview integration suite -> `+281 -0`
- feedback audit:
  - titles: `500`
  - reasons: `501`
  - empty titles: `0`
  - empty reasons: `0`
  - empty synthetic pairs: `0`
  - top-2 feedback title share: `8.0%` (`40 / 500`)
  - banned generic fallbacks present in state: `0`
  - short reason candidates: `0`
- major Act0 owner LOC:
  - `act0_shell_state_v1.dart`: `15183`
  - `act0_shell_preview_screen_v1.dart`: `6462`
  - `act0_lesson_runner_shell_v1.dart`: `5936`
  - `act0_learn_path_shell_v1.dart`: `3051`
  - `act0_profile_shell_v1.dart`: `1640`

Three separate scores must stay separate:

1. practical product quality:
   - `~94-95 / 100`
2. launch-surface maturity:
   - `~89-91 / 100`
3. independent delivery confidence:
   - `~90-92 / 100`
4. launch/commercial readiness:
   - `~82-86 / 100`

Meaning:

- the learner-facing route is strong and the preview-suite floor is green again after bounded proof re-stabilization
- the remaining gap to practical 100 is proof closure plus app-wide maturity closure, not only route logic
- the remaining gap to release-ready 100 is dominated by novice proof, launch-surface maturity, commerce truth, and final release proof
- parallel work is active in the tree, so route claims must keep using live command verification rather than stale snapshots

## Big-Picture Correction

The previous route view became too tunnel-focused on proof and commerce.

That was useful while the main blocker was route stabilization, but it is no
longer enough for honest near-100 reporting.

Current correction:

1. green route tests do not mean the app feels fully release-grade
2. commerce truth is important, but it is not the only remaining big block
3. visual finish, motion, Sharky distinctiveness, and premium-feel density
   still matter materially
4. table-adjacent advanced surfaces such as replay, bet sizing controls, and
   session-detail polish must be treated as maturity questions if they are
   visible in the release slice
5. the correct remaining route is now:
   - proof closure
   - launch-surface maturity closure
   - commerce/store truth closure

## What Still Feels Alpha

These are the non-trivial reasons the app can still read as alpha-like even
when the route is coherent:

1. some visual surfaces still feel more functional than premium
2. Sharky is warm and useful, but not yet a distinctive coach voice
3. motion and celebration layers still feel bounded rather than fully authored
4. table/result maturity is strong in logic, but not yet fully proven in
   premium-feel details such as slider/replay/control polish if those surfaces
   are shown
5. novice trust is still inferred, not proven
6. commerce truth is better internally, but not yet proven against real shipped
   store inventory and package truth

## Working Principles

1. Bottlenecks first.
2. One dominant family at a time.
3. Fix classes of failures before isolated symptoms.
4. Prefer user-visible closure and proof closure over broad refactors.
5. Do not spend expensive waves where diminishing returns already started.
6. Architecture debt matters, but it does not outrank higher-EV route blockers
   unless it directly blocks the next closure family.
7. Keep `Placement -> Welcome layer -> Home -> Learn -> Table -> Result -> Home`
   as the route spine when the one-time onboarding layer lands.
8. Practical product `100 / 100` is not the same as store/commercial `100 / 100`.

## Block Status

### 1. First Start and Placement

- Status: yellow-green
- Score: `89 / 100`
- What is strong:
  - trusted routing improved materially
  - placement handoff is cleaner and more value-first
- What still blocks 100:
  - no real novice proof yet
  - first-start confidence is still unproven with real novice walkthroughs
  - the route still lacks one compact post-placement onboarding layer that
    demonstrates how Sharky works before normal World 1 flow begins
- To reach 100:
  - run novice walkthrough proof
  - if needed, add one bounded post-placement onboarding family
  - keep that family outside the Learn map as product onboarding, not `World 0`

### 2. Home, Navigation, and Re-entry

- Status: green-yellow
- Score: `91 / 100`
- What is strong:
  - Home roles are clearer
  - next action is cleaner
  - daily/return grammar is better
- What still blocks 100:
  - first-return trust is still internally judged, not novice-proven
  - feedback-source maturity still affects how premium the return loop feels
- To reach 100:
  - confirm Home clarity in novice walkthroughs
  - keep Home return copy aligned with final feedback/coaching tone

### 3. Learn Path and World Map

- Status: green-yellow
- Score: `91 / 100`
- What is strong:
  - path is readable and coherent
  - active lesson expansion and lower-lesson autoscroll are green
- What still blocks 100:
  - final world-feel polish still lacks novice proof
  - compact inline hub maturity is strong but not yet externally validated
- To reach 100:
  - prove the map/hub feels clear and non-heavy to first-time users
  - keep device-proof current on the compact layout that now passes tests

### 4. Play Quick Return

- Status: green-yellow
- Score: `91 / 100`
- What is strong:
  - Play is materially clearer as quick-return practice
  - featured groups and pacing are stronger
- What still blocks 100:
  - return-loop usefulness is still unproven with real novices
  - feedback-source repetition still limits the felt coaching quality
- To reach 100:
  - verify the quick-return loop in novice proof
  - finish feedback diversity so practice feels sharp, not templated

### 5. Table and Result Core

- Status: green-yellow
- Score: `90 / 100`
- What is strong:
  - table remains readable
  - result/review transition is usable
  - release-facing replay and session-control labels now reflect actual next
    route meaning instead of generic alpha-grade wording
- What still blocks 100:
  - late-session coaching language is still limited by authored feedback reuse
  - final premium-feel proof on real devices is still not fully refreshed
  - dormant advanced controls must not silently re-enter the release score
    without an explicit activation decision
- To reach 100:
  - finish feedback source cleanup
  - refresh device proof on the near-final build
  - keep replay/session-control surfaces on release-grade route-truth grammar
  - keep sizing/slider out of the current release score until the route
    actually activates them with live state
  - before final `100 / 100`, either:
    - ship a real release-grade sizing control surface
    - or explicitly replace slider with another canonical sizing interaction

### 6. Review Repair Loop

- Status: green-yellow
- Score: `93 / 100`
- What is strong:
  - review loop exists and is productively shaped
  - fixed-summary route improved
- What still blocks 100:
  - coaching quality is still limited by authored feedback repetition
  - pattern-level confidence is still internally judged, not novice-proven
- To reach 100:
  - reduce generic feedback reuse across active repair families
  - validate review usefulness in novice walkthroughs

### 7. Profile and Identity

- Status: green-yellow
- Score: `88 / 100`
- What is strong:
  - identity mirror direction is correct
  - earned growth and next focus exist
- What still blocks 100:
  - profile meaning is still internally calibrated, not externally proven
  - the route still lacks a final maturity pass on compact profile density
- To reach 100:
  - confirm profile comprehension in novice proof
  - do one final density/copy pass only if walkthroughs show friction

### 8. Sharky, Habit, and Product Soul

- Status: yellow-green
- Score: `86 / 100`
- What is strong:
  - streak-lite and earned-return states exist
  - Sharky supports the route more than before
  - compact guide-card coaching now stays readable on narrow widths instead of
    cutting the main line and detail at arbitrary ellipsis points
- What still blocks 100:
  - phrase quality is still stronger than phrase diversity
  - the product has support and warmth, but not yet a distinct, memorable coaching voice
  - habit energy is still not validated with real user return behavior
  - the motion and celebration layer still reads as useful but not fully premium
- To reach 100:
  - validate whether users actually feel the product as alive, useful, and worth returning to
  - refine repeated phrase families only after the novice gate
  - keep the habit layer compact and evidence-led
  - do one bounded Sharky/motion/soul pass after proof, not speculative persona expansion

### 9. Feedback Coaching Quality

- Status: yellow-green
- Score: `86 / 100`
- What is strong:
  - learner-facing runtime floor is materially better
  - no empty feedback titles/reasons in state
  - empty synthetic feedback pairs are now `0`
- What still blocks 100:
  - feedback quality is now much better on the active surface than in the older source-level audit snapshot
  - the remaining tail is phrase maturity, not empty wiring
  - short/generic reasons still exist and need one final bounded pass
- To reach 100:
  - keep the runtime surface specific, calm, and scenario-first
  - reduce the short/generic reason tail in active learner-facing families
  - rerun feedback audit after any wording pass that touches the active route

### 10. Integration Stability

- Status: green
- Score: `100 / 100`
- What is strong:
  - full suite improved to `+280 -0`
  - stale proof-contract drift was materially reduced
  - runner/review/helper cascades are closed
  - counting prompt truth and learn autoscroll are now green
- What still blocks 100:
  - nothing inside the preview integration suite
- To reach 100:
  - add one regression assertion per truly fixed runtime defect
  - keep preview suite at `0` failures

### 11. Simplicity and Architecture

- Status: red
- Score: `60 / 100`
- What is strong:
  - the active route still evolves without immediate system collapse
- What still blocks 100:
  - `act0_shell_state_v1.dart` at `15183` LOC is too large
  - preview coordinator still owns too much route logic
- To reach 100:
  - split only after higher-EV route blockers are reduced
  - first split seams:
    - progression/review state
    - recommendation/home routing
    - placement mapping
  - target: largest Act0 file under `8k` LOC

### 12. Localization and Language Coverage

- Status: green-yellow
- Score: `88 / 100`
- What is strong:
  - the active EN/RU Act0 route is green in the preview suite
  - runtime surface localization is materially stronger and more governed than before
- What still blocks 100:
  - release-ready language confidence still needs an explicit supported-locale boundary
  - full-route human proof for RU clarity is still missing
  - non-Act0 or future-world language completeness should not be assumed from the active slice
- To reach 100:
  - freeze supported release locales explicitly
  - run one bounded EN/RU release smoke pass on the active route
  - keep localization scope to the active release slice, not broad future-world translation debt

### 13. Visual Coherence

- Status: green-yellow
- Score: `87 / 100`
- What is strong:
  - shell tokens are coherent
  - device proof is materially stronger than before
- What still blocks 100:
  - final novice/device proof is not fully closed
  - several surfaces still feel more like a well-structured alpha than a
    premium shipped product
  - motion, density, spacing, and hierarchy may still need one release-grade
    maturity pass
- To reach 100:
  - close remaining proof gates
  - run one explicit launch-surface maturity pass across the active shell

### 14. Value, Trial, and Commerce

- Status: red
- Score: `74 / 100`
- What is strong:
  - preview timing is more value-first
  - canonical structural boundary is now fixed:
    - `W1-W4` free
    - `W5-W36` premium
  - canonical public hybrid model is now fixed:
    - contextual 7-day trial only after value proof
    - no main trial offer immediately after placement
    - optional advanced analytics upsell belongs later, not at launch
    - launch should ship `H1`, while package and entitlement seams stay compatible with later `H5`
  - Today Plan and Premium Hub now share one canonical access-state copy seam
  - release-facing UI proof now explicitly covers expired trial fallback and premium-over-trial precedence
  - main trial CTA on Today Plan now waits for first useful loop proof instead of appearing immediately after placement
  - Today Plan restore and Premium Hub restore/upgrade now share one canonical release action seam
  - release-facing action truth now fails fast on `store unavailable`
  - lifecycle proof now covers `trial -> free` refresh on both Today Plan and Premium Hub
  - release-facing commerce availability is now canonicalized for active surfaces
  - Premium Hub and Today Plan premium preview now show truthful unavailable-store messaging instead of inviting dead-end actions
  - release-facing action-result truth is now proven for `no purchase found` and `purchase failed` on active surfaces
  - launch-compatible premium offer scope is now explicit instead of being inferred from any legacy premium product
  - public package truth now encodes `annual default + monthly secondary` explicitly
- What still blocks 100:
  - active Act0 route still lacks end-to-end real-store proof on the final
    shipped package
  - the canonical public model is premium-enabled, so preview-grade commerce
    truth is no longer acceptable for release
- To reach 100:
  - wire one unified entitlement truth
  - add deterministic purchase/restore/trial tests for the public route
  - prove final store inventory and package completeness against the chosen
    public model
  - do not ship preview-grade premium language without matching product truth

### 15. Proof Gates

- Status: yellow-red
- Score: `62 / 100`
- What is strong:
  - feedback audit exists
  - preview suite is green again after bounded proof re-stabilization
  - device proof exists in partial form
- What still blocks 100:
  - novice gate is still open
  - full proof closure is not yet defensible
- To reach 100:
  - close novice walkthrough proof
  - keep device proof evidence current
  - close feedback residue sweep

## The Real Bottlenecks

These are the current bottlenecks in the order they should be addressed.

1. `Proof and trust closure`
   - novice proof is still open
   - no honest 100 claim without the proof floor staying green and the novice gate closing

2. `Launch-surface maturity closure`
   - visual finish, motion, Sharky voice, and premium-feel density are still
     below a true shipped-product bar

3. `Commerce truth closure`
   - the public model is now fixed
   - active blocker is final package/store truth on that model

4. `Device proof refresh`
   - required before external-quality closure claims

5. `Localization release smoke`
   - active EN/RU route looks strong, but release-ready confidence still needs one bounded supported-locale proof pass

6. `Architecture split`
   - real debt
   - should be done after proof closure and feedback maturity stop dominating

## Tasks To Reach Practical 100

### Must close before a defensible 100 claim

1. novice walkthrough gate
2. final device/screenshot proof refresh on the near-final build
3. one bounded feedback language maturity pass on the active route
4. one explicit verdict on whether Sharky/habit feels distinctive enough or still reads as supportive-but-generic
5. one explicit verdict on whether visible replay/slider/session-control surfaces
   are release-grade or outside the release slice

### Must close before a high-confidence closure pass

6. one bounded proof-informed copy/density correction pass if novice walkthroughs expose real friction
7. one bounded EN/RU release smoke pass on the active route
8. one explicit rationale for any remaining deliberate non-launch closure
9. one bounded launch-surface maturity pass across:
    - Home
    - Learn
    - Play
    - Review
    - You
    - Table
    - Result

### Late but still required for full route maturity

10. release fork closure for monetization:
   - premium-enabled deterministic entitlement/purchase/restore/trial proof
11. one bounded quality-aware progression pass:
   - use repair, session rhythm, and return logic to slow shallow bingeing
   - do not use timers, pain loops, or fake scarcity
12. one bounded architecture split pass
13. final novice/device/feedback proof refresh after any late code movement

## Release Monetization Decision

Canonical public model:

- premium-enabled, value-first depth subscription

Operational meaning:

- public release should keep the long-term monetization model already intact
- internal free-only proof builds may still exist as validation tools
- public release cannot ship with preview-grade premium surfaces and weak entitlement truth

## Wave Order

This order is optimized for:

- highest EV first
- fastest reduction of real blockers
- minimum token waste
- minimum diminishing returns

### Wave A. Integration Foundation Closure

Goal:
Close the shared helper and stale root contracts that re-break multiple tests.

In scope:

- `AppRoot` boot contract
- `advanceTeachingToDrill` helper truth
- progression helper expectations shared by Home/Review/Play tests

Exit:

- no known helper/root contract in this family may stay red on "good enough"
- every fix in this wave must be proven by at least one targeted green test
- full preview suite count must fall materially and stay below the pre-wave baseline
- the wave is not closed while any remaining red in this family still cascades into unrelated tests

Must not do:

- no broad runtime redesign
- no architecture split

### Wave B. RU and Compact Safety Closure

Goal:
Close the largest remaining localization/headroom family in one pass.

In scope:

- RU runner prompt contracts
- RU early feedback labels
- compact headroom and two-line safety assertions
- Home / Play / Profile RU residue

Exit:

- RU compact family must be green, or all remaining reds must collapse to one exact owner seam with no ambiguity
- compact safety assertions must be verified on the actual asserted surfaces, not weakened
- no Russian copy regression may be accepted to save a layout assertion

Must not do:

- no broad new localization infrastructure

### Wave C. Runner Semantics and Learn Contracts

Goal:
Stabilize runner meaning, seat semantics, and learn-path continuation.

In scope:

- counting prompt truth
- active-seat and `To act` contracts
- seat feedback rendering
- lower-lesson autoscroll and Learn continuation residue

Exit:

- runner semantics family must be green in both targeted tests and the full preview suite
- learn autoscroll/continuation must be proven by deterministic viewport or route assertions
- no label-only patch counts as closure if the underlying seat or continuation truth is still wrong

Live status:

- closed
- preview suite is green after:
  - counting prompt runtime fix
  - lower-lesson autoscroll closure
  - compact inline lesson hub density pass

### Wave D. Cross-Shell Routing Coherence

Goal:
Close Home / Play / Review routing residue as one route family.

In scope:

- weak-spot routing
- Play placement leakage
- review resurfacing
- Home daily-goal / repair / weak-spot continuity

Exit:

- cross-shell route continuity family must be green in the full preview suite
- Home, Play, Review, and Result must agree on the same next-step truth after repair and return
- no placement leakage or weak-spot routing ambiguity may remain on the active path

Live status:

- closed
- active route continuity is green in the preview suite
- no current evidence says this family is still the main blocker to 100

### Wave E. Proof and Feedback Closure

Goal:
Close the remaining gap between "good implementation" and "defensible 100 claim".

In scope:

- novice walkthrough proof
- one bounded feedback maturity pass
- synthetic fallback zeroing
- proof refresh after integration stabilization

Exit:

- novice gate closed with real walkthrough evidence, not proxy belief
- feedback audit stays green on empty/synthetic pairs and no new generic collapse appears on the active surface
- post-proof regressions must be rerun after any late integration fix that touches the active route

Live status:

- active
- still required
- no longer the only main route; it now shares the frontier with launch-surface
  maturity and preview re-stabilization
- bounded proof re-stabilization landed:
  - long-copy instructional host change no longer leaves stale RU proof contracts red
  - stale wrap-up and world-5 sizing copy contracts are synced to current route truth
  - habit/profile drift is re-closed
  - preview suite is back to `+280 -0`

### Wave F. Commerce Truth Closure

Goal:
Make the fixed premium-enabled public model truthful on the active route.

In scope:

- route all active release-facing access-state reads through the canonical entitlement seam
- deterministic purchase / restore / trial / expiry proof
- exact free/premium boundary truth:
  - `W1-W4` free
  - `W5-W36` premium
- no preview-grade premium copy where entitlement truth is still missing

Exit:

- active route access-state surfaces agree on one entitlement truth
- deterministic tests cover purchase, restore, trial active, trial expiry, and premium precedence
- no release-facing premium prompt implies access the route cannot actually grant

Live status:

- active in parallel with Wave E as a release-truth family
- first bounded sub-wave landed:
  - canonical access-state copy seam for Today Plan and Premium Hub
  - deterministic UI proof for expired-trial fallback and premium precedence
- second bounded sub-wave landed:
  - canonical release-surface entitlement snapshot for Today Plan
  - explicit `W1-W4` free / `W5+` premium boundary helper
  - deterministic proof for boundary and combined entitlement-surface behavior
- third bounded sub-wave landed:
  - main trial CTA delayed until value proof on Today Plan
  - post-placement soft preview preserved while early main trial pressure was removed
  - deterministic proof for trial-offer visibility policy
- fourth bounded sub-wave landed:
  - canonical release premium action seam for restore and upgrade
  - Today Plan and Premium Hub now share one owner path for release-facing premium actions
  - deterministic proof covers restore, failed restore, premium activation, and already-active upgrade behavior
- fifth bounded sub-wave landed:
  - release-facing premium actions now fail fast on `store unavailable`
  - deterministic proof now covers `trial -> free` lifecycle refresh on Today Plan and Premium Hub
  - failure messaging for release-facing premium actions is more truthful and less generic
- sixth bounded sub-wave landed:
  - canonical release commerce availability seam for active surfaces
  - Premium Hub and Today Plan preview now expose unavailable-store truth and disable dead-end premium actions
  - deterministic proof covers unavailable-store and no-premium-product availability states
- seventh bounded sub-wave landed:
  - deterministic release-surface proof for `no purchase found` and `purchase failed`
  - Today Plan and Premium Hub now surface restore/purchase result truth more explicitly instead of relying on generic optimistic flows
- eighth bounded sub-wave landed:
  - canonical launch premium offer scope seam
  - legacy premium-pack-only scope no longer counts as launch-compatible subscription truth
  - active release surfaces now distinguish launch-compatible subscription scope from legacy premium product presence
- ninth bounded sub-wave landed:
  - canonical subscription package scope now distinguishes annual+monthly, monthly-only, annual-only, legacy-only, and unavailable states
  - annual default and monthly secondary are now represented directly in code and release docs instead of only in planning docs
- do not claim release-ready before this wave is green

### Wave G. Launch-Surface Maturity Closure

Goal:
Close the gap between a coherent route and a convincingly shipped-feeling app.

Structure decision for first-use orientation:

- do not add a canonical `World 0` to the Learn map
- if a first-use power/demo layer is needed, add it as a one-time
  post-placement `Welcome` onboarding layer
- that layer must demonstrate product power through one compact table-adjacent
  micro-win, not through brochure-style self-description
- after it finishes, the route returns to the normal `Home / Learn / World 1`
  path without polluting the curriculum ladder

Admitted beat structure for that layer:

1. one compact "how learning works here" beat
2. one compact "why this feels easier" beat
3. one compact app-shape beat (`Home / Learn / Play / Review`)
4. one short table-adjacent micro-win
5. one direct handoff into `Poker from Zero`

Implementation rules for the admitted layer:

1. show once after `Placement`, before normal `Home`
2. persist completion separately from curriculum/world progress
3. allow later replay from a help/settings-style seam, not from Learn
4. do not create a `World 0`, lesson id, or permanent map node for it
5. keep the final handoff direct: after the micro-win, route into the normal
   beginner path without a second orientation wall

Primary owner seams when this work is admitted:

1. boot / placement handoff policy
2. welcome-surface shell
3. one micro-session runner seam
4. one persisted completion flag

Technical implementation seam contract:

1. `Placement` completion checks a dedicated onboarding-complete flag
2. first-run with that flag false routes into Welcome before normal `Home`
3. completion persists outside world / lesson / map progress
4. replay lives behind a help/settings-style utility seam only
5. the table micro-session is standalone and must not register as a lesson node
6. completion routes straight into normal `Poker from Zero` entry
7. no Welcome-layer state may create `World 0` artifacts on the Learn map

Execution-level beat brief:

1. Beat 1: core promise
   - one headline
   - one short support block
   - no table yet
2. Beat 2: why the format feels easier
   - one headline
   - up to two short support blocks
   - no self-congratulatory product claims
3. Beat 3: app-shape orientation
   - compact jobs for `Home / Learn / Play / Review`
   - no dashboard/system vocabulary
4. Beat 4: first micro-win
   - real table
   - one tiny decision
   - one clear feedback reveal
   - no difficulty spike
5. Beat 5: direct handoff
   - route immediately into `Poker from Zero`
   - no second explanation wall after the micro-win

Proof checklist for the admitted layer:

1. first fresh post-placement run shows Welcome before the first normal `Home`
2. second boot skips Welcome when completion is already persisted
3. replay reopens Welcome without resetting curriculum progress
4. Learn map stays unchanged: no `World 0`, no lesson node, no fake route item
5. post-Welcome exit lands with `Poker from Zero` as the clear next action

In scope:

- one bounded visual premium-feel pass across the active shell
- one bounded Sharky / soul / motion pass
- one explicit replay / slider / session-control scope verdict
- bounded EN/RU release smoke
- one bounded quality-aware progression / anti-binge pass
- one bounded architecture split pass
- token/source isolation closure

### Wave H. Product-Truth And Surface-Role Closure

Goal:
Close the highest-EV remaining gap between a polished route and a trustworthy
product: fake-feeling progress, placeholder practice, weak placement truth, and
surface-role clutter.

Priority ladder inside this block:

1. `progress / skill truth`
2. `Play contract`
3. `Placement truth`
4. `Learn simplification`
5. `Profile role compression`
6. `Welcome presentation`

Why this order:

- learner trust is hurt more by fake or placeholder truth than by another
  visual polish pass
- `XP`, skill gains, reset behavior, and profile stats currently affect
  multiple surfaces at once, so they outrank isolated screen cleanup
- `Play` still has duplicate-route and placeholder-drill risk, which is a
  larger blocker than another compact-density pass
- `Learn`, `You`, and `Welcome` still need simplification and premium-feel
  upgrades, but those should not be used to cosmetically cover truth gaps

Admitted first wave:

#### Wave H1. Progress / Skill Truth Audit Closure

Goal:
Produce one exact truth map for progress, XP, skill gains, reset behavior, and
gain presentation before any implementation patch.

In scope:

- reset-progress -> Learn zero-state truth
- XP award derivation from real tasks
- skill-gain derivation from real task families
- gain presentation ownership in runner/table/result surfaces
- profile stat source truth

Exit:

- one exact owner verdict for the family
- if the family is coherent, one implementation wave may follow immediately
- if the family splits across unrelated owners, stop and record the split
  instead of patching blindly

Must not do:

- no Welcome redesign in the same wave
- no Learn chrome cleanup in the same wave
- no Play copy cleanup in the same wave
- no broad visual polish as a substitute for truth repair

Captured backlog inside Wave H (do not lose these when H1/H2 starts):

1. `Learn`
   - dev reset currently does not return the map to a real zero-state
   - excess pills / micro-labels / duplicated chapter cues create clutter
   - some visible truncation still remains
   - current chapter / world-card signaling feels duplicated
2. `Play`
   - some paths still collapse back into `Learn` instead of staying true to
     `Play`
   - `Today` / `Fix leak` cards carry extra small meta (`minutes`, `spots`,
     etc.) that makes the surface noisy and visually uneven
   - topic packs still need real working drill formats instead of placeholder
     routes
   - drill-mode practice should stay drill-first, without recurring lesson-like
     intros inside the drills themselves
3. `You`
   - current identity surface is too text-heavy and mixed-density
   - gain icons and gain blocks are heavier than their value
   - `Replay welcome` / `Retake placement` may not survive final role
     compression
   - extra route-back-to-Learn affordances should be reduced
4. `Placement`
   - current questions still read as low-signal and placeholder-like
   - the future question set must actually separate meaningful starting routes
5. `Welcome`
   - current visual form is not yet premium or persuasive enough
   - future redesign should demonstrate product power through better
     presentation, not extra explanation walls
6. `Progress / skills / gains`
   - XP and skill growth must reflect real task families, not decorative local
     counters
   - bottom-block gain presentation on the table is too heavy for the value it
     adds
   - stats must track real taught skills, not just look plausible

Exit:

- active surfaces must stop reading as "good alpha" and start reading as a
  deliberately finished product
- any visible replay / slider / session-detail controls must either feel
  release-grade or be removed from the release slice
- quality-aware progression must use repair, mastery, and session rhythm rather than time gates or fake scarcity
- token/source isolation and value/trial proof must be deterministic and green when premium is shipped
- the largest remaining route debt must no longer block cheap evolution
- practical `100 / 100` may only be claimed when the remaining risk is minor, explicit, and non-route-critical

Live status:

- pending
- should start once proof drift is back under control, even if commerce still
  has external store truth left
- first bounded maturity sub-wave landed:
  - runner instructional hosts now avoid forced ellipsis on long teaching copy
  - learning-rail and coach-card copy now split on logical sentence/phrase
    boundaries before falling back to bounded internal scrolling
  - compact portrait proof is green for theory, drill, and review visibility
- second bounded maturity sub-wave landed:
  - `Act0SharkyGuideCardV1` now uses an adaptive compact layout instead of
    squeezing mascot and long coach copy into one thin row
  - guide-card line and detail now use a long-copy contract with logical
    sentence splits and no forced truncation
  - narrow-width proof is green for readable Sharky coach surfaces
- third bounded maturity sub-wave landed:
  - block-summary and fixed-repair replay controls now use route-truth CTA
    grammar instead of generic `Replay block` / `Run fix again` wording
  - review-first and next-block states now surface the actual next action on
    release-facing session controls
  - session-control proof remains green in the full preview suite
- fourth bounded maturity sub-wave landed:
  - action-prompt panel now uses a compact premium card instead of a bare text
    stack in the dock
  - compact drill questions now stay on a long-copy contract without forced
    truncation
  - preview suite stayed green after the dock/prompt finish pass
- fifth bounded maturity sub-wave landed:
  - `Act0HomeShellV1` now prefers wrapped support density over hard ellipsis on
    the active Home return surface
  - next-step subtitle, optional-rep support line, and repair-card supporting
    copy now preserve compact readability without reverting to logic or route
    changes
  - deterministic Home density locks are green in targeted proof and the full
    preview suite
- sixth bounded maturity sub-wave landed:
  - `Act0ReviewShellV1` now prefers wrapped support density over hard
    truncation on the active repair surface
  - review board support copy, empty-state body, and prominent repair reason
    now keep compact headroom without changing Review routing or state truth
  - deterministic Review density locks are green in targeted proof and the
    full preview suite
- seventh bounded maturity sub-wave landed:
  - `Act0FeedbackShellV1` now prefers wrapped density over hard truncation on
    the active post-answer runner surface
  - Sharky reaction copy, selected/preferred action lines, and feedback reason
    now keep compact headroom without changing feedback scoring or route truth
  - deterministic feedback-density proof is green in targeted tests and the
    full preview suite
- eighth bounded maturity sub-wave landed:
  - `Act0BlockCompletionShellV1` now prefers wrapped density over hard
    truncation on the active post-block summary surface
  - gate message, habit detail, suggested next action, and compact accuracy
    line now keep headroom without changing CTA truth or progression logic
  - deterministic block-summary density proof is green in targeted tests and
    the full preview suite
- ninth bounded maturity sub-wave landed:
  - runner overlay microcopy now prefers wrapped density over hard truncation
    on the active pot-sweep and repair-callout surfaces
  - pot-sweep label and table-repair callout now keep compact headroom without
    changing table semantics or repair-routing truth
  - deterministic overlay-density proof is green in targeted tests and the
    full preview suite
  - current active route now has explicit proof that dormant sizing/slider
    controls are not part of the live release slice
- tenth bounded maturity sub-wave landed:
  - `Act0ProfileShellV1` now prefers wrapped density over hard truncation on
    the active identity, focus, consistency, skill-card, and achievement
    surfaces
  - profile compact copy now keeps more headroom without changing progression,
    streak, achievement, or routing truth
  - deterministic Profile density locks are green in targeted proof and the
    full preview suite
- eleventh bounded maturity sub-wave landed:
  - `Act0LessonRunnerShellV1` learning-rail support now segments oversized
    teaching and wrap-up copy into compact logical blocks instead of solving
    height pressure with an internal scroll region
  - the active runner instruction-host now advances through explicit support
    segments and returns control to drill/retry only after the final segment,
    preserving structured reading without reintroducing truncation
  - preview helpers and wrap-up/retry contracts now prove the new invariant:
    no internal support scroll, compact support dots present when needed, and
    full shared preview proof stayed green after the owner-family change
- twelfth bounded maturity sub-wave landed:
  - canonical instruction-content policy now owns compact teaching-block shape
    across the active instruction hosts instead of relying on one-off local
    split heuristics
  - `act0_instruction_content_policy_v1.dart` now drives both learning-rail
    support blocks and Sharky guide detail blocks, biasing authored copy toward
    richer `2-4` line beats instead of micro-pages or internal scroll
  - deterministic corpus proof now audits EN authored task truth and RU
    localized task truth against the shared compact contract, so future worlds
    inherit the same instruction-block guard by default
- thirteenth bounded maturity sub-wave landed:
  - `Act0PlacementShellV1` now renders dense first-start explanation copy as
    grouped support blocks instead of monolithic paragraphs on result and
    recommended-path surfaces
  - placement report body, trust lines, recommended reason, next-step follow-up,
    and premium pitch now inherit the shared instruction-content policy, so the
    first-start route matches the active runner teaching contract
  - deterministic placement preview proof now locks those grouped blocks inside
    the shared preview suite, and full Act0 preview proof stayed green after the
    owner-family change
- fourteenth bounded maturity sub-wave landed:
  - `Act0LearnPathShellV1` sticky selected-world meta now inherits the shared
    instruction-content policy instead of relying on hard ellipsis in the levels
    menu header
  - the active levels surface now keeps compact headroom for world status,
    selected-world subtitle, and next-landmark context without reopening the
    separate lesson-node or inline-hub motion families
  - deterministic Learn preview proof now locks the new sticky-meta contract in
    compact mode, and full Act0 preview proof stayed green after the
    owner-family change
- fifteenth bounded maturity sub-wave landed:
  - `Act0LearnPathShellV1` selected lesson panel now renders subtitle copy as
    compact support blocks and keeps a persistent guidance strip instead of
    collapsing the panel meta into one-line truncation on compact screens
  - the active lesson panel now reads cleaner and more premium without changing
    lesson-step ordering, CTA truth, or the separate inline-hub motion contract
  - deterministic Learn preview proof now locks subtitle headroom and guidance
    strip behavior in compact mode, and full Act0 preview proof stayed green
    after the owner-family change
- sixteenth bounded maturity sub-wave landed:
  - `Act0LearnPathShellV1` now keeps the validated "scroll first, then open"
    lesson-switch motion contract dominant by skipping the second scroll pass
    unless the expanded lesson panel is materially clipped
  - the active Learn route no longer performs a visible extra drag after the
    lesson has already aligned under the world card, while still preserving the
    compact lower-lesson viewport safety contract
  - deterministic Learn motion proof is green in both lower-lesson and
    lesson-switch targeted tests, and full shared preview proof stayed green
    after the owner-family change
- seventeenth bounded maturity sub-wave landed:
  - `Act0LearnPathShellV1` lesson-title taps now follow the real parent-child
    pending-open contract: parent records a pending lesson, child performs the
    scroll, and only then does the inline lesson hub open
  - the active Learn route no longer opens lesson detail early in the parent or
    stagger-reveals lesson steps with delayed timers, so the user sees one
    dominant motion that lands the lesson header under the world card instead
    of a second follow-on phase
  - deterministic Learn motion proof now locks the no-early-open path for a
    lower lesson and keeps the existing lesson-switch guard green, while full
    shared preview proof and `flutter analyze` stayed clean after the
    owner-family change
- eighteenth bounded maturity sub-wave landed:
  - `Act0ShellPreviewScreenV1` restore policy is now Home-first on fresh boot:
    persisted lesson/task progress survives, but ephemeral runner state no
    longer reopens the table over the launch surface
  - the active boot path now ignores stored `resumeInRunner` when rebuilding the
    shell, so hot restart returns to `Home` while preserving route progress
    instead of dropping the user back into a mid-runner phase
  - deterministic restore proof now locks `resumeInRunner: true -> Home`
    behavior and updates the old fresh-mount runner test to preserve progress
    truth without keeping the outdated auto-resume contract; full shared preview
    proof and `flutter analyze` stayed green after the owner-family change

## Stop Rules

1. Do not reopen finished product waves unless current repo truth proves it.
2. Do not spend a wave on architecture before current red route blockers are reduced.
3. Do not let launch/commercial closure take priority over route-critical blockers.
4. Do not chase cosmetic polish after the next user-visible blocker has changed.
5. Do not use a large refactor to hide unresolved proof gaps.
6. Do not close a wave on partial green if the remaining red still sits inside the same owner family.
7. Do not weaken tests, assertions, or route contracts just to reduce the failure count.

## Definition Of Practical 100

Practical product `100 / 100` is reached when all are true:

1. the active learner route feels polished and coherent
2. preview integration suite is green
3. novice gate is closed
4. feedback residue is no longer dominated by generic title reuse
5. launch surfaces no longer read as alpha-like in the active release slice
6. the remaining debt does not make the next improvements expensive or fragile
7. no still-open blocker inside a previously "closed" wave can re-break the active route

## Definition Of "Good Enough To Stop"

To avoid diminishing returns, stop at closure when all are true:

1. product route is at least `97-98 / 100` in honest user-facing quality
2. preview suite is green or reduced only to proven non-route noise with written rationale
3. novice gate is closed
4. launch surfaces no longer read as alpha-like on the active release slice
5. no current blocker is changing real learner-visible product truth
6. the remaining work is mostly launch/commercial or architecture hardening
