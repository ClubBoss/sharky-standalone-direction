# ACT0_EXECUTION_SNAPSHOT_2026_05_14_v1

Status: ACTIVE CONTINUATION SNAPSHOT
Purpose: restart-safe handover for the next chat so Act0 product work can
continue without replaying the full thread.
Last updated: 2026-05-14

## Read Order

1. `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
2. `docs/plan/MASTER_PLAN_v3.0.md`
3. `docs/plan/ACT0_PRODUCT_100_EXECUTION_ROUTE_v1.md`
4. this file

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

### Wave: Visual Premium-Feel Density Pass

Focus:

- active shell density
- premium finish
- hierarchy polish
- motion restraint
- finish quality rather than new state logic

Primary owner seams:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_tokens_v1.dart`

What to avoid:

- do not reopen commerce truth first
- do not reopen proof-restabilization unless tests actually go red
- do not invent a slider implementation blindly without activating the product
  route that needs it

## After That

After the visual premium-feel pass, the next order should be:

1. decide the canonical `sizing control` implementation for the final product
   if it is entering the active release slice soon
2. run `novice walkthrough proof`
3. run final device refresh
4. do one final release/store truth closure pass

## Commands To Re-Verify Before Any New Claim

Use these before recalibrating the route in the next chat:

```bash
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact
flutter analyze
dart run tools/act0_feedback_floor_audit.dart
```

## One-Sentence Resume Brief

Act0 is green on proof and strong on route quality; the next chat should keep
working inside `Launch-Surface Maturity Closure`, explicitly remember that
sizing/slider still belongs to the intended final product, and only reopen new
families when live verification proves they are the highest-EV blocker.
