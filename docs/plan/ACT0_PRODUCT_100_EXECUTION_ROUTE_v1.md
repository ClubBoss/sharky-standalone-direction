# ACT0_PRODUCT_100_EXECUTION_ROUTE_v1

Status: ACTIVE
Purpose: one practical execution file for driving the current Act0 product
route from today's mixed product/proof state toward practical `100 / 100`
with the highest-EV order, clear bottlenecks, and low token waste.
Last updated: 2026-05-20

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
- route-facing interpretation of the broader readiness ledger

Whole-product readiness authority:

- `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`
  - use this when the question is broader than `How strong is the Act0 route?`
  - it prevents route scores from being mistaken for whole-product readiness
- `docs/plan/EXECUTION_POLICY_SSOT_v1.md`
  - use this for compact execution-policy defaults, deferred-lane rules, and
    the reopen / rebuild gate

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

## 2026-05-21 Screen / Layer Readiness Snapshot

Status: active audit snapshot, not a `100 / 100` claim.

This replaces older route-only optimism when discussing current practical
Act0 readiness. The active route is strong and usable, but it is not production
complete. Home composition is closed unless a concrete runtime, screenshot, or
novice-proof blocker appears. The user-facing pacing model remains a daily
training command center; `30-day` / monthly Home framing stays deferred.

Fresh proof signals used for this snapshot:

- `flutter analyze` is expected to remain required before any new route claim.
- `test/ui_v2/act0_en_alpha_residue_guard_test.dart` is green after the
  `Keep the route moving` residue repair.
- `test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart` is still red on
  real RU residue: `Poker from Zero`, `II`, `III`, and `pressure`.
- `Non-answer table context remains visible during active prompt` is still red
  on the missing `CO opened` context proof.
- the fast loop also shows Learn selected-lesson-panel proof drift; current
  tests expect `act0_shell_selected_lesson_panel` in several Learn paths and
  the widget is not found.
- The current fast-loop tail is not a reason to reopen Home; it points at RU /
  compact-layout proof, Learn panel proof, prompt/context proof, and remaining
  non-route tail.

Strict current Act0 product-route readiness estimate:

- `86 / 100`
- not `100 / 100`
- not launch/store-ready `100 / 100`

### Weighted Screen Model

| Screen / surface | Weight | Now | Contribution | Why not 100 | Highest-EV missing work | Est. delta | Status |
| --- | ---: | ---: | ---: | --- | --- | ---: | --- |
| Home | 7% | 92 | 6.44 | novice proof and final screenshots still missing | verify with novice walkthrough; do not redesign | +1 | closed |
| Learn / route | 5% | 88 | 4.40 | world-feel and compact RU title proof are not final | compact RU proof plus novice Learn clarity | +2 | active |
| Practice / Play | 4% | 88 | 3.52 | return-loop usefulness is internally judged | novice quick-return proof | +1 | closed_watch |
| Review | 5% | 88 | 4.40 | pattern-level coaching and novice trust not proven | Review usefulness proof; pattern grouping later | +2 | active |
| Runner / Table / Feedback | 7% | 89 | 6.23 | prompt-context proof tail and final device proof remain | prompt/context repair; device proof refresh | +2 | active |
| First Table Guide | 4% | 88 | 3.52 | guide-first comprehension is not novice-proven | novice proof on guide handoff | +2 | active |
| Placement / Welcome | 4% | 87 | 3.48 | fast first value is internally proven, not human-proven | novice first-start proof | +2 | active |
| World completion / mastery payoff | 3% | 88 | 2.64 | payoff is compact but not human-validated | proof of "got better today" feeling | +1 | active |
| You / Profile | 3% | 84 | 2.52 | progress identity is useful but still thin | bounded progress-payoff pass after proof | +2 | deferred |
| Bottom nav / shell cohesion | 3% | 90 | 2.70 | route roles are clear but final device proof remains | device/screenshot sweep | +1 | closed_watch |

### Weighted Learning / System Layer Model

| Layer | Weight | Now | Contribution | Why not 100 | Highest-EV missing work | Est. delta | Status |
| --- | ---: | ---: | ---: | --- | --- | ---: | --- |
| First-run foundation | 5% | 88 | 4.40 | novice comprehension still unproven | bounded novice walkthrough | +3 | active |
| Poker-content correctness / ownership | 4% | 90 | 3.60 | content ownership is strong but not fully human-proofed | novice + content-owner spot audit | +1 | closed_watch |
| Core lesson interaction baseline | 5% | 89 | 4.45 | prompt/context tail remains | prompt/context proof repair | +2 | active |
| Retention memory + spaced recheck | 5% | 88 | 4.40 | v1 is deterministic but not long-term validated | longer return-loop proof | +2 | active |
| Review / mistake repair / prove-owned | 5% | 88 | 4.40 | pattern-level coaching is still shallow | pattern grouping after novice proof | +2 | active |
| Content depth / transfer density | 5% | 86 | 4.30 | W5/W6 gains landed, broader depth still thin | next transfer-density wave | +4 | active |
| Long-term habit / anti-binge pacing | 4% | 84 | 3.36 | daily model exists; longer-horizon frame deferred | under-the-hood pacing proof; no monthly Home | +3 | active |
| World mastery payoff | 3% | 88 | 2.64 | payoff needs real-user validation | mastery payoff proof in walkthrough | +1 | active |
| Full-route novice QA | 5% | 78 | 3.90 | biggest unknown: real first-user comprehension | full-route novice QA/proof pass | +5 | active_blocker |
| Localization / copy trust | 4% | 78 | 3.12 | RU guard is red and compact RU layout is not final | RU proof cleanup, no broad rewrite | +3 | active |
| Telemetry / learning-loop events | 3% | 70 | 2.10 | improvement loop is not instrumented end-to-end | telemetry truth map and minimal events | +3 | deferred |
| Visual / UI premium consistency | 3% | 85 | 2.55 | Home is stronger; cross-screen device proof remains | active-shell screenshot sweep | +3 | active |
| Technical proof / dirty-tree status | 3% | 78 | 2.34 | fast loop red and worktree dirty | proof-tail split; avoid broad cleanup | +2 | active |
| Monetization / value packaging | 1% | 75 | 0.75 | not release-store proven | store/package proof later | +2 | deferred |

Weighted total: `86.16 / 100`, reported as `86 / 100`.

### Bottlenecks To 100

1. Full-route novice QA is still open.
2. Content depth and transfer density are still below the long-term product
   ambition.
3. RU/localization trust is red on real residue.
4. Learn compact RU layout proof is still open.
5. Learn selected-lesson-panel proof drift is visible in the fast loop.
6. Prompt/context proof still has a live `CO opened` failure.
7. Profile / You payoff is useful but not yet emotionally strong.
8. Cross-screen visual/premium consistency still needs a device proof sweep.
9. Telemetry / learning-loop events lag the product route.
10. Technical proof is still noisy because the tree is dirty and fast-loop is red.
11. Monetization/value packaging is not final-store proven.

### Highest-EV Next Bounded Waves

1. `Full-route novice QA / proof capture v1`
   - likely delta: `+5` if it validates the current route and produces only
     bounded fixes
   - owns: first-session clarity, first value, "I got better today", Review
     naturalness, Learn/Practice/Review/You role comprehension
2. `Content depth / transfer-density lift v2`
   - likely delta: `+4`
   - owns: shallow early-route depth, more transfer reps, more repair variants
3. `RU and compact Learn proof cleanup v1`
   - likely delta: `+3`
   - owns: RU residue, compact RU title wrapping, Learn selected-panel proof,
     supported-locale trust
4. `Prompt/context proof repair v1`
   - likely delta: `+1-2`
   - owns: the `CO opened` active-prompt context failure
5. `Profile / You payoff + minimal telemetry truth map v1`
   - likely delta: `+2-3`
   - owns: progress identity, visible improvement proof, event truth

Immediate recommendation:

- run `Full-route novice QA / proof capture v1` next
- do not reopen Home
- if a code wave must come first for proof hygiene, make it
  `Prompt/context proof repair v1`, not a broad test-tail cleanup

### Readiness Units / Block Progress Model v1

2026-05-21 correction:

- Act0 route mechanics can be high while full-product readiness stays lower.
- Route mechanics after the bounded W4 transfer-density lift are estimated at
  `90 / 100`.
- Full-product readiness must now be tracked through units, not only route
  percentages.
- Home composition remains closed unless new concrete evidence appears.
- `30-day` / monthly Home framing remains deferred.

Starting unit model after the W4 purpose-price transfer wave:

| Block | Units Now | Status | Notes |
| --- | ---: | --- | --- |
| EN Core Route Proof | 8.5 / 14 | active | route feels strong, novice proof still open |
| Home / Daily Command Center | 9 / 10 | closed_watch | do not reopen without fresh blocker |
| Learn Route Clarity | 8 / 10 | active | selected-panel proof is fixed; broader Learn proof still mixed |
| Runner / Feedback Proof | 8 / 12 | active | core prompt proof is better; broad proof tail remains |
| Review / Retention / Prove | 9 / 12 | active | deterministic and useful, still not final pattern depth |
| Practice / Daily Reps | 5 / 9 | active | useful lane, still thin on breadth and payoff |
| Content Depth / Transfer | 6.5 / 16 | active | was `5.5 / 16` before this W4 wave |
| First-Run / Foundation | 8.5 / 11 | active | beginner-safe but not human-validated |
| World Completion / Mastery | 5 / 9 | active | payoff exists, still under-proven |
| Profile / You Payoff | 3 / 10 | deferred | progress identity still thin |
| Visual Premium / Cross-Screen | 5 / 12 | active | Home is stronger; cross-screen finish still mixed |
| RU / Localization | 2.5 / 12 | deferred | do not confuse deferred RU debt with EN route completion |
| Telemetry / Learning Events | 1 / 8 | deferred | no real event truth map yet |
| Technical Proof / CI | 5.5 / 12 | active | focused proofs green, fast-loop tail still red |
| Monetization / Commercial | 2 / 10 | deferred | not release/store proven |

Scoring rules for future bounded reports:

- `+0`: audit / proof classification only
- `+0.5`: proof cleanup without product change
- `+1`: small real UX/content improvement
- `+2`: meaningful bounded content family
- `+3`: major route / learning block closed
- `+4+`: rare multi-surface wave only

Future report requirement:

1. percentage readiness delta
2. unit-based block delta
3. which blocks changed
4. which blocks stayed unchanged
5. which remaining units are highest EV
6. whether the current lane should continue or switch

## Big-Picture Correction

2026-05-21 note:

- `./tools/fast_loop_world1_v1.sh` is now clean again
- use `FULL_PRODUCT_READINESS_LEDGER_v1.md` for current whole-product scoring
  rather than treating route-weighted views here as whole-product truth

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

## 2026-05-20 Queue Refresh

This section records the live Act0 queue after the recent placement, Welcome,
copy-density, and guard-pass closures. Use it as the current continuation list
instead of older route notes that still assume those families are open.

### Active near-term queue

1. `active` Act0 / World 1 starter orientation architecture
   - Why:
     - Welcome now stays short by design
     - the route must not create a canonical `World 0`
     - current World 1 content appears to carry most table-orientation truth,
       but the starter-guide framing is still unclear
   - Landed model:
     - `First Table Guide` is now the first normal World 1 lesson
     - no canonical `World 0`
     - no numeric `Lesson 0`
     - fresh users pass through the guide before adaptive route branching
     - `What poker is` stays as the next poker-content lesson
     - `First Table Guide` owns Sharky/product/table literacy, not the primary
       Hold'em format explanation
     - `What poker is` owns Texas Hold'em orientation plus the cash-first route
       rationale
     - app-menu orientation lands only at the end of the guide, not in Welcome
   - Must verify / close:
     - novice proof on the landed guide-first route
     - whether skipped-basics presentation feels calm and replayable for
       stronger users
     - whether Learn state language such as repeated `Now` creates first-use
       orientation noise
   - Non-goals:
     - no canonical `World 0`
     - no long Welcome manual
     - no broad route rewrite

2. `active_residue` Welcome minimal bridge + orientation gap
   - Why:
     - the 2-beat Welcome fixed pre-value overload
     - screenshots and recent audits still show that Welcome can feel visually
       sparse and does not explain the app model by itself
   - Principle:
     - keep Welcome short
     - move deeper orientation into the Act0 / World 1 starter guide or a
       later contextual layer
   - Non-goals:
     - do not restore the old 5-beat Welcome without new evidence

3. `active` Home support-layer compression
   - Why:
     - Home still risks stacking too many support layers at once:
       hero subtitle, repair support, daily-goal support, and Sharky/footer
       framing
   - Goal:
     - one primary next useful action
     - progress proof over explanatory prose
   - Non-goals:
     - no sterile empty Home
     - no removal of necessary recovery guidance

4. `active_followup` Learning proof / felt progress
   - Why:
     - the route should prove learning through visible gains, not repeated
       promises
   - Candidate proof signals:
     - mistake repaired
     - next focus
     - cue spotted
     - skill gained
     - fixed on retry
     - reason understood
   - Goal:
     - improve retention, trust, first-purchase readiness, and LTV

5. `active_p1_readiness` Retention Spine architecture
   - Why:
     - the current W1-W12 route is interactive and credible, but the latest
       time model still lands far below practical `100 / 100` retention depth
     - current estimates are:
       - W1-W12 base active time: `6.1-7.4 hours`
       - W1-W12 effective time with current retry/repair overhead:
         `7.3-9.9 hours`
       - W1-W36 projected base time at current density: `18.4-22.1 hours`
       - W1-W36 projected effective time at current density:
         `22.0-29.8 hours`
     - this is materially below the target model:
       - 12 worlds: `18-30` base hours
       - 36 worlds: `60-100` base hours
       - with review/pacing: `90-150+` effective hours
       - calendar duration: `3-12 months`
   - Required architecture:
     - daily plan separation: new learning vs review vs repair vs recheck
     - mistake-memory carry-forward beyond the immediate repair moment
     - deterministic spaced resurfacing by task family / concept family
     - soft mastery gates at lesson/world boundaries
     - world-completion payoff that emits future review targets
   - Landed substrate:
     - persisted progress now stores `retentionSequence`
     - persisted progress now stores durable review-memory entries with
       `openRepair`, `fixedRecent`, `agedRecheck`, and `ownedCandidate`
       statuses
     - old snapshots migrate safely with empty retention memory
     - this substrate does not yet imply full resurfacing behavior by itself
   - Landed spaced recheck v1:
     - `fixedRecent` now promotes to `agedRecheck` with a deterministic
       sequence-gap rule
     - successful rechecks can promote to `ownedCandidate`
     - Review now owns both recent repair and aged recheck
     - Home daily-plan split remains a follow-up wave, not part of v1
   - Landed Home daily training dashboard v1:
     - Home keeps one primary route action
     - Home now surfaces compact retention jobs for `repair`, `recheck`, and
       `prove` when those jobs actually exist
     - Review owns repair / recheck detail; Home owns compact daily routing
   - Landed soft daily training contract v2:
     - Home now makes the daily mix explicit when secondary work exists:
       `continue`, `repair`, `recheck`, `prove / keep sharp`
     - missing job types collapse cleanly instead of showing fake empty rows
     - the daily plan is recommended, not mandatory; the primary route CTA
       remains available and there are no hard blocks or cooldown gates
     - preferred user-facing pacing model is now a simple daily training
       checklist, not a visible month-long obligation
     - canonical checklist shape:
       `Learn / Continue one lesson`, `Practice / Practice quick spots`,
       `Review old spots`, `Fix mistake / Keep sharp`
     - after the daily minimum is complete, the route should reward closure,
       streak credit, and `continue if you want`, not fear-based pressure
   - Landed weekly focus contract v1:
     - Home now derives one advisory weekly focus from current state without
       adding a new persistence layer
     - selection priority is deterministic:
       open repair concept -> aged recheck concept -> current route lesson
     - weekly focus is advisory only and should sit under the daily checklist
       as context, not as a second heavy obligation
     - daily jobs remain primary and there are no hard locks, timers, or
       cooldown rules
   - Landed world-completion payoff v1:
     - world completion now acts as a compact skill milestone, not only a
       route-forward summary
     - world completion now states what the learner can now do and why
       tomorrow still matters
     - world completion may emit at most a small deterministic set of future
       recheck targets into the retention spine
     - Review and Home may surface those targets later without flooding the
       route
   - Landed world-end mastery pack v1:
     - world completion now adds a compact mastery-direction pack on top of
       the existing payoff
     - the pack stays modest: `Keep sharp`, `This week`, `Recheck soon`, and
       `Prove next` when those lines are actually supported by runtime data
     - no hard mastery lock, no cooldown, and no route blocking were added
   - Landed Home Daily Training Checklist v1:
     - Home now replaces the old stacked support-card composition with one
       checklist-centered daily-training surface after the first real training
       loop
     - v1 intentionally uses a premium 4-row checklist, not a 2x2 square,
       because portrait clarity beats novelty at this stage
     - checklist rows are: `Learn`, `Practice`, `Review`, and
       `Fix / Keep sharp`
     - activated Home now uses a compact route strip above the checklist
       instead of a large route hero / Continue button
     - Home row ownership is intentionally bounded: Learn opens the existing
       Learn context, Practice opens the existing Practice hub, Review opens
       the existing Review context for due rechecks, and Fix may still launch
       direct repair / prove behavior through existing safe seams
     - Weekly Focus now renders as lightweight context above the checklist,
       not as a separate obligation card
     - if no mistake is due, the fix lane falls back to calm clean-state /
       keep-sharp language instead of fake error duty
     - before first value, Home stays simple and route-first
   - User-facing pacing direction locked:
     - do not lead learner UX with `30-day plan`, `month-long plan`, or
       similar obligation framing
     - long-term retention and pacing should work mostly under the hood until
       a richer monthly layer is proven safe
     - Home stays daily-first; Profile may later hold longer-horizon pathing
       if needed
     - full daily-checklist framing should only become the main Home structure
       after the learner has completed the first real training loop
     - if there are no mistakes due, collapse the `fix` obligation cleanly or
       shift to a clean-state / keep-sharp variant instead of showing fake work
   - Future visual direction:
     - `Daily Training Square`
     - four compact blocks in a 2x2 square form the daily minimum
     - completed state should resolve into one premium finished square/card
       with subtle shine or glow, not childish celebration
   - Landed soft mastery / prove-owned v1:
     - `ownedCandidate` is now treated as prove-it input, not as final mastery
     - a successful prove-it updates deterministic proof counts without adding
       a new persisted status
     - once proof count is strong enough, Home / Review may shift to modest
       `keep sharp` / `skill holding` language
     - v1 remains soft and evidence-based with no hard route blocking
   - Structural rules:
     - `100 / 100` requires durable retention, not only route completion
     - content expansion alone is not enough
     - lessons should support `teach -> try -> feedback/proof -> transfer /
       checkpoint` where relevant
     - pacing / review / mastery is a separate readiness layer, not optional
       polish
   - Non-goals:
     - no broad content rewrite
     - no new worlds in the first retention wave
     - no ML dependency
     - no monetization rewrite in the architecture pass
   - Next bounded implementation:
     - `Content Density Expansion / Transfer Drill Lift v1`
   - Landed first density-lift class:
     - `W6 range-fit / pressure-line transfer variants`
     - first landed tasks:
       - `w6_table_value_line_transfer`
       - `w6_turn_pressure_shift_transfer`
     - rule:
       - add real frame-change transfer material that can feed repair /
         recheck / prove, not recap duplication or filler duration
   - Landed second density-lift class:
     - `W5 street-change / draw-story transfer variants`
     - first landed tasks:
       - `turn_river_changes_w5_turn_texture_shift_transfer`
       - `turn_river_changes_w5_river_draw_story_transfer`
     - rule:
       - keep the same draw story alive across streets and recheck it through
         new turn / river frames rather than recap copy
   - Landed first mistake-review variant class:
     - `W5 street-change / draw-story repair variants`
     - first landed review path:
       - `turn_river_changes_w5_turn_hits`
         -> `turn_river_changes_w5_turn_texture_shift_transfer`
     - rule:
       - Review may repair a weak concept through one nearby fresh frame, but
         only when the mapping stays deterministic, concept-linked, and
         bounded
       - keep exact replay intact for unmapped mistakes and retention replay
         jobs
   - Landed second mistake-review variant class:
     - `W6 range-fit / pressure-line repair variants`
     - first landed review paths:
       - `w6_value_range_action`
         -> `w6_table_value_line_transfer`
       - `w6_bluff_candidate`
         -> `w6_turn_pressure_shift_transfer`
     - rule:
       - the original weak concept remains the repair source of truth even
         when Review launches a nearby transfer frame
       - successful variant repair must fix the original weak concept without
         seeding fake open-repair residue for recheck / prove replay
   - Next density candidates:
     - remaining W4 transfer family
     - world-end mastery follow-up / broader mastery-pack depth
     - weekly focus follow-up / broader pacing layer
     - monthly / 30-day framing remains deferred until it can be layered on
       top of the daily checklist without feeling like a scary obligation
     - third mistake-review variant family only if the second family stays
       clean under broader proof
     - W11 durable mastery reinforcement

### Important deferred backlog

1. `deferred` Practice theory recall / learning recovery
   - Needs future audit:
     - review previous teaching
     - contextual hint / theory recall
     - expandable micro-bite
     - mistake-driven recovery
   - Non-goal:
     - do not break practice/drill focus

2. `deferred` Beginner term introduction / glossary support
   - Why:
     - early unexplained terms such as `SB`, `BB`, `BTN`, and `UTG` can still
       confuse true beginners
   - Needs future audit:
     - term-introduction guard
     - optional local definitions / glossary support
     - first-use explanations before local jargon is trusted

3. `deferred_quality` RU human copy quality
   - Why:
     - RU W1-W3 coverage improved, but some phrasing still reads as mechanical
       rather than premium human copy
   - Known examples to preserve:
     - `Poziciya menyaet komfort...`
     - `Kakoe chtenie mesta...`
     - `ramka spota`
   - Non-goal:
     - not a current top priority unless RU launch becomes the active lane

4. `deferred_architecture` ModernTableScreenV1 ownership / legacy cleanup
   - Why:
     - the active Act0 runner route is not owned by `ModernTableScreenV1`
     - lingering references should be audited before any keep/archive/delete
       verdict
   - Non-goal:
     - no deletion without repo-proof

5. `deferred_visual` Vertical rhythm / empty-space calibration
   - Why:
     - copy compression exposed large empty spaces in some placement / Welcome /
       result surfaces
   - Principle:
     - do not add text just to fill space
     - calibrate layout only after structural placement/orientation decisions
       are settled

### Recently closed; do not reopen without new evidence

- `closed` complete-beginner shortcut before diagnostics
- `closed` placement intake reduced to `experience -> confidence -> live check`
- `closed` `confidence` simplified to single-choice
- `closed` `format` and `goal` deferred from required first-run intake with
  safe defaults
- `closed` visible premium/payment framing removed before first value
- `closed` placement result compressed to a compact start handoff
- `closed` Welcome compressed to 2 beats; orientation gap tracked separately
- `closed` placement diagnostic first-impression compact portrait guard pass
- `closed` W5-W8 teaching-step cognitive-load compression
- `closed` RU W1-W3 mixed-language coverage class
- `closed` action/result feedback consistency with no P0/P1 mismatch proven
- `closed` world-objective/task-family consistency with no P0/P1 contradiction
  proven

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
  - Welcome is now intentionally minimal, but the route still needs a clearer
    starter-orientation architecture inside the existing Act0 / World 1 path
- To reach 100:
  - run novice walkthrough proof
  - settle the first-use starter-guide framing between Welcome and the first
    World 1 block
  - keep orientation inside the existing route and outside the Learn map as
    onboarding, not `World 0`

### 2. Home, Navigation, and Re-entry

- Status: green-yellow
- Score: `91 / 100`
- What is strong:
  - Home roles are clearer
  - next action is cleaner
  - daily/return grammar is better
- What still blocks 100:
  - first-return trust is still internally judged, not novice-proven
  - Home still risks stacking too many support layers before the next useful
    action is obvious
- To reach 100:
  - confirm Home clarity in novice walkthroughs
  - compress support layers without stripping necessary recovery guidance

### 3. Learn Path and World Map

- Status: green-yellow
- Score: `91 / 100`
- What is strong:
  - path is readable and coherent
  - active lesson expansion and lower-lesson autoscroll are green
- What still blocks 100:
  - final world-feel polish still lacks novice proof
  - compact inline hub maturity is strong but not yet externally validated
  - the first World 1 block is not yet framed clearly enough as the starter
    guide / first table guide for full beginners
- To reach 100:
  - prove the map/hub feels clear and non-heavy to first-time users
  - clarify the starter-guide framing for the first World 1 block without
    creating a canonical `World 0`
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

#### Wave H2. Progress / Skill Truth Implementation

Status:
`closed green`

Delivered:

- dev reset now returns to real first-start zero-state instead of restoring an
  already-advanced route shell
- persisted progress schema now carries skill truth directly
- skill gains and profile skill stats restore from persisted truth and fall back
  to completed-task derivation only for older snapshots
- lower feedback/growth clutter was reduced without dropping gain truth

Proof:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
- `flutter analyze`

#### Wave H3. Play Contract Closure

Status:
`closed green`

Delivered:

- `Play` now keeps a separate contract from `Learn` instead of routing through
  placeholder or lesson-like entry paths
- active Play surface is reduced to `daily`, `weak spots`, and real topic-pack
  drill lanes; `continue` and `placement` stay out of the main practice surface
- starter daily reps now use real drill tasks, not intro placeholders
- drill launch contract now bypasses lesson selectability when the launch target
  is an admitted drill
- mistake repair preserves world ownership so `Review` and `Home -> Fix next`
  can reopen the correct drill owner instead of leaking into the current lesson
- daily completion truth now tracks completed reps directly, so `Done for today`
  and `Seat held for tomorrow` are driven by the real daily contract

Proof:

- focused Play / Review / Home daily tests updated to the new drill-first
  contract
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+301`
- `flutter analyze`

#### Wave H4. Placement Truth Closure

Status:
`closed green`

Delivered:

- removed low-signal self-report filler from the pre-placement intake by
  cutting the question set from `6` screens to `4`
- dropped `age` and `frequency` from route-level placement truth because they
  were adding surface bulk without improving the start decision
- route outcome now depends primarily on the real table diagnostic instead of a
  blended self-report score gate
- placement still hands off through `Welcome` and into the selected `Home`
  route without introducing a detached onboarding branch

Proof:

- focused placement tests updated to the new 4-question intake and diagnostic
  handoff contract
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+301`
- `flutter analyze`

#### Wave H5. Learn Simplification Closure

Status:
`closed green`

Delivered:

- removed the attached top `current chapter` journey strip so Learn keeps one
  dominant route header instead of a duplicated world-card stack
- removed extra module progress copy above the route header to reduce chrome
  noise before the lesson path begins
- simplified lesson-card state presentation from pill badges to plain state
  text, reducing visual clutter and uneven chip widths across the list
- expanded the pinned route header title/meta headroom so current-route copy is
  less likely to truncate harshly on compact paths

Proof:

- focused Learn simplification tests updated to the new one-header contract
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+302`
- `flutter analyze`

#### Wave H6. Profile Role Compression Closure

Status:
`closed green`

Delivered:

- removed the large first-start tools card from the main `You` surface and
  moved replay/retake utilities behind one compact tools entry
- fixed the replay/retake tools contract so the tools sheet dismisses before
  the next route opens
- simplified identity rows from boxed signal chips to lighter text rows
- reduced empty-feeling achievement chrome by shrinking icon containers and
  card height

Proof:

- focused Profile tests updated to the new compact-tools contract
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+303`
- `flutter analyze`

#### Wave H7. Welcome Presentation Closure

Status:
`closed green`

Delivered:

- welcome beats `1-3` now show product-facing visual previews instead of
  relying on text-only empty space
- intro and why-it-works beats now demonstrate the learning loop and the
  table-adjacent model before the live demo spot starts
- app-shape beat now uses a compact `2x2` role grid with icons instead of a
  long vertical brochure list
- presentation stays inside the existing welcome logic and demo flow; no new
  route family or detached onboarding branch was introduced

Proof:

- focused Welcome tests updated to the new visual-preview contract
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+304`
- `flutter analyze`

#### Wave H8. Placement Diagnostic Content Truth Closure

Status:
`closed green`

Delivered:

- upgraded the placement diagnostic from `4` very basic checks to `5` more
  route-splitting reads without opening a new owner family
- replaced seat-only and street-count-only checks with stronger starter-world
  tasks:
  - live table scan transfer
  - private-vs-board separation
  - action order
  - legal action under no-bet pressure
  - early-vs-late position value
- tightened placement thresholds so `ready for action basics` now requires a
  stronger diagnostic signal instead of passing off one advanced hit on top of
  the old softer route
- updated the placement ready surface so it previews the real diagnostic shape
  instead of an underselling `three fast reads` placeholder

Proof:

- focused placement-first-start and placement-result tests updated to the new
  `5`-read contract
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+304`
- `flutter analyze`

#### Wave H9. Play Drill Inventory Truth Closure

Status:
`closed green`

Delivered:

- topic packs now target explicit representative drills instead of reading as
  thin wrappers around whichever lesson-step happened to be first
- topic-pack launch truth no longer depends on the current selected lesson
  stack; packs now carry their own `targetWorldId` and resolve directly into
  the intended drill owner
- locked lesson chrome no longer disables drill-first packs; packs can launch
  through the existing drill-bypass contract when the representative task is a
  real drill
- `Play`-launched drill back-navigation now returns to `Play` instead of
  drifting into `Learn`
- `Play` topic-pack copy was tightened around the actual representative drill
  that opens, reducing placeholder feel at the surface level as well

Proof:

- focused Play tests updated to the new representative-drill contract
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+305`
- `flutter analyze`

#### Wave H10. Skill And XP Taxonomy Truth Closure

Status:
`closed green`

Delivered:

- moved skill-growth truth onto a centralized `taskId -> skill delta` seam
  instead of relying mostly on broad lesson-level heuristics
- representative drill families now feed matching skills:
  - action drills -> `Betting decisions`
  - blind drills -> `Blind play`
  - position drills -> `Position play`
  - best-five / showdown drills -> `Hand reading` plus `Board reading`
- kept safe fallback rules for uncatalogued tasks so persistence and future
  content do not collapse into zero-growth behavior
- retained persisted-skill compatibility while making new gains materially
  closer to the task the learner actually solved

Proof:

- focused skill-taxonomy tests now cover both persistence and multi-family drill
  gains
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+306`
- `flutter analyze`

#### Wave H Exit Verdict

Status:
`closed green`

Closed inside `Wave H`:

- `progress / skill truth`
- `Play contract`
- `Placement truth`
- `Learn simplification`
- `Profile role compression`
- `Welcome presentation`
- `Play drill inventory truth`
- `skill / xp taxonomy truth`

What `Wave H` no longer owns:

- novice-proof
- final device refresh
- app-wide premium consistency beyond the active route
- premium / trial conversion depth
- shell/runtime coherence as a structural architecture seam
- telemetry / observability scale

#### Wave I. Proof And Full-Product Coherence

Goal:
Move from a strong, internally coherent route to a product that is externally
credible, premium-consistent, and structurally ready for broader review.

Priority ladder inside this block:

1. `novice / device proof closure`
2. `launch-surface premium consistency`
3. `commerce / value packaging truth`
4. `shell-runtime coherence audit`
5. `telemetry / observability truth`
6. `localization expansion after shape hold`

Why this order:

- the external audit mostly confirmed a shift we had already reached: the
  biggest remaining issues are no longer placeholder drills or weak shell
  roles, but proof, premium consistency, and cross-surface coherence
- the English consumer-copy and alpha-residue family is now closed, so the
  next strongest remaining work is back to proof, premium consistency, and
  cross-surface coherence
- `Wave H` already removed the highest-EV product-truth residue inside Act0, so
  reopening those families would now be churn
- the strongest surviving structural signal is the split between the polished
  Act0 shell and the deeper runner/runtime ownership stack
- value packaging and telemetry still lag the learner-route maturity, but they
  should be approached after proof calibration rather than as blind redesign

Admitted first wave:

#### Wave I1. Proof Closure Calibration

Goal:
Produce one exact post-H truth map for:

- novice-proof status
- device-refresh residue
- final launch-surface premium gaps
- whether any `Wave H` family still has real reopening evidence

Exit:

- one exact proof verdict
- one dominant next family inside `Wave I`
- no reopening of `Wave H` without concrete new evidence

#### Wave I1 Exit Verdict

Status:
`closed green` for the automated current-route floor

Closed inside `Wave I1`:

- recalibrated `fast_loop` and `checkpoint` selection to the current Act0
  canonical route instead of archived map/result seams
- removed stale auto-appended UI test owners from the active fast-loop proof
  floor
- repaired `act0_product_100_proof_capture_v1.dart` for the current Practice
  owner and added Learn-detail screenshot evidence capture for visual audits
- restored one honest automated gate for the current learner-facing route:
  analyze + Act0 preview/play/guard suites + current pack/feedback guards

Proof:

- `./tools/fast_loop_world1_v1.sh --force-tests`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
- `flutter test test/ui_v2/act0_play_shell_v1_test.dart -r compact`
- `flutter test test/ui_v2/act0_en_alpha_residue_guard_test.dart -r compact`
- `flutter test test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart -r compact`
- `flutter analyze`

Honest remainder:

- `Wave I1` is not fully done at the human/release level
- remaining proof residue is manual:
  - novice walkthrough proof
  - device-refresh / physical-device polish
  - any final human-observed reopen evidence

#### Wave I1a. English Consumer-Copy And Alpha-Residue Audit

Goal:
Audit active learner-facing English across the current route and runtime for
alpha/debug/operator residue that still lowers product feel without reopening
already-closed route-truth families.

Target seams:

- `lib/ui_v2/screens/modern_table_screen_v1.dart`
- active learner-facing copy inside `lib/ui_v2/act0_shell/*`
- any surviving route/taxonomy-heavy phrasing in the current shell/runtime

Examples of the exact residue class:

- `Scenario Loader`
- `Clarity: tactical focus`
- `Back to map`
- `Skill gain`
- other operator-ish, debug-ish, or overly internal English in the live route

Exit:

- one exact residue list
- one owner verdict
- if the family is connected, one bounded implementation wave plus full proof

#### Wave I1a Exit Verdict

Status:
`closed green`

Closed inside `Wave I1a`:

- active runtime/table alpha residue in `modern_table_screen_v1.dart`
- consumer-copy cleanup for the most visible operator-ish English in active
  shell/runtime seams
- regression guard against the exact banned residue class

Proof:

- `flutter test test/ui_v2/act0_en_alpha_residue_guard_test.dart -r compact`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+306`
- `flutter analyze`

#### Wave I2. Launch-Surface Premium Consistency

Goal:
Tighten the visible launch-surface feel without reopening route-truth or
content-truth seams.

Admitted sub-wave:

`shared header chrome closure`

Additional landed sub-waves:

- `home chrome density cleanup`
- `learn premium visual redesign`
- `learn density and expanded-panel coherence`
- `play chrome density cleanup`
- `profile premium hierarchy closure`
- `profile mid-surface density cleanup`
- `review chrome density cleanup`
- `global top-strip role reduction`
- `table center-stack de-layering`
- `table runtime chrome density cleanup`

Closed inside this sub-wave:

- replaced loud eyebrow pills in shared screen headers with a calmer dot-plus-
  label treatment
- gave shared launch headers softer title/subtitle wrapping and less abrupt
  truncation
- tightened Learn list density, reduced pinned-header bulk, and constrained the
  expanded lesson/sublesson panel so large/tablet widths stay closer to the
  rest of the shell rhythm
- improved premium consistency across Home / Play / Review / Profile / Welcome
  without changing route ownership
- rebuilt `Learn` away from pseudo-map / floating-card chrome toward a calmer
  premium curriculum list with a quieter sticky header and simpler lesson
  hierarchy
- simplified `Home` by removing the optional extra-practice helper line,
  flattening daily status chrome, and reducing repair-card meta noise
- simplified `Play` tiles by removing facts rows, reducing badge chrome, and
  replacing CTA pills with calmer text-plus-arrow affordances
- simplified `Profile` by flattening rhythm meta, removing extra explanatory
  copy from milestones/recent-progress cards, and keeping mid-surface story
  lighter without touching stats truth
- closed the remaining `Profile` hierarchy residue by removing the duplicate
  identity-story card from the main surface, moving next focus directly under
  the hero, calming hero fact chrome, flattening rhythm/milestones grammar, and
  reducing dashboard-like stacking across the screen
- simplified `Review` mistake cards by removing attempts/context-count badges
  while preserving the repair story and dominant action
- reduced the shell-global top strip from a mini-dashboard into one calmer
  route-status rail by removing decorative brand chrome, keeping `Today` as
  the dominant signal, demoting XP to supporting text, and softening streak
  into a quieter token
- tightened the active table runtime chrome by slimming the center-info stack,
  calming seat-node glow/typography, and reducing feedback-panel bulk without
  changing route or runtime truth
- de-layered the compact table center stack further by softening the action
  trail, switching narrow review playback controls into a stacked compact
  layout, and scale-fitting center board cards so refined compact widths stay
  clean without content loss

Proof:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+306`
- `flutter analyze`

Sizing / replay control verdict:

- `Replay` is an active maturity seam, not a dormant concept:
  - review/fixed-mistake replay is live inside the Act0 route
  - the current contract is functional and route-coherent, but not yet a full
    premium table-control finish
  - keep replay inside release-grade route-truth grammar and polish it as a
    real visible control when the route returns to table/result maturity
- `Sizing / slider` is still a dormant final-scope seam, not an active release
  tool:
  - existing slider proof lives in `ModernTableScreenV1` and isolated tests,
    not in the current canonical Act0 release route
  - current active route already has explicit proof that slider/sizing is
    outside the live release slice
  - before a true `100 / 100` claim, the product must either:
    - ship one canonical release-grade sizing interaction
    - or explicitly replace slider with another approved sizing-control owner

Current owner verdict:

- `Replay` can be improved now as a bounded premium/control polish family
- `Slider / sizing` should not be cosmetically polished in isolation before a
  canonical activation decision

Recommended next order inside this family:

1. `Replay premium/control polish`
   - landed
   - fixed-mistake and quick-fix replay CTAs now use calmer replay grammar
   - block-summary replay CTA grammar now matches the same replay family
   - static posted blinds no longer animate on plain table mount
   - bet-chip motion now only runs during real trail playback and uses gentler
     blind-post timing
   - proof floor:
     - `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
     - `flutter analyze`
2. `Canonical sizing interaction decision`
   - decide whether slider remains the final sizing owner
   - otherwise replace it with a different canonical sizing interaction before
     polishing visuals

Deep audit verdict:

- the biggest live replay risk is not route correctness but maturity:
  - replay controls are functional but still read like utilitarian session
    controls instead of finished premium table tools
  - blind-post / bet-chip / table-reset motion has proof for layout safety, but
    not yet a fully authored smoothness/timing closure
- the biggest sizing risk is ownership:
  - `ModernTableScreenV1` proves a slider prototype and isolated testable
    behavior
  - the active Act0 route still does not prove sizing/slider as a canonical
    learner-facing control

Canonical sizing decision:

- `pure percentage slider` is **not** the approved final learner-facing owner
- approved direction is:
  - `preset-first sizing control`
  - plus optional secondary `fine-tune drag` only when the spot truly benefits
    from it

Why this is the better final direction:

- current learner curriculum already teaches named size buckets:
  - `one-third`
  - `half-pot`
  - `pot-size`
- a raw percentage slider is flexible, but it is not the best first control
  for a beginner-safe guided product
- preset-first sizing is:
  - faster to scan
  - easier to act on
  - easier to localize
  - easier to verify
  - calmer on compact screens
- optional fine-tune still preserves final-scope depth without forcing every
  learner into an abstract percentage-first interaction

Approved final shape:

1. primary sizing row:
   - `1/3 pot`
   - `1/2 pot`
   - `pot`
   - one conditional extra size only where genuinely needed
     - e.g. `2x`, `jam`, or `all-in`
2. secondary control:
   - compact fine-tune slider/scrubber
   - visually subordinate
   - not the main beginner action
3. primary CTA:
   - reflects the chosen named size
   - not only a raw percent string

Implementation implication:

- do **not** polish the current pure slider in place as the final canonical
  tool
- the next honest sizing wave is:
  - replace primary ownership with preset-first sizing
  - keep drag/fine-tune only if it still earns its place after that

Preset-first sizing control spec:

Goal:

- make sizing feel like a premium teaching control, not a sandbox widget
- keep the first decision legible, fast, and beginner-safe
- preserve advanced flexibility without making it the main surface

Primary UX contract:

1. the learner first sees named sizes, not a raw percentage
2. only legal and context-relevant sizes are active
3. the active choice updates the main action CTA immediately
4. fine-tune is secondary and never required for the basic learning flow

Primary control layout:

- one horizontal preset row above the main action CTA
- each preset uses one short label only:
  - `1/3 pot`
  - `1/2 pot`
  - `pot`
  - optional extra:
    - `2x`
    - `jam`
    - `all-in`
- only one preset can be selected at a time
- selected preset must be visually dominant without becoming a heavy card
- disabled presets remain visible only when their absence would be confusing;
  otherwise hide them entirely

Secondary control layout:

- compact fine-tune scrubber/slider hidden behind the selected preset state
  or an explicit expand affordance
- use it only in spots where micro-adjustment has real teaching value
- never place the fine-tune control visually above the preset row
- never make fine-tune the only way to express a standard named size

CTA contract:

- primary CTA must reflect the chosen size in learner language
- preferred grammar:
  - `Bet 1/3 pot`
  - `Bet 1/2 pot`
  - `Bet pot`
  - `Raise 2x`
  - `Jam`
- avoid:
  - raw `%` as the only visible decision truth
  - solver-ish abbreviations
  - abstract labels that detach from the table state

Spot-activation rules:

- beginner/default spots:
  - show only named standard buckets
  - hide fine-tune
- intermediate sizing lessons:
  - show named buckets first
  - allow secondary fine-tune if the lesson is explicitly about comparing close
    sizings
- extreme-stack / shove spots:
  - expose `jam` or `all-in` as a named primary preset
- non-sizing spots:
  - the entire sizing control family must be absent

Visual quality bar:

- no oversized pills, no control stack inside decorative cards
- the selected size should read premium and precise, not gamey
- control density must stay stable on compact phones
- labels must never truncate into unreadable `%` fragments

Implementation owner verdict:

- approved owner direction:
  - refine the existing `Act0-owned reusable sizing surface`
  - keep `ModernTableScreenV1` as donor/prototype reference only

Current active owner seam already exists:

- state/config owner:
  - `Act0SizingConfigV1`
  - `Act0SizingPresetV1`
  - `Act0SizingUiModeV1`
  - in [act0_shell_state_v1.dart](/Users/elmarsalimzade/Sharky_1.0/lib/ui_v2/act0_shell/act0_shell_state_v1.dart)
- active runtime surface:
  - `_SizingPresetsLaneV1`
  - `_SizingPresetButtonV1`
  - in [act0_lesson_runner_shell_v1.dart](/Users/elmarsalimzade/Sharky_1.0/lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart)
- donor/prototype only:
  - `lib/ui_v2/screens/modern_table_screen_v1.dart`

Why this owner is correct:

- active product boundary already says the canonical learner-facing product is
  the Act0 shell route and its direct support seams
- sizing is part of the learning route itself, not a detached table sandbox
- the curriculum already anchors sizing through Act0 content truth:
  - `World 5 / Bet Purpose And Price`
  - named buckets:
    - `one-third`
    - `half-pot`
    - `pot-size`
- keeping final ownership inside Act0 makes it easier to:
  - align with lesson copy
  - align with task-family activation rules
  - hide sizing controls in non-sizing spots
  - keep localization and proof in one active route family

Content guard:

- the control must follow curriculum truth, not invent its own sizing grammar
- starter sizing labels must stay consistent with current W5 teaching language
- later worlds may extend the preset family for advanced spots, but must not
  break the beginner W5 naming contract
- this is a staged-control decision, not a content cut:
  - beginner release presets are intentionally narrow
  - full 36-world curriculum still keeps advanced sizing families live

Coverage guard for the full curriculum:

- W5 beginner/home sizing:
  - `1/3 pot`
  - `1/2 pot`
  - `pot`
- later extensions must still preserve important advanced sizing families where
  the curriculum calls for them:
  - `overbet`
  - `underbet / block bet`
  - `river jam`
  - `2x / 2.5x / 3x` style preflop/open sizing
  - positional 3-bet sizing
  - SPR/commitment-driven geometric sizing
- advanced sizing should appear only in the worlds that own that concept, not
  leak into the early beginner control family

Planned sizing-control expansion by route depth:

1. W5:
   - purpose-and-price starter buckets only
2. W14-W16:
   - postflop sizing logic expands into small/merged/big/pot/overbet and
     turn-river commitment patterns
3. W17:
   - 3-bet sizing by position and stack depth
4. W23+:
   - modern open sizing variations
5. later advanced worlds:
   - exploitative and live-pattern sizing expansion where the concept map
     already assigns ownership

Exact later sizing activation ladder:

1. `W5` — beginner starter sizing
   - control mode:
     - `presetsOnly`
   - approved visible buckets:
     - `One-third`
     - `Half-pot`
     - `Pot-size`
   - hidden:
     - slider / fine-tune
     - overbet
     - jam / all-in
     - modern open sizes
     - positional 3-bet sizes

2. `W14` — SPR / geometry / commitment setup
   - control mode:
     - `presetsOnly` by default
     - `presetsWithSlider` only for explicitly geometry-comparison drills
   - approved visible buckets:
     - `Half-pot`
     - `Pot-size`
     - `Overbet`
   - notes:
     - this is the first honest home for `overbet` as a strategic pressure
       tool rather than a raw amount curiosity
     - slider must stay secondary and only appear in lessons about close
       multi-street planning, not generic postflop reps

3. `W16` — turn / river sizing special tools
   - control mode:
     - `presetsOnly`
   - approved visible buckets by spot:
     - turn pressure spots:
       - `Half-pot`
       - `Pot-size`
       - `Overbet`
     - river defensive/merge spots:
       - `Block bet`
       - `Half-pot`
       - `Jam`
   - notes:
     - `block bet` first appears only when the content explicitly teaches it
     - `jam` is allowed only in true commitment endpoints, not as a generic
       early-world CTA

4. `W17` — positional 3-bet sizing
   - control mode:
     - `presetsOnly`
   - approved visible buckets:
     - `3.5x`
     - `4x`
     - `4.5x`
   - activation rule:
     - exact set depends on `IP` vs `OOP` and stack depth
   - notes:
     - no raw percentage UI here
     - this is a preflop raise-family sizing surface, not a reused postflop
       pot-fraction surface

5. `W23+` — modern open sizing variations
   - control mode:
     - `presetsOnly`
   - approved visible buckets:
     - `2x`
     - `2.5x`
     - `3x`
   - notes:
     - activation only in worlds that explicitly compare open-size tradeoffs
     - no slider needed

6. `W26+` and later commitment-heavy tournament/live branches
   - control mode:
     - `presetsOnly`
   - approved visible buckets by spot:
     - `Jam`
     - `All-in`
     - world-specific short-stack raise/jam splits
   - notes:
     - jam/all-in controls are owned by stack-pressure worlds, not by W5-W17
       default surfaces

7. non-sizing spots at any route depth
   - control mode:
     - hidden
   - rule:
     - no dormant sizing chrome should render when the task is about action,
       seat order, hand reading, counting, or transfer without an explicit
       sizing decision

Implementation guard for later waves:

- do not activate a later-world sizing family just because the control can
  render it
- activation requires all three:
  1. world ownership from the curriculum map
  2. learner-facing content already teaching that bucket
  3. a focused test proving the control appears only on the intended task
     family and remains hidden elsewhere

W14 sizing activation audit verdict:

- long-horizon ownership is clear:
  - `W14` owns bet sizing as message, SPR commitment heuristics, and pot
    geometry
- active production is not there yet:
  - the current route has playable `W5` sizing tasks and `W8` SPR/commitment
    tasks
  - the current `W8` SPR tasks are concept drills about room vs commitment,
    not explicit sizing-selection drills
  - they do not yet carry `Act0TaskFamilyV1.sizing` or learner-facing named
    size buckets like `Half-pot`, `Pot-size`, or `Overbet`

Stop rule:

- do **not** activate `W14` sizing controls in runtime until production content
  actually exposes:
  1. a playable world/task owner for `W14`
  2. explicit size-choice drills that teach those buckets
  3. focused proof that the controls appear only on those tasks

Next honest frontier after W5:

- either:
  - a bounded production-content wave that brings `W14` sizing lessons/tasks
    into the active route
- or:
  - a bounded `W8` content-bridge wave if the product deliberately wants an
    earlier transitional step from `SPR feel` into `size as commitment signal`

- not:
  - activating advanced sizing chrome on current `W8` tasks that only test SPR
    intuition

Correction:

- the next wave should **not** invent a second sizing family
- it should promote and complete the current Act0 sizing seam
- it should **not** reopen already-landed W5 sizing content, lesson order, or
  concept coverage unless new evidence proves a content error

Non-duplication rule for this frontier:

- content truth is already admitted:
  - W5 owns beginner sizing buckets and purpose/price teaching
  - later worlds own advanced sizing expansion
- the remaining work is control truth only:
  - how the learner selects a size
  - how named sizing appears in the active runner UI
  - how CTA/state/rendering reflect the selected size
- do not spend the next wave rewriting:
  - W5 lesson titles
  - W5 concept ordering
  - W5 sizing labels
  - long-horizon coverage ownership
- reopen content only if implementation reveals a concrete contradiction with
  the existing curriculum truth

Next implementation wave should own:

1. refine `Act0SizingConfigV1` so spot-family rules are explicit
2. refine `_SizingPresetsLaneV1` into the approved premium/minimal preset-first surface
3. wire CTA integration so named size drives the action text truth
4. add explicit no-render contract for non-sizing spots
5. keep `presetsWithSlider` secondary and subordinate rather than primary

Code-facing implementation ladder:

Phase 1 — state contract

- extend `Act0SizingConfigV1` from a simple `mode + presets` holder into an
  explicit control contract for active spots:
  - `mode`
  - `presets`
  - `showGuidance`
  - selected CTA verb or action family if needed
  - optional `allowFineTune`
  - optional `hideWhenInactive`
- keep `Act0SizingPresetV1` lightweight, but strong enough to drive CTA truth:
  - `id`
  - `label`
  - `potFraction`
  - optional `ctaLabel`
  - optional `isPrimary`

Phase 2 — runner UI contract

- refine `_SizingPresetsLaneV1` so it becomes the primary decision control for
  `Act0TaskFamilyV1.sizing` drills
- when sizing presets are active for the spot:
  - do not show the generic action-option row as a competing primary control
  - keep the runner dock visually stable
  - keep preset labels on one line and premium/minimal
- if `mode == presetsWithSlider`, render fine-tune only as a subordinate second
  row or expand affordance

Phase 3 — selection/state truth

- remove the current surrogate preset flow that fabricates a generic
  `preset_<id>` option in the runner UI layer
- replace it with an explicit preset-selection contract:
  - selecting a preset updates `selectedPresetId`
  - selected preset drives CTA copy
  - selected preset maps deterministically to the correct sizing outcome for the
    task
- keep review/feedback truth intact:
  - the selected size must still resolve to the existing correct/wrong teaching
    outcome
  - but the learner-facing control should no longer feel like a disguised
    multiple-choice row

Phase 4 — task migration

- migrate current W5 sizing drills onto the canonical sizing-control path
  without changing lesson content:
  - `w4_small_bet`
  - `w4_half_pot_bet`
  - `w4_pot_bet`
- these tasks should keep the same:
  - purpose
  - labels
  - correct answers
  - feedback reasons
- only the control surface and state binding change

Phase 5 — non-sizing guard

- add one explicit rule:
  - if task family is not `Act0TaskFamilyV1.sizing`, no sizing control renders
- no dormant preset lane on action drills, compare drills, counting drills, or
  generic review spots

Phase 6 — advanced extension hold

- keep `presetsWithSlider` dormant or secondary for now
- do not activate advanced sizing controls broadly until the owning later worlds
  need them
- when later worlds reopen this family:
  - extend presets per world-owned concept
  - do not mutate the W5 starter contract

Suggested first runtime implementation slice:

1. W5 sizing drills only
2. `presetsOnly` mode only
3. CTA bound to named preset
4. generic option row hidden for these sizing tasks
5. focused tests first, then full preview suite

Acceptance gates for the future implementation wave:

1. preset-first sizing works on compact phone without overflow or drift
2. only relevant/legal sizes appear for the current spot
3. primary CTA reflects the named selected size
4. fine-tune control is secondary, optional, and visually subordinate
5. non-sizing spots do not show dormant sizing chrome
6. proof covers both:
   - visual/layout safety
   - action/state correctness

Suggested proof ladder:

- focused control tests:
  - preset selection changes CTA
  - irrelevant presets stay hidden
  - fine-tune does not appear in beginner/default spots
- compact layout tests
- route-grade integration test once the control is active in the canonical
  route

Historical backlog captured before Wave H closures (keep for context only, do
not treat as active undone work):

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

## Practice Contract Closure

Status:
`closed green`

Why this family is now reopened:

- the earlier `Play` waves closed route separation, drill-launch truth, and
  representative pack ownership
- current live product evidence shows that the deeper reinforcement contract is
  still incomplete
- the surface is no longer broken as a route, but it is still underpowered as
  a true practice system

Exact product verdict:

- `Practice` must stay a separate surface from `Review`
- `Review` remains the repair lane
- `Practice` owns optional repetition of already-taught material
- if the current `Play` surface shape blocks that contract, it may be rebuilt
  rather than cosmetically preserved

Hard rules:

1. no unseen content in `Practice`
2. no lesson grammar in `Practice`
3. every lane must have one explicit purpose
4. advanced packs must follow curriculum ownership, not jump ahead of it

Required lane contract:

- `Daily`
  - short return reps
  - only from completed / already-seen content
- `Fix`
  - one weak spot or quick repair rep
  - still separate from the deeper `Review` lane
- `Packs`
  - one already-taught skill family at a time
  - unlocked only after the concept family has been taught on the main route

Rapid-drill runtime contract:

- no teaching rail
- no support/explanation wall
- no full review card after every answer
- answer -> micro verdict -> next rep
- one compact batch-end summary only

Landed inside this family so far:

1. seen-only gating
   - `Daily` no longer falls back to starter/unseen reps
   - topic packs only launch already-cleared drill families
   - `Home` no longer routes into fake practice before route truth exists
2. rapid practice loop for learner-safe practice lanes
   - `Daily` now auto-chains short reps without a full feedback stop
   - topic packs now auto-return to the hub after one clean rep
   - `Review` / repair grammar stays explicit and is not collapsed into the
     same rapid loop
3. learner-facing naming and featured-first hub shape
   - visible `Play` entry now uses `Practice`
   - the surface now leads with one featured next rep instead of a flat
     undifferentiated grid
   - the featured recommendation appears once and is not duplicated lower in
     the hub
   - weak-spot repair can surface as the featured `Practice` action without
     collapsing `Review` into the same owner
4. compact return summary and `Fix` lane ownership
   - rapid `Daily` and one-rep pack runs now return with one compact closure
     card instead of a dead stop or silent jump
   - `Fix` inside `Practice` is now quick-refresh-only and can no longer stand
     in for unresolved repair work
   - deeper open mistakes stay owned by `Review`, while `Practice` keeps only
     one light reinforcement lane ready
5. final surface-shape closure
   - the approved `Practice` surface now keeps one featured recommendation,
     one calm quick-lane list, and one separate skill-pack shelf
   - quick reinforcement lanes no longer read like another equal-weight card
     catalog beside pack browsing
   - the final shape stays visibly secondary to `Learn` while still being
     clear and useful in a few seconds

Exit verdict:

- `Practice` stays separate from `Review`
- reinforcement truth is now honest end-to-end:
  - seen-only
  - rapid reps
  - quick-refresh fix lane
  - compact return summary
- current featured-first + lane-list + pack-shelf shape is approved for this
  route slice
- reopen this family only with concrete new evidence from real usage, not for
  speculative chrome churn

Implementation ladder:

1. seen-only gating:
   - every `Practice` entry must derive from already completed or already-seen
     route content
2. practice launch mode:
   - separate mode flag for practice-launched reps
3. rapid-drill shell:
   - micro verdict
   - auto-advance
   - compact batch-end summary
4. pack unlock contract:
   - topic families only appear after their curriculum owner has landed
5. later optional modes:
   - timed drills
   - until-first-miss
   - generated family packs
   - only after the base reinforcement contract is proven

Explicit non-goals for the first wave:

- do not merge `Practice` and `Review`
- do not generate advanced packs before curriculum ownership
- do not ship a broad infinite-practice system first
- do not keep the current surface shape if it blocks the right reinforcement
  contract

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
