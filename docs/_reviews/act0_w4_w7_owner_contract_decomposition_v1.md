# Act0 W4-W7 Owner Contract Decomposition v1

## Accepted Contract

- W4 = Bet Purpose / Price.
- W5 = Board Awareness.
- W6 = Range Thinking.
- W7 = Visible Cards Change Ranges / range continuation.

## Previous Owner Matrix

| World | Displayed job | Previous lesson owner | Result |
| --- | --- | --- | --- |
| W4 | Bet Purpose / Price | `_preflopFrameworkLessons` | Display correct; owner offset. |
| W5 | Board Awareness | `_betPurposePriceLessons` | Display correct; owner offset. |
| W6 | Range Thinking | `_boardDrawsLessons` | Display correct; owner offset. |
| W7 | Visible Cards Change Ranges | `_rangeThinkingLiteLessons` | Display and owner aligned, but W6 had no distinct primary range owner. |

## Range Classification

| Existing lesson/task group | Current owner | Pedagogical role | Intended world | Reusable without copy change? |
| --- | --- | --- | --- | --- |
| `range_bucket_basics` | W7 via `_rangeThinkingLiteLessons` | Foundational range buckets intro, practice, transfer, review | W6 | Yes |
| `range_board_fit` | W7 via `_rangeThinkingLiteLessons` | Foundational board-fit range practice and review | W6 | Yes |
| `range_pressure_lines` | W7 via `_rangeThinkingLiteLessons` | Foundational value/bluff/missed action direction, transfer, repair, review | W6 | Yes |
| `range_combo_counts` | W7 via `_rangeThinkingLiteLessons` | Combo-density continuation prerequisite | W7 | Yes |
| `range_thinking_checkpoint` | W7 via `_rangeThinkingLiteLessons` | Range continuation review, combo reinforcement, transfer, visible-card/showdown support | W7 | Yes |
| `Act0W7VisibleAceHiddenRuntimeSessionOwnerV1.taskSpecs` | W7 hidden owner specs | Explicit visible-card combo-density continuation decisions and transfer | W7 | Yes, through a route-card adapter using existing spec copy |

## Resolved Owner Definitions

W6 foundational owner:

- Symbol: `_rangeThinkingFoundationLessons`.
- Definition: `range_bucket_basics`, `range_board_fit`, `range_pressure_lines`.
- Sufficiency: includes introductory explanation, real decisions, transfer, repair, and review coverage.

W7 continuation owner:

- Symbol: `_visibleCardRangeContinuationLessons`.
- Definition: `range_combo_counts`, `range_thinking_checkpoint`, `range_thinking_lite_combo_density`.
- Hidden W7 reuse: `range_thinking_lite_combo_density` is composed from `Act0W7VisibleAceHiddenRuntimeSessionOwnerV1.taskSpecs`; the adapter reuses existing spec prompt, choices, feedback, board context, learning purpose, and stable IDs.
- Sufficiency: includes combo-density setup, continuation review/transfer, and explicit visible-card combo-reduction decisions and transfer.

## After Binding Matrix

| World | Lesson owner after repair |
| --- | --- |
| W4 | `_betPurposePriceLessons` |
| W5 | `_boardDrawsLessons` |
| W6 | `_rangeThinkingFoundationLessons` |
| W7 | `_visibleCardRangeContinuationLessons` |

## Preflop Reachability

Preflop Framework was removed from W4 route ownership. Accepted reachability remains through the W3 bridge: `world_3` retains position/preflop source tasks, including first-in, facing-open, frame, and preflop checkpoint language. No Preflop Framework content was deleted.

## Non-Duplication Proof

W6 and W7 route-card lesson IDs are disjoint:

- W6: `range_bucket_basics`, `range_board_fit`, `range_pressure_lines`.
- W7: `range_combo_counts`, `range_thinking_checkpoint`, `range_thinking_lite_combo_density`.

The full `_rangeThinkingLiteLessons` list is not duplicated across W6 and W7.

## Lock State

W7-W12 world-card lock fields remain unchanged: locked status, `isLocked: true`, and `isSelectable: false`. No W13+ world is introduced.

## Files Changed

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `test/ui_v2/act0_w4_w7_owner_contract_decomposition_v1_test.dart`
- `docs/_reviews/act0_w4_w7_owner_contract_decomposition_v1.md`

## Explicit Non-Goals

- No new learner-facing prompts, answers, feedback, or drills.
- No title, subtitle, or unlock-copy rewrite for W4-W7 world cards.
- No visual, mascot, Modern Table, screenshot, telemetry, monetization, W11/W12, W13+, archive, or generated-output work.
- No push.

## Validation

Passed:

- `flutter test test/ui_v2/act0_w4_w7_owner_contract_decomposition_v1_test.dart`
- `flutter test test/ui_v2/act0_w4_w6_title_runtime_normalization_pr1_test.dart`
- `flutter test test/guards/w7_w10_route_status_alignment_contract_test.dart`
- `flutter test test/ui_v2/act0_w7_visible_ace_hidden_runtime_session_owner_v1_test.dart`
- `flutter test test/guards/w12_volume_i_admission_policy_contract_test.dart`
- `flutter analyze`
- `git diff --check`
- `graphify hook-check`

Scope checks:

- Changed files are limited to one Act0 shell production file, one focused test file, and this review artifact.
- No content packs, assets, screenshots, generated outputs, mascot, Modern Table, telemetry, monetization, W11/W12, or W13+ files changed.
- W6 and W7 route-card lesson IDs are disjoint.
- Existing W4-W7 world-card titles, subtitles, and unlock copy are preserved.
- No new prompt, answer, feedback, or drill copy was authored; W7 route-card visible-card material is composed from existing hidden owner specs.
