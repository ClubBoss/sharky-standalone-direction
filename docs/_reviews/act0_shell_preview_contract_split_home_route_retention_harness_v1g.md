# Act0 Shell Preview Contract Split v1g - Home Route and Retention Harness

## Wave Admission

Mode: bounded Home route/retention harness contract refresh.

This wave only touched Home route strip and Home retention/recommendation assertions in `test/ui_v2/act0_shell_preview_screen_v1_test.dart`. It did not change product code, Home recommendation logic, repair-intent behavior, route truth, monetization, screenshots, localization, compact geometry, Placement, Learn, Profile, Review, or content.

## PIEC Result

Existing Home behavior is product-authoritative for this wave:

- Home exposes the current route through mounted mission/checklist keys, not the stale literal `Active world: Poker from Zero`.
- Checklist activation is conditional. A direct `Act0HomeShellV1(showChecklist: false)` does not mount the daily plan card or checklist rows.
- The current weekly-focus concept is folded into the active checklist/daily-plan surface; no separate weekly-focus card owner is mounted.
- Retention recheck/prove jobs are represented as Home plan jobs, but not every retention row is immediately tappable. Rows can be pending behind Learn/Practice/Repair ownership.
- The Home repair row is normalized to learner-facing `Repair` language; stale `Fix one mistake` assertions are no longer current.
- Home support copy currently wraps without a hard `maxLines` contract, while compact checklist row title/detail text is single-line fade.

## Home Route / Retention Failure Inventory

Fixed stale Home assertions:

- `Home shell shows Poker from Zero with compact activated route strip`
- `Home stays route-first before checklist activation`
- `Activated Home does not duplicate the current lesson across hero focus and Learn row`
- `Home shows recheck job when agedRecheck exists`
- `Weekly focus uses open repair concept when available`
- `Weekly focus uses aged recheck concept when no open repair exists`
- W6/W5/W5-outs/W5-flush/W4/W1 retention transfer recheck rows
- `Home shows prove job when ownedCandidate exists`
- `Home shows keep-sharp job after prove threshold is met`
- `Home shows full soft daily mix when continue repair recheck and prove are all available`
- `Home support copy prefers wrapped density over hard truncation`
- `Home fix row keeps compact multi-line density for long copy`
- `Home daily goal card pivots to weak-spot repair when needed`

Classification:

- Stale test expectation: route strip literal text, weekly-focus standalone owner, `Fix one mistake` copy, hard support-line truncation, two-line compact row assumption.
- Harness drift: direct Home shell tests that expected checklist rows while constructing `showChecklist: false`.
- Recommendation ownership drift: retention recheck/prove rows were expected to navigate immediately even when the current Home contract only surfaces the job row.
- Real product regression: none proven in Home route/retention scope.

## Mapping From Old Assertions To Current Home Behavior

- Old: `Active world: Poker from Zero` text.
  Current: `act0_shell_home_primary_route_title` and `act0_shell_home_week1_title` are mounted.
- Old: inactive Home still mounts checklist/daily-plan rows.
  Current: `showChecklist: false` keeps `act0_shell_home_focus_checklist`, `act0_shell_home_daily_plan_card`, and checklist rows unmounted.
- Old: weekly focus has standalone title/detail keys.
  Current: weekly/current focus is represented through `act0_shell_home_daily_plan_card`, checklist rows, and active repair/review row state.
- Old: recheck/prove rows navigate immediately to Review or runner.
  Current: Home surfaces deterministic plan-job keys such as `act0_shell_home_plan_job_recheck:<taskId>` and `act0_shell_home_plan_job_prove:<taskId>`.
- Old: repair row uses `Fix one mistake`.
  Current: repair row label is `Repair`, with repair detail owned separately.
- Old: support copy has a hard max-line/overflow contract.
  Current: support copy wraps without hard truncation.
- Old: compact fix row title/detail are two-line.
  Current: compact row title/detail are single-line fade.

## Fixes Applied

Updated Home-only test assertions to match current mounted keys, row ownership, copy normalization, and density contracts. No production implementation files were changed by this wave.

## Broad Suite Status

Before this wave, the broad preview suite was expected around 44 failures after the v1f Placement/Welcome harness split.

After this wave:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: still red, `+627 -29`

The remaining failures are outside the Home route/retention boundary.

## Deferred Non-Home Groups

- Placement compact geometry.
- Learn/runner compact geometry and selected lesson panel harness.
- Review/Profile runner navigation harnesses.
- Action-trail drill prompt/step ownership.
- First Table Guide copy and step-count contract.
- Content chronology for street board growth.
- World-completion retention return-copy contract.

## Recommended Next Wave

Act0 Shell Preview Contract Split v1h - Compact Runner Geometry and Navigation Harness.

Start with the first remaining non-Home failures in the broad preview file, especially Placement compact table visibility and runner viewport geometry, and keep content chronology/world-completion retention deferred unless they become the first bounded blocker.
