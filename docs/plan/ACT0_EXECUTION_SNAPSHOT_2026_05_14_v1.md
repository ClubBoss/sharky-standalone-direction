# ACT0_EXECUTION_SNAPSHOT_2026_05_14_v1

Status: ACTIVE CONTINUATION SNAPSHOT
Purpose: restart-safe handover for the next chat so Act0 product work can
continue without replaying the full thread.
Last updated: 2026-05-20

## Read Order

1. `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
2. `docs/plan/MASTER_PLAN_v3.0.md`
3. `docs/plan/ACT0_PRODUCT_100_EXECUTION_ROUTE_v1.md`
4. this file
5. `docs/plan/EXECUTION_POLICY_SSOT_v1.md`

## Current Truth

Live verified on 2026-05-14:

- `flutter analyze` -> clean
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
  -> `+281 -0`
- active route quality is strong, but the app is still short of honest
  `100 / 100`

Current calibration:

1. practical product quality:
   - `~95 / 100`
2. launch-surface maturity:
   - `~92 / 100`
3. independent delivery confidence:
   - `~91-93 / 100`
4. launch/commercial readiness:
   - `~82-86 / 100`

2026-05-21 correction:

- strict current Act0 product-route readiness is `86 / 100`, not `100 / 100`
- this is lower than older route-only estimates because proof is no longer
  fully green and novice validation is still absent
- current fast-loop proof tail is dominated by:
  - RU/localization residue: `Poker from Zero`, `II`, `III`, `pressure`
  - Learn compact RU layout proof
  - Learn selected-lesson-panel proof drift:
    `act0_shell_selected_lesson_panel` is absent in several current Learn tests
  - prompt/context proof debt, including the missing `CO opened` context line
  - remaining dirty-tree / non-route tail
- EN alpha residue is currently green after the `Keep the route moving` repair
- Home composition is closed unless a fresh concrete blocker appears
- Home pacing remains daily checklist / command-center UX
- `30-day` / monthly Home framing remains deferred
- EN/default route remains the current optimization lane; RU stays deferred
  unless a bounded seam directly requires it
- the bounded W4 purpose-price transfer wave landed after the W1 live-table
  transfer wave; content depth / transfer now tracks at roughly `6.5 / 16`
  units instead of `5.5 / 16`
- future readiness reports must include both:
  - route percentage delta
  - unit-based block delta
- unit-model reporting is now the preferred way to avoid overstating
  full-product readiness while EN route mechanics improve
- `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md` is now the canonical
  full-product ledger for separating route strength from whole-product,
  release, and commercial readiness
- `docs/plan/EXECUTION_POLICY_SSOT_v1.md` is now the compact execution-policy
  wrapper for future prompt reuse, deferred-lane discipline, and rebuild-gate
  rules
- `docs/plan/CONTROLLED_DEMO_PROOF_PACKET_v1.md` now owns the canonical
  controlled internal demo path, pre-demo proof floor, known-gap list, and
  pass/fail admission rules
- 2026-05-21 scoring correction:
  - future aggregate readiness should use the unit-based formulas and guardrails
    in `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`
  - default delta is now `0` unless a wave materially reduces a named risk
- 2026-05-21 DoD correction:
  - `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md` now contains block-level
    DoD criteria for future unit movement
  - future summaries should cite the affected block criteria instead of treating
    remaining units as tiny task tickets

2026-05-21 floor update:

- `./tools/fast_loop_world1_v1.sh` now reports `FAST LOOP PASS`
- this improves proof confidence, but it does not mean full-product readiness
  equals Act0 route mechanics

## What Was Just Finished

Recent bounded maturity waves already landed:

1. instructional host long-copy contract
   - runner learning rail and coach card no longer force ellipsis on long
     teaching text
2. Sharky guide-card compact readability
   - `Act0SharkyGuideCardV1` now keeps long coach copy readable on narrow
     widths
3. replay / session-control route-truth grammar
   - block summary and repair replay controls now say the actual next route
     action instead of generic placeholder labels
4. action dock prompt readability
   - action prompt panel now uses a proper compact card and keeps drill
     questions readable without forced truncation
5. world completion / mastery payoff v2
   - world completion now frames skill gain, keep-sharp direction, tomorrow
     value, and next-unlock reason more clearly without fake mastery or
     monthly-pressure language
6. Profile / You payoff v2
   - Profile now shows stronger progress evidence for what improved, what is
     getting stronger, what got fixed, and why the next session starts warmer
     without turning into a heavy dashboard

## What Is Not Done Yet

The next chat must not assume the app is done just because the preview suite is
green.

The big remaining blocks are:

1. `Novice proof`
   - no real novice walkthrough closure yet
2. `Final device refresh`
   - compact/large/tablet proof still needs a near-final pass
3. `Launch-surface premium feel`
   - several surfaces still feel more functional than fully authored
4. `Commerce/store truth`
   - internal seams are stronger, but real final package/store proof is not
     closed
5. `Feedback phrase maturity`
   - wiring is clean, but some learner-facing phrase families still need the
     last polish pass

## 2026-05-20 Queue Refresh

Recent first-start closures materially changed the immediate queue after this
snapshot was first written.

Closed since the original 2026-05-14 handover:

- complete-beginner placement bypass before diagnostics
- reduced placement intake and profile-signal simplification
- compact placement result start handoff
- visible premium/payment framing removed before first value
- Welcome compressed to 2 beats
- placement diagnostic compact-portrait first-impression guard pass
- action/result feedback consistency audit with no P0/P1 mismatch proven
- world-objective/task-family consistency audit with no P0/P1 contradiction proven
- starter orientation architecture now lands as `First Table Guide`, the first
  normal World 1 lesson before adaptive route branching

Current near-term queue:

1. `Welcome minimal bridge + orientation gap`
   - preserve the 2-beat bridge
   - keep deeper app/table orientation inside `First Table Guide` rather than
     back into a brochure-style Welcome
   - keep Texas Hold'em / cash-first ownership in `What poker is`, not in the
     guide shell
2. `Home support-layer compression`
   - keep one obvious next useful action
   - prefer progress proof over stacked helper prose
3. `Learning proof / felt progress`
   - strengthen visible proof that the learner is improving, not only reading
     promises
4. `Novice proof on guide-first adaptive route`
   - verify that fresh users understand the loop before the route adapts
   - verify that stronger users read skipped/replayable basics as available,
     not broken
5. `Retention spine architecture`
   - no longer treat long-term pacing / retention as only deferred backlog
   - the current time model shows a real `100 / 100` gap:
     - W1-W12 base active time: `6.1-7.4 hours`
     - W1-W12 effective time: `7.3-9.9 hours`
     - W1-W36 projected base time: `18.4-22.1 hours`
     - W1-W36 projected effective time: `22.0-29.8 hours`
   - route completion alone is not enough
   - the next retention architecture pass should define:
     - daily plan separation
     - mistake-memory carry-forward
     - deterministic spaced resurfacing
     - soft mastery gates
     - world-completion payoff
   - current landed prerequisite:
     - persisted progress now has the minimum retention-memory substrate needed
       for future spaced recheck waves
   - next bounded wave:
     - `Review Memory + Spaced Recheck Contract v1`
   - landed follow-up:
     - Home now stays compact and action-first while surfacing daily retention
       jobs
     - world completion now adds compact ownership + tomorrow payoff and may
       seed a tiny deterministic recheck set
   - landed follow-up:
     - `ownedCandidate` now behaves as prove-it input rather than fake final
       mastery
     - repeated clean proofs can shift Home / Review into modest `keep sharp`
       language without hard route blocking
   - next bounded wave:
     - `Content Density Expansion / Transfer Drill Lift v1`
   - landed first density-lift class:
     - `W6 range-fit / pressure-line transfer variants`
     - first landed tasks:
       - `w6_table_value_line_transfer`
       - `w6_turn_pressure_shift_transfer`
     - they extend the retention spine with real transfer material instead of
       recap duplication
   - landed second density-lift class:
     - `W5 street-change / draw-story transfer variants`
     - first landed tasks:
       - `turn_river_changes_w5_turn_texture_shift_transfer`
       - `turn_river_changes_w5_river_draw_story_transfer`
     - they extend the retention spine with cross-street transfer material
       instead of isolated board beats
   - landed first mistake-review variant family:
     - `W5 street-change / draw-story repair variants`
     - first landed repair path:
       - `turn_river_changes_w5_turn_hits`
         -> `turn_river_changes_w5_turn_texture_shift_transfer`
     - Review can now repair one concept through a nearby fresh frame without
       creating fake open-repair residue for prove / recheck replay
   - landed second mistake-review variant family:
     - `W6 range-fit / pressure-line repair variants`
     - first landed repair paths:
       - `w6_value_range_action`
         -> `w6_table_value_line_transfer`
       - `w6_bluff_candidate`
         -> `w6_turn_pressure_shift_transfer`
     - Review now has more than one bounded concept-linked fresh-frame repair
       family while keeping original weak-concept ownership and clean
       prove/recheck replay
   - landed soft daily training contract v2:
     - Home now makes the daily mix explicit when secondary jobs exist:
       `continue`, `repair`, `recheck`, and `prove / keep sharp`
     - missing job types collapse cleanly
     - the plan is recommended, not mandatory; primary route continuation
       remains live after daily completion and no hard stop was added
     - preferred user-facing pacing frame is now a simple daily training
       checklist, not a visible month-long commitment
   - landed weekly focus contract v1:
     - Home now derives one advisory weekly focus from current runtime state
     - focus priority is:
       open repair concept -> aged recheck concept -> current route lesson
     - daily plan remains primary; weekly focus is advisory only and adds no
       lock, timer, cooldown, or new persistence contract
     - weekly focus should sit below the daily checklist as context, not as a
       separate obligation
   - landed Home Daily Training Checklist v1:
     - Home now uses one checklist-centered composition after the first real
       training loop instead of the older stack of repair / weekly / daily
       support cards
     - v1 ships as a premium 4-row checklist, not the future 2x2 square,
       because compact portrait clarity is the safer owner truth
     - row contract is:
       `Learn`, `Practice`, `Review`, `Fix / Keep sharp`
     - activated Home now compresses the route affordance into a small route
       strip above the checklist; the large route hero / Continue button stays
       fresh-state only
     - Learn / Practice / Review rows use existing tab contexts where safe;
       Fix / Keep sharp keeps direct repair or prove behavior when actionable
     - the fix row now collapses cleanly to calm keep-sharp / clean-state copy
       when no mistake is due
     - Weekly Focus is now lightweight context, not a separate Home task card
   - landed world-end mastery pack v1:
     - world completion now adds one compact mastery-direction pack above the
       existing return reason
     - the pack may summarize `This week`, `Recheck soon`, and `Prove next`
       from already-capped runtime targets
     - no hard mastery locks or progression gates were added
   - pacing direction locked:
     - do not push `30-day plan` / monthly-obligation copy in learner-facing
       Home UX yet
     - long-term pacing remains mostly under the hood for now
     - Home stays daily-first; Profile may later hold a longer-horizon path if
       needed
     - future visual direction is a `Daily Training Square`:
       4 compact daily blocks that resolve into one premium completed square
       after the daily minimum is done
   - next bounded candidate:
     - weekly-focus follow-up, broader mastery-pack depth, or remaining W4
       transfer family

Deferred but important:

- practice theory recall / learning recovery
- beginner terminology / glossary support
- RU human-copy quality
- ModernTableScreenV1 ownership / legacy cleanup
- vertical rhythm / empty-space calibration after structural orientation
  decisions are settled

## Explicit Scope Verdicts

These points are important so the next chat does not drift:

### 1. Sizing / slider

- current live Act0 route does **not** activate a sizing/slider surface
- the current preview route proves that dormant sizing controls are not part of
  the active release slice today
- therefore sizing/slider is **not** a current blocker for the green proof
  floor

But:

- sizing/slider is **still part of the intended 100% product scope**
- it must not be forgotten or silently dropped
- before claiming final `100 / 100`, the product must do one of these two
  things explicitly:
  1. activate a real sizing control surface in the live route and make it
     release-grade
  2. replace slider with a different canonical sizing interaction and prove
     that this is the final product decision

Rule:

- no future chat should conclude "sizing is not needed" just because it is
  dormant today
- dormant today means "not active blocker now", not "removed from the final
  product vision"

### 2. Replay / session controls

- these are active release-facing surfaces
- they already received one route-truth grammar pass
- they should now be treated as mostly green unless a broader visual/motion
  maturity wave proves otherwise

## Best Next Wave

The next highest-EV bounded wave is:

### Wave: Full-Route Novice QA / Proof Capture

Focus:

- prove whether a first-time learner understands the full current route
- measure first-session clarity, first useful value, Review naturalness, and
  whether the learner feels better after the loop
- record concrete blockers by owner instead of reopening closed surfaces by
  instinct

Primary owner seams:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`

What to avoid:

- do not reopen Home composition unless the walkthrough proves a fresh blocker
- do not add a `30-day` or monthly Home shell
- do not do broad localization, commerce, or runner redesign inside the novice
  proof wave

If a code wave must come first for proof hygiene:

- use `Prompt/context proof repair v1`
- target the active `CO opened` context failure only
- do not turn it into broad test-tail cleanup

## After That

After the novice proof pass, the next order should be:

1. content depth / transfer-density lift
2. RU and compact Learn proof cleanup, including selected-lesson-panel drift
3. final device refresh
4. Profile / You payoff if novice proof says progress identity is weak
5. one final release/store truth closure pass

## Commands To Re-Verify Before Any New Claim

Use these before recalibrating the route in the next chat:

```bash
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact
flutter test test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart -r compact
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Non-answer table context remains visible during active prompt' -r compact
flutter analyze
./tools/fast_loop_world1_v1.sh
```

## One-Sentence Resume Brief

Act0 is strong but not `100 / 100`: Home is closed, the guide-first route is
explicit, EN alpha residue is green, RU / compact Learn / prompt-context proof
tail remains visible, and the next highest-EV route move is full-route novice
QA before another product-build wave.
