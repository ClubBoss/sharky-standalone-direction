# Act0 Shell Preview Contract Refresh v1

Date: 2026-06-18
Mode: broad preview contract triage, docs-only refresh
Scope: `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## 1. Wave Admission

Admitted as a bounded contract-triage wave for the broad Act0 shell preview
suite after accumulated surface drift.

No product code, UI/copy, routes, telemetry, persistence, commerce,
entitlement, premium/trial/paywall surfaces, screenshot tooling, table
geometry, localization files, or content files were changed.

The suite currently fails too broadly for a safe in-wave contract rewrite:
`flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
reproduced `+570 -86`.

## 2. Evidence Reviewed

- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`
- `test/ui_v2/act0_repair_intent_contract_v1_test.dart`
- `test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- `docs/_reviews/ai_personalization_rule_based_repair_discovery_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`

## 3. Failure Inventory Grouped by Surface

Authoritative suite result: 86 failures.
Unique extracted failure descriptions: 81.

### Home

- `Home shell shows Poker from Zero with compact activated route strip`
- `Home stays route-first before checklist activation`
- `Activated Home does not duplicate the current lesson across hero focus and Learn row`
- `Home support copy prefers wrapped density over hard truncation`
- `Home shows full soft daily mix when continue repair recheck and prove are all available`
- `Home shows recheck job when agedRecheck exists`
- `Home shows prove job when ownedCandidate exists`
- `Home shows keep-sharp job after prove threshold is met`
- `Home fix row keeps compact multi-line density for long copy`
- `Home surfaces new W1 live-table transfer as a recheck job when retention memory points at it`
- `Home surfaces new W4 purpose-price transfer as a recheck job when retention memory points at it`
- `Home surfaces new W5 transfer variant as a recheck job when retention memory points at it`
- `Home surfaces new W5 flush recheck transfer when retention memory points at it`
- `Home surfaces new W5 outs transfer as a recheck job when retention memory points at it`
- `Home surfaces new W6 transfer variant as a recheck job when retention memory points at it`
- `Home focus row shows Practice now when goal not done`
- `Tapping daily focus row from fresh Home starts daily practice`
- `Home daily goal card pivots to weak-spot repair when needed`
- `Hot restart restore ignores runner resume and lands on Home`
- `World completion seeds compact recheck targets and Home surfaces the return reason`

Classification: stale assertions and ambiguous Home contract drift. The first
failure expects `Active world: Poker from Zero`; current Home ownership appears
mission-card/checklist based, and several expected keys still exist in the
component but are gated by state, checklist activation, or route context.

### Learn

- `Expanded lesson panel shows primary CTA and tapping it launches runner`
- `Selected lesson panel keeps compact subtitle headroom and guidance strip`
- `Opening a lower lesson auto-scrolls its inline hub into view`
- `Returning to the current lesson from a completed lesson reopens only the target after scroll`
- `Completing current lesson unlocks the next lesson`
- `Runner Review Continue advances to next task when available`
- `Bottom nav switches tabs`
- `Levels menu is separate and keeps Level 1 selected with locked levels gated`
- `First Table Guide stays compact at five steps or fewer`
- `Fresh ready-for-basics placement still starts with First Table Guide`
- `Existing progressed users are not forced back into First Table Guide`

Classification: stale assertions plus test harness drift. The current lesson
hub still owns `act0_shell_selected_lesson_panel`, but failures show route
state or scroll/opening assumptions no longer line up. `First Table Guide`
currently includes six visible step rows because `what_poker_is_table_read_recheck`
is present, making the five-step expectation stale unless product explicitly
reverts that density.

### Profile

- `Placement seeds poker skill stats into Profile`
- `Profile earned achievement unlocks after first task and streak stat appears`
- `Correct answer adds a recent skill gain to Profile`
- `Representative Play packs feed matching skill families into Profile`
- `Skill gains and profile skill stats survive a fresh dev shell mount`
- `Profile compact recent-progress stack keeps one light summary above payoff rows`
- `Profile ties progress, identity, focus, and strengths into one story`
- `Profile keeps next focus above deeper identity support`
- `Profile groups next focus and recent progress into one wide support band`
- `Profile keeps identity support below rhythm so the first story stays focused`
- `Profile payoff card shows improved fixed and return-value lines without scar language`
- `Profile recent progress keeps one dominant proof before support detail`
- `Profile recent gains dedupe repeated labels in display`
- `Profile recommended focus returns the user to Home`
- `Profile shows stronger learner-progress payoff without turning into a dashboard`
- `Profile keeps deeper skill detail behind a view-all affordance`
- `Profile identity and focus prefer wrapped density over hard truncation`

Classification: stale assertions and test harness drift. The profile component
still contains the major keys, but failures cluster around scroll/lazy visibility,
duplicate text counts, and recent-progress/focus support expectations.

### Review

- `Review and Profile shells feel app-like and avoid taxonomy`
- `Review surfaces a dominant repair pattern when evidence repeats`
- `Review frames an open repair as part of Week 1`
- `Review repaired state keeps calm proof without debug language`
- `Review resurfaces open mistake regardless of lesson context`
- `Review action trail keeps replay controls without pot sweep on review`
- `Quick fix card can replay the repaired spot`
- `Clean repair closes the loop in Review without a permanent scar`
- `Second wrong answer becomes a deeper Review leak`
- `Weekly focus uses open repair concept when available`
- `Weekly focus uses aged recheck concept when no open repair exists`
- `Review-launched exact repair replay keeps theory recall available on the reopened drill`
- `Review-launched mapped repair keeps theory recall available on the reopened drill`
- `Review-launched W1 matched-chips replay keeps theory recall available on the reopened drill`
- `Review-launched W8 side-pot replay keeps theory recall available on the reopened drill`

Classification: mixed stale assertions and ambiguous product contract drift.
`Act0ReviewShellV1` still owns `act0_shell_review_pattern_card` and support-line
keys, but broad host/tab tests fail to reach the expected state. Direct shell
expectations need a separate review-surface refresh before implementation
changes are justified.

### Welcome and Placement

- `Welcome compresses to two beats before first lesson handoff`
- `Welcome intro beat localizes cleanly in Russian`
- `Placement first diagnostic keeps table visible on compact portrait`
- `Placement answer-list feedback inherits stable table viewport`
- `Placement seeds poker skill stats into Profile`
- `Fresh ready-for-basics placement still starts with First Table Guide`

Classification: ambiguous product decision plus geometry/test-harness drift.
The failures touch onboarding count/copy, placement diagnostic option flow, and
compact viewport budgets. These are explicitly outside a small test-expectation
refresh because they can change the first-run product contract.

### Compact Geometry and Runner

- `Live compact portrait runner prioritizes table and readable rail`
- `Compact action prompt makes the main question the dominant left-aligned line`
- `Compact stacked long options get extra readable height`
- `Refined compact runner review keeps feedback hierarchy calm`
- `Canonical detached shell shows teaching prompt during drill teaching states`
- `Canonical detached shell keeps theory guidance in one place and readable suits`
- `Canonical detached shell keeps drill guidance below the table only`
- `Compact table-reading theory keeps the table-first learning rail model`
- `Compact non-visual W1-W3 theory avoids article chrome and stays rail-anchored`
- `Inside-lesson retry keeps theory recall available for the retried drill`
- `First related action drill shows a read-only theory recall affordance`
- `Action trail reveals appended step after state change`
- `Review action trail keeps replay controls without pot sweep on review`
- `Trail history drill embeds temporal context into the prompt owner`

Classification: real possible regressions or stale geometry budgets, but not
safe for this wave. The user explicitly forbids table geometry and broad visual
polish changes, so these require a separate compact-runner contract wave.

### Localization

- `Welcome intro beat localizes cleanly in Russian`
- `Profile first-start tools move behind a compact utility entry and localize cleanly in Russian`
- `Profile consistency card localizes momentum copy and keeps headroom in Russian`
- `Review board localizes clean-state guidance and keeps support headroom in Russian`

Classification: localization contract drift. The current wave forbids
localization-file changes and broad copy rewrites, so these remain deferred.

### Content Chronology

- `First Table Guide stays compact at five steps or fewer`
- `Fresh ready-for-basics placement still starts with First Table Guide`
- `Existing progressed users are not forced back into First Table Guide`

Classification: product decision required. Current code includes the
`what_poker_is_table_read_recheck` step in the First Table Guide visible hub.
Changing the test or product without explicit route/content authority would
reopen content chronology.

## 4. Classification Summary

The 86 failures are not a repair-intent regression cluster.

The dominant classes are:

- stale broad preview expectations after surface drift;
- host/tab/test-harness drift where direct widgets still own expected keys;
- ambiguous first-run/content chronology decisions;
- compact geometry budgets outside this wave's allowed surface;
- localization copy/count expectations outside this wave's allowed surface.

No tiny implementation fix was proven safe. Updating the broad suite in-place
would require a large assertion rewrite across multiple surfaces and product
contracts, which exceeds the requested bounded refresh.

## 5. Fixes Applied

Docs-only inventory artifact added:

- `docs/_reviews/act0_shell_preview_contract_refresh_v1.md`

No executable code or tests were changed.

## 6. Verification

Commands run:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
  - Result: failed, `+570 -86`
- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart --reporter compact`
  - Result: passed
- `flutter test test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart --reporter compact`
  - Result: passed
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --reporter compact`
  - Result: passed
- `flutter test test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart --reporter compact`
  - Result: passed
- `./tools/fast_loop_world1_v1.sh`
  - Result: failed on `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - Tools lint passed
  - `flutter analyze` passed inside the loop
- `git diff --check`
  - Result: passed before this artifact was added

## 7. Recommended Next Wave

`Act0 Shell Preview Contract Split v1`

Recommended bounded scope:

1. Split broad preview assertions by owner surface.
2. Start with Home + Learn only.
3. For each failing assertion, decide one of:
   - update stale expectation to current authoritative behavior;
   - add a smaller direct-widget test if the broad host path is the stale part;
   - leave as product-decision blocker.
4. Do not touch compact geometry, localization, content chronology, commerce,
   premium/trial/paywall, screenshots, or repair-intent behavior in that wave.
