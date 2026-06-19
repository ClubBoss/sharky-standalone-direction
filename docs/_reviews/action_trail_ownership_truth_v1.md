# Action-Trail Ownership Truth v1

## 1. Current broad status

Starting status from the previous closure artifact:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: failed, `+653 -3`

After this wave:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: failed, `+655 -1`
- Remaining failure: `World completion seeds compact recheck targets and Home surfaces the return reason`

This wave targets only the two Action-Trail failures:

1. `Trail history drill embeds temporal context into the prompt owner`
2. `Action trail reveals appended step after state change`

The world-completion retention return-copy blocker is intentionally out of scope.

## 2. Action-Trail failure inventory

| failure | expected | observed before this wave | owner |
|---|---|---|---|
| `Trail history drill embeds temporal context into the prompt owner` | text `Read what happened`; context line with current street and previous-action street | prompt surface mounted, but `Read what happened` was absent | `_ActionPromptPanelV1` plus `act0RuntimeTrailTaskLabelV1` |
| `Action trail reveals appended step after state change` | key `act0_shell_action_trail_step_2` after prefix action-trail list grows from two to three items | compact harness did not mount the replay trail in that fixture | `_ActionTrailV1` replay rendering plus test harness viewport |

## 3. Prompt owner decision: A

Old `Read what happened` text is still correct product truth.

Evidence:

- `act0RuntimeTrailTaskLabelV1` still returns `Read what happened`.
- `_resolveRunnerBottomContextV1` still classifies trail-history drills and passes that task label to the prompt owner.
- The failure came from `_ActionPromptPanelV1` suppressing the task label when the integrated trail-history prompt inherited compact decision mode.

## 4. Appended-step decision: C

The test harness failed to trigger the mounted replay owner.

Evidence:

- `_ActionTrailV1` already supports prefix-growth reveal for appended action-trail items.
- The existing compact replay attribution test already proves `act0_shell_action_trail_step_2` can render in a compact replay state when the trail owner is mounted.
- The failing test used a compact fixed-lower-slot fixture where the action trail is intentionally not mounted, so it was testing envelope suppression rather than appended-step reveal.

## 5. Rationale

Action history is a table clue. The learner-facing prompt should name the job before asking which prior action happened last, and the deterministic prompt context should keep the current street and prior action street visible.

For appended steps, the product truth is that replay action-trail rows can reveal new steps when the source trail grows. That should be tested in a fixture where the replay trail is actually mounted. This wave does not change compact runner geometry or force the trail into a fixed lower-slot layout.

## 6. Changes applied

Product fix:

- `_ActionPromptPanelV1` now disables compact prompt-header suppression when `embedChildInSurface` is true, preserving the trail-history task label and context line inside the integrated prompt surface.

Test harness fix:

- The appended-step state-change test now uses the tall runner harness, so it exercises `_ActionTrailV1` replay reveal instead of the compact fixed-lower-slot envelope.

## 7. Tests updated, if any

Updated:

- `Action trail reveals appended step after state change`

The assertion remains the same: `act0_shell_action_trail_step_2` must appear after the action-trail list grows.

## 8. Remaining blockers

Still blocked outside this wave:

- `World completion seeds compact recheck targets and Home surfaces the return reason`

Reason:

- Retention return-copy truth is not part of Action-Trail ownership.
- The expected copy `Still yours? Run this spot once more.` still needs a separate product-contract decision.

## 9. Exact next recommended wave

`World-Completion Retention Return-Copy Contract v1`

Goal:

- Decide whether Home should keep the newer return copy or restore/share the older Review aged-recheck copy, then update the smallest product/test contract accordingly.
