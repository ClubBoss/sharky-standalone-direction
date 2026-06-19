# Feedback Proof Lane Stabilization v1

## Wave Admission

Admitted as bounded proof-lane stabilization. The change adds a named debug/capture-only first-wrong feedback state and focused tests. It does not change feedback copy, hierarchy, table geometry, scoring, telemetry, commerce, localization, normal routes, or screenshot tooling.

## PIEC Findings

Existing capture states:

- `runner_first_correct_feedback` already existed and seeded `world_1 / fold_check_call_raise / actions_check_drill` directly into review with the correct `Check` option selected.
- `runner_feedback` existed as a generic review-state surface, but it defaulted to `what_poker_is_theory` unless the debug harness entry carried explicit task ids.

Wrong proof blocker:

- The attempted URL used `act0_capture=runner_feedback&world=world_1&lesson=fold_check_call_raise&task=actions_check_drill&locale=en`.
- The parser does not attach `world/lesson/task` ids for `runner_feedback`, so this was not a stable targeted first-wrong proof seam.
- Browser screenshot attempts then failed around the accessibility/capture path, but the root product issue was the missing named wrong-feedback state.

Selected proof seam:

- Add `runner_first_wrong_feedback` as a direct debug/capture surface.
- Seed the same first No-bet task as the correct proof lane.
- Select the first existing wrong option from that task.

Selected file set:

- `lib/ui_v2/app_root.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## Decision

Implemented.

## Proof Lane Behavior

The new wrong proof state uses existing Act0 task/content metadata only:

- world: `world_1`
- lesson: `fold_check_call_raise`
- task: `actions_check_drill`
- selected option quality: `wrong`
- visible verdict: `Not quite`
- table signal: `No bet yet`

Normal user routes are unaffected because the state is only reachable through the existing `act0_capture` debug/proof parser.

## Stable Feedback Proof URLs

- Correct: `http://127.0.0.1:7357/?act0_capture=runner_first_correct_feedback&locale=en`
- Wrong: `http://127.0.0.1:7357/?act0_capture=runner_first_wrong_feedback&locale=en`

Suboptimal was not added. The first No-bet task has correct and wrong branches only; adding a first-suboptimal proof URL would require choosing a different task and would broaden the wave.

## Tests Added / Updated

- Parser test now accepts `runner_first_wrong_feedback` as a named safe capture surface.
- Existing first-correct debug capture test remains green and still verifies `Good read`.
- New first-wrong debug capture test verifies:
  - runner feedback state opens directly;
  - `Not quite` renders;
  - missed clue copy points to `No bet yet`;
  - signal proof label is `No bet yet`;
  - placement is not visible.

## Optional Screenshot Inventory

| State | URL | Screenshot |
| --- | --- | --- |
| First correct feedback | `?act0_capture=runner_first_correct_feedback&locale=en` | `output/playwright/feedback_proof_lane_stabilization_v1/first_correct_feedback_compact_en.png` |
| First wrong feedback | `?act0_capture=runner_first_wrong_feedback&locale=en` | `output/playwright/feedback_proof_lane_stabilization_v1/first_wrong_feedback_compact_en.png` |

## Remaining Risks

- The in-app browser screenshot path still needed an accessibility-gate retry and returned JPEG bytes that were normalized to PNG afterward. That is capture friction, not a product route blocker.
- Correct and wrong verdict labels are both readable but still visually quieter than the action result line; this belongs to a separate feedback hierarchy wave if the team wants a stronger commercial proof moment.

## Direction Score

8.7/10.

The missing wrong-feedback proof seam is now closed, and the next wave can judge correct and wrong feedback together from complete compact English evidence.

## Recommended Next Arc

Run `Feedback Verdict Hierarchy v1` if the product bar requires the verdict to lead more strongly than `Best play / Better option`.

If the current hierarchy is acceptable, proceed to `Final First-Week Commercial Proof Packet v1`.

