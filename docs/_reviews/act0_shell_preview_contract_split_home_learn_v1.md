# Act0 Shell Preview Contract Split v1 - Home + Learn

Date: 2026-06-18
Mode: bounded Home + Learn test-contract split
Scope: Home + Learn failure groups from
`docs/_reviews/act0_shell_preview_contract_refresh_v1.md`

## 1. Wave Admission

Admitted as a bounded split of the broad Act0 shell preview contract suite.

No product code, UI copy, routes, telemetry, persistence, commerce, entitlement,
premium/trial/paywall surfaces, screenshots, table geometry, localization
files, or content files were changed.

## 2. PIEC Result

The Home + Learn failures did not share one root cause. The safe subset was a
small stale-test group where assertions over-specified current Home behavior.

The remaining Home + Learn failures are either:

- broad Home contract decisions around the legacy active-world route strip;
- Learn route/state harness drift;
- first-run and First Table Guide chronology decisions;
- cross-surface navigation assertions that should be split before further edits.

## 3. Home Failure Classification

Fixed stale assertions:

- `Home focus row shows Practice now when goal not done`
  - Root cause: direct `Act0HomeShellV1` test passed `showChecklist: false`
    while expecting checklist rows.
  - Fix: set `showChecklist: true`.
- `Tapping daily focus row from fresh Home starts daily practice`
  - Root cause: same stale direct-widget setup.
  - Fix: set `showChecklist: true`.
- `Hot restart restore ignores runner resume and lands on Home`
  - Root cause: test asserted a daily-goal card after restore even though the
    contract under test is only "Home, not runner".
  - Fix: assert `act0_shell_home_mission_command_card`.
- `Existing progressed users are not forced back into First Table Guide`
  - Root cause: test asserted exactly one `Cards, ranks & suits`, but current
    Home can show the same current lesson in the mission card and checklist row.
  - Fix: assert the title exists with `findsWidgets` while keeping
    `First Table Guide` absent.

Deferred Home blockers:

- `Home shell shows Poker from Zero with compact activated route strip`
  - Current first failure expects `Active world: Poker from Zero`.
  - Product decision needed before reintroducing or deleting the legacy route
    strip contract.
- Daily/recheck/prove/retention Home rows need a separate Home-only pass because
  they depend on retention state setup and current checklist activation rules.

## 4. Learn Failure Classification

Deferred Learn blockers:

- `First Table Guide stays compact at five steps or fewer`
  - Current surface exposes six step rows, including
    `what_poker_is_table_read_recheck`.
  - This is content chronology and was not changed.
- `Fresh ready-for-basics placement still starts with First Table Guide`
  - Crosses Placement, Welcome, and Learn; deferred by scope.
- `Levels menu is separate and keeps Level 1 selected with locked levels gated`
  - Current failure expects `What poker is` after selecting World 1.
  - This is Learn route/state contract drift and needs a focused Learn pass.
- Selected lesson panel, completion unlock, runner continue, and bottom-nav
  failures remain deferred as Learn harness/state split work.

## 5. Files Changed

- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/act0_shell_preview_contract_split_home_learn_v1.md`

## 6. Recommended Next Wave

`Act0 Shell Preview Contract Split v1b - Learn Route Harness`

Bounded scope:

1. Do not touch content chronology.
2. Split Learn-only direct widget tests from full-shell navigation tests.
3. Refresh stale selected-lesson-panel and levels-menu assertions against the
   current authoritative Learn route behavior.
4. Leave Profile, Review, Welcome/Placement, geometry, localization, commerce,
   premium/trial/paywall, screenshots, and repair-intent behavior untouched.
