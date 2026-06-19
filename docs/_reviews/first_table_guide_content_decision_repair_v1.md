# First Table Guide Content Decision + Repair v1

## 1. Current broad status

Incoming known broad preview status:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result before this wave: failed, `+643 -13`

Post-repair broad preview status:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result after this wave: failed, `+647 -9`
- First Table Guide failures cleared; remaining failures are outside this wave.

Targeted First Table Guide failures were reproduced before repair:

- `First table guide compact table-read transfer keeps the support body within a native-safe compact budget`
- `First table guide keeps the fourth beat as a bridge from table scan into one preflop setup read`
- `First Table Guide stays compact at five steps or fewer`
- `First table guide copy avoids internal route and surface phrasing in the first-run family`

## 2. First Table Guide failure inventory

| failing test | observed mismatch | owner |
|---|---|---|
| Compact table-read transfer support body | Test expected `act0_shell_action_context_line`; current compact theory surface renders the support copy in `act0_shell_learning_rail_support_line`. | stale test owner after compact learning-rail migration |
| Fourth beat bridge | Test expected five tasks; current lesson includes `what_poker_is_table_read_recheck` between table-read transfer and preflop setup. | product decision |
| Five steps or fewer | Test expected five visible lesson-step rows; current visible list has six rows. | product decision |
| First-run copy | Test expected `later lessons move faster`; current family copy repeated tab jobs and lacked the exact first-value payoff phrase. | product copy |

## 3. Current content/task list

Current `what_poker_is` / First Table Guide task list:

1. `what_poker_is_theory` - theory - Meet the table
2. `what_poker_is_find_hero` - drill - Find your seat
3. `what_poker_is_table_read_transfer` - drill / transfer - Read the table
4. `what_poker_is_table_read_recheck` - drill / transfer - Table read recheck
5. `first_table_guide_one_clear_choice` - drill - Read the preflop setup
6. `first_table_guide_route_roles` - review / transfer - Where to go next

The recheck task is also the deterministic same-signal target for table-read repair and reinforcement.

## 4. Old test expectations

Old expectations:

- Compact table-read transfer support was owned by `act0_shell_action_context_line`.
- The lesson had exactly five tasks.
- The fourth task was `first_table_guide_one_clear_choice`.
- The visible Learn hub showed exactly five step rows.
- First-run copy contained `later lessons move faster`, `later lessons keep reusing`, and compact tab-job language.

## 5. Product decision selected: C

Selected decision: C. Hybrid: keep current learning intent but compress and lock the contract.

Locked First Table Guide contract:

- First Table Guide has five conceptual beats.
- It may include one tiny same-signal table-read recheck rep because that rep is the deterministic repair/reinforcement target for the first visible table clue.
- The recheck must stay small and table-first.
- The recheck must not become broad content expansion or a second explanation wall.
- The preflop setup read remains the first action-adjacent decision after table scan and recheck.
- First-run copy must stay compact, learner-facing, and free of internal route/surface phrasing.

## 6. Decision rationale

Why not A:

- Removing `what_poker_is_table_read_recheck` from the lesson would make the mapped same-signal repair target unavailable to the shell resolver and would risk degrading the deterministic repair arc into exact replay.

Why not B:

- Treating the current six-step flow as fully product-authoritative without cleanup would ignore first-value pacing and the repeated route-style copy.

Why C:

- It preserves the AI Personalization / Rule-Based Repair Layer v1 direction by keeping the same-signal table-read target launchable.
- It protects first-value pacing by treating the extra row as one tiny recheck rep, not a new conceptual beat.
- It keeps the table-first loop intact: read the table, repeat the clue once, then carry it into the preflop setup read.
- It removes copy repetition and keeps tab jobs in compact user-facing language.

Confidence: medium-high.

## 7. Changes applied

Product copy:

- Tightened `first_table_guide_one_clear_choice` feedback reason to include the first-value payoff: later lessons move faster because later lessons keep reusing the same table-first scan.
- Tightened `first_table_guide_route_roles` hint and feedback reasons so the tab jobs remain learner-facing and less repetitive.

Test contract:

- Updated the compact support-body test to read the current learning rail support owner.
- Updated the task-order test to lock the same-signal recheck before the preflop setup read.
- Updated the visible step-count test to lock five conceptual beats plus one recheck rep.

No repair-intent behavior, routing logic, localization, geometry, commerce, screenshots, or unrelated content was changed.

## 8. Tests updated, if any

Updated only First Table Guide assertions in `test/ui_v2/act0_shell_preview_screen_v1_test.dart`.

The updated assertions now protect:

- current compact learning-rail ownership;
- the launchable same-signal recheck target;
- the preflop setup read after table scan and recheck;
- compact first-run copy without stale route/surface phrasing.

## 9. Remaining blockers

Expected broad blockers outside this wave:

- theory micro-bite budget;
- Learn selected-panel harness;
- Review/Practice repair-state semantics;
- theory recall / action-trail ownership;
- street-board chronology;
- world-completion retention return copy.

Current post-repair broad failure count is nine:

- `Compact theory rail teaching bodies stay inside one-bite segment budget`
- `Opening a lower lesson auto-scrolls its inline hub into view`
- `Returning to the current lesson from a completed lesson reopens only the target after scroll`
- `Second wrong answer becomes a deeper Review leak`
- `First related seat-tap drill restores the same table targets after recall close`
- `Trail history drill embeds temporal context into the prompt owner`
- `Action trail reveals appended step after state change`
- `Your first hand teaches street board growth in order`
- `World completion seeds compact recheck targets and Home surfaces the return reason`

Fast-loop status:

- `./tools/fast_loop_world1_v1.sh`
- Result after this wave: failed, `+670 -9`
- Lint-tools, analyze, and non-preview selected tests passed; failure remains the broad preview blocker set above.

## 10. Exact next recommended wave

Recommended next wave:

`Theory Micro-Bite Budget Repair v1`

Reason: it is the narrowest remaining product-fix candidate with clear evidence: one known theory segment exceeds the one-bite budget. It is lower risk than repair-state semantics and higher product clarity than harness-only Learn selected-panel cleanup.
