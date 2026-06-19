# Act0 Preview Remaining Failure Truth Audit v2

## 1. Wave Admission

Mode: audit-first remaining failure truth classification.

This wave inventories the remaining broad `act0_shell_preview_screen_v1_test.dart` failures after the Home route/retention harness cleanup. No product code, tests, copy, localization, geometry thresholds, routes, content chronology, screenshots, commerce, premium/trial/paywall, or repair-intent behavior were changed.

## 2. Evidence Reviewed

- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/act0_shell_preview_contract_refresh_v1.md`
- `docs/_reviews/act0_shell_preview_contract_split_home_learn_v1.md`
- `docs/_reviews/act0_shell_preview_contract_split_learn_route_harness_v1b.md`
- `docs/_reviews/act0_shell_preview_contract_split_profile_dead_layout_v1d.md`
- `docs/_reviews/act0_shell_preview_contract_split_review_repair_harness_v1e.md`
- `docs/_reviews/act0_shell_preview_contract_split_placement_welcome_harness_v1f.md`
- `docs/_reviews/act0_shell_preview_contract_split_home_route_retention_harness_v1g.md`
- Fresh command output from `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`

## 3. Current Broad Suite Status

Fresh result:

- Command: `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: failed
- Count: `+627 -29`

The remaining failures are not a Home route/retention cluster and not a repair-intent cluster.

## 4. Remaining Failure Inventory Grouped By Surface

### Placement Compact Geometry

Failures:

- `Placement first diagnostic keeps table visible on compact portrait`
- `Placement answer-list feedback inherits stable table viewport`

Observed assertion shape:

- Table height is `501.288` against a max budget of `500`.
- Feedback safe-bottom clearance is `-18.0` against a minimum of `12.0`.

Classification:

- Geometry/readability blocker.
- Real implementation risk until proven otherwise.
- Not a stale assertion by default because these tests protect first-run table visibility.

Next action: fix product geometry or split a dedicated Placement compact geometry wave. Do not lower thresholds in a broad cleanup wave.

### First Table Guide / Content Chronology

Failures:

- `First table guide keeps the fourth beat as a bridge from table scan into one preflop setup read`
- `First Table Guide stays compact at five steps or fewer`
- `First table guide copy avoids internal route and surface phrasing in the first-run family`

Observed assertion shape:

- Expected First Table Guide task list no longer matches current task list.
- Expected five visible steps, actual six.
- Expected first-run copy still containing `later lessons move faster`, but current family copy starts with `One loop first...`.

Classification:

- Product-decision blocker plus content chronology blocker.
- Do not classify as stale automatically. These tests protect first-value pacing and route language.

Next action: product/content decision needed before either updating tests or changing content.

### Street Board Chronology

Failure:

- `Your first hand teaches street board growth in order`

Observed assertion shape:

- Expected first board-count sequence `[0, 3, 4, 5]`.
- Actual first sequence `[0, 0, 3, 4]`.

Classification:

- Content chronology blocker.
- Possible product regression or intentional inserted preflop/setup rep; needs content-owner decision.

Next action: product/content decision needed. Do not patch harness first.

### Learn / Selected Lesson Panel Harness

Failures:

- `Opening a lower lesson auto-scrolls its inline hub into view`
- `Returning to the current lesson from a completed lesson reopens only the target after scroll`

Observed assertion shape:

- Lower lesson tap expects `act0_shell_selected_lesson_panel`, but none is mounted.
- Return-to-current test expects no selected panel during transition, but one is still mounted.

Classification:

- Harness drift and route/navigation ownership blocker.
- Prior v1b established current Learn opens to the mission card and selected panels require explicit valid opening state.

Next action: split harness or update test contract after confirming whether locked/lower lesson taps should open, ignore, or preserve current panel.

### Learn / Runner Compact Geometry

Failures:

- `Compact theory rail teaching bodies stay inside one-bite segment budget`
- `Compact non-visual W1-W3 theory avoids article chrome and stays rail-anchored`
- `Compact table-reading theory keeps the table-first learning rail model`
- `Compact stacked long options get extra readable height`
- `Compact action prompt makes the main question the dominant left-aligned line`
- `Refined compact runner review keeps feedback hierarchy calm`
- `Canonical detached shell keeps theory guidance in one place and readable suits`
- `Live compact portrait runner prioritizes table and readable rail`
- `Canonical detached shell shows teaching prompt during drill teaching states`
- `Canonical detached shell keeps drill guidance below the table only`

Observed assertion shape:

- Several rail/table geometry values miss by a small but meaningful compact budget margin, for example table height `668.0` against an expected minimum near `673.8`.
- Long option rows render at `44.0` height against a minimum of `56`.
- Some stale prompt/key expectations are mixed in, such as missing `act0_shell_question_badge`.

Classification:

- Mixed geometry/readability blocker plus harness drift.
- Highest-risk group because it protects the active runner's compact first-value experience.

Next action: dedicated compact runner geometry and navigation harness wave. Separate real geometry failures from stale key assertions before changing implementation.

### Review / Localization Headroom

Failure:

- `Review board localizes clean-state guidance and keeps support headroom in Russian`

Observed assertion shape:

- Test expects `act0_shell_runner_screen`, but current path does not mount it in this scenario.

Classification:

- Localization/headroom harness drift with possible route/navigation blocker.
- Not enough evidence for localization copy changes.

Next action: split direct Review shell localization test from full-shell runner navigation setup.

### Active Route Closeout / Static Copy Guard

Failure:

- `Active route closeout removes stale internal route phrasing from welcome Home and Review owners`

Observed assertion shape:

- Test expected a source-text match such as `en: 'Continue path'`; actual file text starts as a Dart import.

Classification:

- Stale assertion or static-source scan drift.
- Likely test-only contract update, but low product EV compared with runner geometry.

Next action: update or replace static scan in a copy-guard cleanup wave.

### Review / Profile Runner Navigation

Failures:

- `Second wrong answer becomes a deeper Review leak`
- `Profile earned achievement unlocks after first task and streak stat appears`
- `Correct answer adds a recent skill gain to Profile`

Observed assertion shape:

- Tests expect `act0_shell_runner_screen`, but the current flow remains in another shell state before the runner assertion.
- Prior Profile dead-layout audit established mounted Profile keys are current, so these failures are upstream runner/practice navigation, not Profile layout by default.

Classification:

- Route/navigation blocker and harness drift.
- Possible product regression if daily/practice runner entry is actually broken.

Next action: inspect shared `startDailyPracticeFromHub`, `startCurrentRouteFromHomeV1`, and Practice runner-entry helpers in a focused navigation harness wave. Do not rewrite Profile assertions first.

### Theory Recall / Seat-Tap Harness

Failure:

- `First related seat-tap drill restores the same table targets after recall close`

Observed assertion shape:

- Expects `act0_shell_hint_body`, but none is mounted after recall open.

Classification:

- Harness drift around recall sheet state or route phase.
- Could be stale after the v1e recall-helper split.

Next action: update recall-open helper or direct seat-tap harness in the compact runner/navigation wave if it shares the same runner state issue.

### Action Trail Drill

Failures:

- `Trail history drill embeds temporal context into the prompt owner`
- `Action trail reveals appended step after state change`

Observed assertion shape:

- Expected prompt text `Read what happened` is absent.
- Expected `act0_shell_action_trail_step_2` is absent after action-trail state update.

Classification:

- Product-decision blocker or implementation regression for action-history prompt ownership.
- This is not a generic stale test until source truth confirms whether the active product still owns action-history drills.

Next action: defer to a focused action-trail truth wave after runner geometry/navigation is stable.

### Practice Pack Setup

Failures:

- `Quick daily drill updates local daily progress`
- `Representative Play packs feed matching skill families into Profile`

Observed assertion shape:

- Tests expect runner entry after starting daily/group practice, but `act0_shell_runner_screen` is not found.
- Representative pack failure is blocked before Profile proof.

Classification:

- Route/navigation blocker with possible Practice pack setup regression.
- Higher product risk than pure stale copy because it touches daily reps.

Next action: include in a runner/practice navigation harness wave, or split immediately after compact runner geometry if runner entry is the shared blocker.

### World Completion Retention

Failure:

- `World completion seeds compact recheck targets and Home surfaces the return reason`

Observed assertion shape:

- Expected two instances of `Still yours? Run this spot once more.`, actual zero.

Classification:

- World-completion retention blocker or stale return-copy assertion.
- Product decision needed because retention copy has recently shifted away from raw internal retention terms.

Next action: defer to a dedicated world-completion retention contract wave.

## 5. Classification Summary

Counts by primary class:

- Geometry/readability blocker: 12
- Content chronology / first-run product decision: 4
- Route/navigation or harness drift: 8
- Action-trail product/harness blocker: 2
- Localization/static copy harness drift: 2
- World-completion retention blocker: 1

The suite is now small enough to repair in bounded families. It is not safe to bulk-refresh assertions because the remaining failures include real compact-readability and learning-chronology risks.

## 6. Product-Fix vs Test-Fix vs Decision-Blocker Breakdown

Likely product-fix candidates:

- Placement compact geometry.
- Runner compact geometry where table/rail budgets are missed.
- Long compact option row height.
- Practice/daily runner entry if focused reproduction proves runner launch is broken.

Likely test-fix or harness-split candidates:

- Learn selected panel scroll/opening assumptions.
- Static copy source scan.
- Review Russian clean-state full-shell setup.
- Recall sheet opening helper.
- Profile proof tests that fail before reaching Profile.

Product-decision blockers:

- First Table Guide task count/order/copy.
- Street board growth order.
- Action-trail prompt ownership.
- World-completion retention return-copy.

## 7. Highest-EV Next Repair Wave Recommendation

Recommended next wave:

`Act0 Shell Preview Contract Split v1h - Compact Runner Geometry and Navigation Harness`

Why this is highest EV:

- It covers the largest failure group, roughly ten direct runner compact failures plus adjacent recall/navigation failures.
- It protects the top-1 product promise: one real spot, visible table signal, clear why.
- It is higher product risk than static copy guards or stale Learn scroll assertions because compact table/rail readability is user-facing first-value quality.
- It can separate implementation fixes from stale harness keys before touching content chronology.
- It may also unblock Practice/Profile failures if they share runner-entry helper drift.

Bounded scope for v1h:

- Reproduce only the compact runner geometry/navigation failures.
- Keep Placement compact geometry either included only if the same runner layout seam owns it, or explicitly split out if Placement has a separate owner.
- Do not touch First Table Guide content, street chronology, localization copy, world-completion retention, commerce, screenshots, or repair-intent behavior.
- Do not lower geometry thresholds until source truth proves the old threshold is obsolete.

## 8. Deferred / Blocked Items

Deferred:

- First Table Guide content chronology and copy.
- Street board chronology.
- Action-trail prompt ownership.
- World-completion retention return-copy.
- Static route closeout source scan.
- Review RU clean-state headroom.
- Learn selected-panel scroll contract unless v1h proves it shares runner navigation state.

Blocked pending product decision:

- Whether First Table Guide should remain five visible steps or own the added bridge/recheck task.
- Whether the first four `your_first_hand` board states must be exactly preflop, flop, turn, river.
- Whether `Still yours? Run this spot once more.` remains the world-completion retention return receipt.

## 9. Verification

Commands run:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
  - Result: failed, `+627 -29`
- `flutter analyze`
  - Result: passed, no issues found
- `git diff --check`
  - Result: passed

Repair-intent targeted tests were not rerun in this docs-only audit wave. They were not touched by this wave.
