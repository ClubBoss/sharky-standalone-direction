# Wave 3.1 - Street Replay / How We Got Here v1

## 1. Verdict

wave3_1_street_replay_how_we_got_here_ready

## 2. TOP1 matrix row target

Primary:

- street context / how-we-got-here comprehension

Secondary:

- table/session core
- first proof loop
- Practice usefulness
- Review coaching depth
- premium learning clarity

## 3. Wave goal and scope

Goal: help the learner understand how the current multi-street decision arrived at the visible spot without turning the product into a hand-history archive or analytics surface.

Scope stayed inside the active Act0 lesson runner. The wave adds a compact `How we got here` entry point, a structured street timeline bottom sheet, and a deterministic replay contract derived from existing table/action-trail state.

## 4. Benchmark notes

Runout pattern reviewed:

- table remains dominant;
- a compact history/context entry opens a bottom sheet;
- context explains preflop/flop/turn/river flow;
- narrative context is on demand instead of always visible.

What Sharky copies conceptually:

- on-demand context instead of table overload;
- bottom-sheet continuity from the active decision screen;
- street-by-street explanation of how the decision was reached.

What Sharky improves:

- structured scan rows instead of a paragraph wall;
- explicit `You are here` marker on the current street;
- compact `Decision context` and `Key clue` blocks when source-owned data exists;
- beginner-safe `How we got here` copy instead of generic archive language.

What Sharky avoids:

- no Action History clone;
- no hand-history archive;
- no tracker/log/dashboard framing;
- no solver/GTO line;
- no replay playback controls in this wave.

## 5. Files changed

- `lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `test/ui_v2/act0_street_replay_contract_v1_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/wave3_1_street_replay_how_we_got_here_v1.md`

## 6. Existing replay/street/action seed audit

Existing safe seeds found:

- `Act0TableStateV1.streetLabel`
- `Act0TableStateV1.boardCards`
- `Act0TableStateV1.potLabel`
- `Act0TableStateV1.toCallLabel`
- `Act0TableStateV1.centerLabel`
- `Act0TableStateV1.focusCalloutLabel`
- `Act0TableStateV1.actionTrail`
- existing review-only action-trail replay controls in `act0_lesson_runner_shell_v1.dart`

Safe active route seed:

- `world_1` / `your_first_hand` / `your_first_hand_action_trail` carries a real multi-street action trail and river decision context.

Missing or intentionally unused:

- no durable all-time hand database;
- no player tendency model;
- no street animation renderer;
- no pot-by-each-street ledger beyond current source-owned pot label.

The existing action-trail seed is future-animation-safe enough for v1 because it is structured source state, not prebuilt paragraph-only copy.

## 7. Contract or seam implemented/reused

Added `Act0StreetReplayV1` and `Act0StreetReplayStepV1`.

`act0StreetReplayFromTableV1` derives replay steps from `Act0TableStateV1`:

- street order: preflop, flop, turn, river;
- board cards available by street;
- action summaries grouped by street prefixes and active street context;
- current street from `streetLabel`;
- current pot/price context from existing labels;
- key clue from `focusCalloutLabel`;
- decision context from `centerLabel`, `potLabel`, and `toCallLabel`.

If street or action-trail evidence is absent, the contract returns `null`.

## 8. Why the contract is animation-ready

The UI does not render one fixed text blob. It consumes structured replay steps with stable fields:

- `street`
- `boardCardsAtStreet`
- `actionSummary`
- `potAtStreet`
- `isCurrentStreet`
- `compactLabel`

Wave 3.5 can animate the same ordered steps without creating a second model. This wave does not add cards/chips animation, playback state, play/pause controls, a scrubber, or cinematic replay.

## 9. Visible entry point implemented

The active decision panel now shows one compact `How we got here` action when a replay contract exists and the runner is in drill mode. The entry uses key `act0_shell_street_replay_entry`.

The primary answer buttons remain visible and dominant in the same decision panel.

## 10. Bottom sheet / context panel implemented

Tapping `How we got here` opens a modal bottom sheet with key `act0_shell_street_replay_sheet`.

The sheet includes:

- title `How we got here`;
- subtitle `Street by street`;
- ordered street rows;
- current street marker;
- optional `Decision context`;
- optional `Key clue`;
- close button.

No playback toggle, scrubber, animation controls, or route navigation were added.

## 11. Evidence source for each visible replay step

Visible step source:

- street labels derive from `Act0StreetReplayStreetV1`;
- action summaries derive from `Act0TableStateV1.actionTrail`;
- board cards derive from `Act0TableStateV1.boardCards`;
- current street derives from `Act0TableStateV1.streetLabel`;
- current pot derives from `Act0TableStateV1.potLabel`;
- decision context derives from `centerLabel`, `potLabel`, and `toCallLabel`;
- key clue derives from `focusCalloutLabel`.

No fake player tendency, fake price, fake all-time history, or inferred solver line is displayed.

## 12. You are here marker proof

`Act0StreetReplayStepV1.youAreHereLabel` returns `You are here` only for the step where `isCurrentStreet` is true.

Focused tests prove:

- the river step is marked current for a river table state;
- `You are here` appears in the sheet for source-owned street context;
- the replay entry remains hidden when street/action-trail evidence is removed.

## 13. Why this supports learning causality rather than hand-history/product bloat

The feature answers one learner question: how did this decision arrive here?

It uses the current hand context already present in the runner and stays tied to the active decision. It does not add search, archives, filters, all-time logs, analytics, player database, or historical hand browsing.

## 14. Future Wave 3.5 handoff

Wave 3.1 builds:

- replay data contract;
- structured timeline UI;
- source-safe gating;
- current street marker.

Wave 3.5 may build an animated replay renderer over `Act0StreetReplayV1` and `Act0StreetReplayStepV1`.

No duplicate model should be created later. The future animation layer should consume the same ordered steps and preserve the same evidence boundaries.

Intentionally not built now:

- animated cards;
- animated chips;
- action motion;
- playback controls;
- scrubber;
- replay timeline state machine.

## 15. Claim-safety proof

New visible copy avoids:

- AI;
- GTO;
- solver;
- mastery;
- permanent leak fix;
- fixed forever;
- cleared;
- resolved;
- recovered;
- all-time analytics;
- rating;
- radar;
- Level / Lv as proof;
- premium/paywall value;
- guaranteed improvement;
- win-rate improvement.

The focused sheet test scopes forbidden-copy checks to the new replay surface.

## 16. No route/progression/model/telemetry boundary proof

No route family changed. No canonical entry point changed. No progression mutation, telemetry call site, durable storage, queue resolution, Review clearing, repair completion, or model persistence was added.

The only model-like addition is a local deterministic view contract derived from already-present table state.

## 17. No hand-history archive / tracker / analytics boundary proof

The feature is not durable and not browsable. It has no all-time state, no history list, no hand database, no PokerTracker-style labels, no analytics dashboard, no filters, and no long-term counts.

The sheet copy uses `How we got here` and `Street by street`, not tracker/archive language.

## 18. Existing Review CTA / Sharky Soul / earned reward preservation proof if touched

Review, Sharky phrase, and earned reward source files were not modified.

Shared runner/action-trail preservation checks passed:

- existing trail-history prompt owner remains intact;
- existing review action-trail replay controls remain intact;
- appended action-trail state update still works;
- shove amount attribution still works;
- beginner route wording guard remains green.

## 19. Tests and validation run

Passed:

- `flutter test test/ui_v2/act0_street_replay_contract_v1_test.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Street replay|builds deterministic street steps|does not create replay"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Trail history drill embeds temporal context into the prompt owner|Review action trail keeps replay controls without pot sweep on review|Action trail reveals appended step after state change|Action trail replay attributes shove amount to the acting seat|Beginner route learner-facing copy avoids trail wording in the active hand-history seam"`
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart test/ui_v2/act0_street_replay_contract_v1_test.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `flutter analyze`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- `git status --short`

## 20. Screenshot proof run and result

Passed:

- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`

Local packets:

- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

`full_scroll compact` was not run because the implementation is a bounded runner decision-surface change and the required day2/first-week compact packets passed.

## 21. Generated/untracked artifact status

Generated outputs remain local-only and untracked:

- `output/screen_review/`
- `output/claude_review/`

No generated screenshots, zips, or output directories are part of this commit.

## 22. Anti-theater proof

User-visible change:

- a learner can open `How we got here` from a source-owned multi-street decision and inspect preflop/flop/turn/river context in a structured sheet.

Final target requirement moved:

- street context / how-we-got-here comprehension now has a concrete first implementation in the active runner.

Evidence:

- deterministic contract test;
- positive sheet test;
- no-context gating test;
- screenshot packets passed.

Explicitly not built:

- animation;
- hand-history archive;
- tracker/dashboard;
- solver/GTO line;
- route/progression/telemetry/storage changes.

Why this is not fake progress:

- the visible entry is gated by real `Act0TableStateV1` street/action-trail evidence and disappears when that evidence is removed.

## 23. Expected TOP1 matrix movement

Street context / how-we-got-here comprehension:

- meaningful lift; multi-street decisions now have an on-demand causal context surface.

Table/session core:

- modest lift; the table remains dominant while context is accessible from the decision panel.

First proof loop:

- modest lift; the learner can connect prior street flow to current choice before feedback/repair.

Practice usefulness:

- light lift; source-owned replay context can support future repair reps using the same contract.

Review coaching depth:

- light future lift; Review was not changed, but the contract can later support Review context without introducing an archive.

## 24. Caveats

V1 uses current table/action-trail evidence only. It does not have a per-street pot ledger, player tendency source, durable hand history, or animation renderer.

Some existing older trail-history wording remains in older trail tests/surfaces; this wave avoids introducing archive/tracker framing into the new Street Replay sheet.

## 25. Next recommendation

Proceed to Wave 3.2 - First-Week Commercial Proof & Gap Lock. Do not start Wave 3.5 motion until Wave 3.2, Wave 3.3, and Wave 3.4 either pass or produce concrete P0/P1 evidence that changes the route.
