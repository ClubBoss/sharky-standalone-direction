# Theory Micro-Bite Budget Repair v1

## 1. Current broad status

Incoming known broad preview status after First Table Guide Content Decision + Repair v1:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: failed, `+647 -9`
- First Table Guide failures were cleared.
- The remaining theory micro-bite blocker was:
  `Compact theory rail teaching bodies stay inside one-bite segment budget`

## 2. Failing theory micro-bite inventory

Single failing offender:

- Task: `cards_ranks_suits_rank_drill`
- Runner: `_cardsRanksRunner`
- Teaching step: `teachingSteps[1]`
- Segment: `segment 1`
- Failure: compact instruction segment exceeded the word budget.

## 3. Expected vs actual budget

Test budget:

- Words per compact segment: `<= 24`
- Sentences per compact segment: `<= 4`

Actual before repair:

- `29 words`
- `2 sentences`

This was a text-density failure, not a stale key, layout measurement, or visual geometry issue.

## 4. Current segment/copy evidence

Before repair, the full compact segment was:

`The beginner order is 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K, A. Ace is highest for now, so ace beats king in this drill.`

The segment taught two different beginner facts in one compact bite:

- full rank order;
- ace beats king in the current drill.

The instruction block builder already supports explicit paragraph splits with blank lines, so this was a copy segmentation issue.

## 5. Decision selected: A

Selected decision: A. Current theory segment was too dense for one compact bite; product copy/segmentation should be split.

Confidence: high.

## 6. Rationale

The current content was learner-facing and relevant, but it combined two learning jobs in one compact rail segment. Beginner rank order is already a dense ordered list, and the ace-vs-king application is a second idea. Splitting the body into two explicit paragraphs preserves all required content while keeping each compact support segment one-bite.

No evidence supported raising the budget. No evidence showed stale harness ownership or incorrect measurement.

## 7. Changes applied

Changed only `_cardsRanksRunner` teaching copy:

- Kept the exact rank-order sentence.
- Kept the `Ace is highest for now` sentence.
- Added a blank line between them so compact instruction segmentation renders two small bites.

No unrelated content, First Table Guide, street-board chronology, action-trail, repair-state, retention, localization, geometry, commerce, screenshot, or repair-intent behavior was changed.

## 8. Tests updated, if any

No tests were updated.

The existing budget test remains authoritative and continues to protect the one-bite compact theory contract.

## 9. Remaining blockers

Post-repair broad preview status:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: failed, `+648 -8`
- Cleared blocker: `Compact theory rail teaching bodies stay inside one-bite segment budget`

Expected broad blockers outside this wave:

- `Opening a lower lesson auto-scrolls its inline hub into view`
- `Returning to the current lesson from a completed lesson reopens only the target after scroll`
- `Second wrong answer becomes a deeper Review leak`
- `First related seat-tap drill restores the same table targets after recall close`
- `Trail history drill embeds temporal context into the prompt owner`
- `Action trail reveals appended step after state change`
- `Your first hand teaches street board growth in order`
- `World completion seeds compact recheck targets and Home surfaces the return reason`

Fast-loop status after repair:

- `./tools/fast_loop_world1_v1.sh`
- Result: failed, `+671 -8`
- Tool lint, `flutter analyze`, and the selected non-preview tests passed.
- Remaining failures are still inside `test/ui_v2/act0_shell_preview_screen_v1_test.dart`.

## 10. Exact next recommended wave

Recommended next wave:

`Learn Selected-Panel Harness Refresh v1`

Reason: after this micro-bite fix, the next safest bounded blocker family is the two-test Learn selected-panel harness drift. It is likely lower risk than repair-state semantics, action-trail ownership, street chronology, or retention contract work.
