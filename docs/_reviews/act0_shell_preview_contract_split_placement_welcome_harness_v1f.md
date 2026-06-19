# Act0 Shell Preview Contract Split v1f - Placement and Welcome Harness

## Wave Admission

Bounded Placement/Welcome harness stabilization only. No product code, content,
route, telemetry, commerce, screenshot, localization, compact-geometry, Home,
Learn, Profile, Review, or repair-intent implementation changes were made.

## PIEC Result

Current source truth shows:

- Welcome intro is the two-beat `Find your start` flow.
- Welcome handoff remains `Your path is ready.` / `Твой маршрут готов.`.
- Placement `Start recommended` is a direct runner handoff.
- Placement `Start from zero` keeps the foundation Welcome/Home/Learn path.
- Compact Placement answer-list geometry is still guarded by existing table and
  safe-bottom budget assertions.

## Placement/Welcome Failure Inventory

Fixed as stale harness or stale copy:

- `Placement seeds poker skill stats into Profile`
- `Welcome compresses to two beats before first lesson handoff`
- `Welcome intro beat localizes cleanly in Russian`
- `Fresh ready-for-basics placement can still start with First Table Guide`

Already green:

- `Welcome handoff localizes cleanly in Russian after one intro step`

Left blocked as compact geometry:

- `Placement first diagnostic keeps table visible on compact portrait`
  - Current table height is `501.288`, while the existing budget max is `500`.
- `Placement answer-list feedback inherits stable table viewport`
  - Current feedback CTA bottom gap is `-18`, while the existing safe-bottom
    budget requires at least `12`.

## Old Assertions To Current Behavior

- Old Welcome intro title `Your path is almost ready.` now maps to
  `Find your start`.
- Old RU Welcome intro title `Твой маршрут почти готов.` now maps to
  `Найди свой старт`.
- Old intro CTA `See your start` now maps to `Find my start`.
- Old RU intro CTA `Посмотреть свой старт` now maps to `Найти мой старт`.
- Tests that need Home/Learn/Profile after placement use
  `act0_shell_placement_start_zero`, because `act0_shell_placement_start_recommended`
  now opens the recommended runner directly.
- The ready-for-basics foundation check now proves the from-zero option still
  opens First Table Guide instead of pretending recommended direct-runner flow
  should land on Learn.

## Fixes Applied

- Made `completeWelcomeLayer` a no-op when Welcome is not mounted, preserving
  tests that intentionally enter the direct runner path.
- Refreshed stale Welcome intro EN/RU text assertions.
- Updated Placement handoff tests that assert Home/Learn/Profile state to use
  the explicit from-zero path.
- Replaced stale hard-coded diagnostic answer keys with the existing current
  correct-answer helper for the three-check Placement diagnostic.

## Broad Suite Status

The safe Placement/Welcome harness tests now pass in isolation. The full broad
preview file remains red because compact Placement geometry and non-Placement
groups are still failing.

## Deferred

Deferred by scope:

- Placement compact geometry budgets.
- Home route/retention rows.
- Learn/runner compact geometry.
- Profile non-placement failures.
- action-trail drill.
- lesson progression.
- world-completion retention.
- content chronology.

## Recommended Next Wave

Act0 Shell Preview Contract Split v1g - Home Route and Retention Harness.
