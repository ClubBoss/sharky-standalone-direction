# Feedback Dock Allocation — Option A v1

Terminal verdict: `option_a_feedback_dock_allocation_landed_wrong_feedback_and_repair_focus_now_use_a_smaller_fixed_repair_learning_dock_with_receded_table_context_controls_preserved`

## Boundary and change set

- Branch / HEAD before: `claude/hub-surface-coherence-audit-plan-v1` /
  `383cd7a6`.
- Branch / HEAD after: the implementation commit containing this artifact.
- Audit option implemented: **A — wrong feedback + repair focus shared compact
  allocation fix only**.
- Changed product file:
  `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`.
- Changed focused guards/tests:
  `test/guards/feedback_repair_session_closure_hierarchy_gate_v1_test.dart` and
  `test/ui_v2/feedback_dock_allocation_option_a_v1_test.dart`.

## Allocation contract

Before, any fixed compact review envelope used the general 365--405 px lower
slot (or repair-fill allocation), including short wrong/repair-focus feedback
cards. The intrinsic card therefore left the unused portion below its CTA.

After, only non-rapid review feedback that is either wrong or has a non-empty
repair-focus reason selects `compactRepairFeedbackDock`. That owner reserves a
280--320 px lower slot with a maximum 44% share. It is an allocation rule at
the runner-envelope boundary, not a card-height or spacer patch. The dock
retains its existing scroll and safe-bottom behavior, so longer feedback can
grow and scroll instead of clipping.

Repair focus now shares table recession (`0.68`) with wrong feedback. This is
intentional: both are repair-learning moments where the table remains readable
context, while the lower feedback card and its next action are the active
learner focus. Correct feedback and repair result do not select this mode.

## Protected states

- Correct feedback: retains existing envelope and full table context.
- Repair result: retains existing receipt/proof layout and envelope.
- Decision: does not enter review feedback mode; compact answer-list geometry
  remains unchanged.
- Long feedback: keeps `_RunnerActionDockV1`'s scrollable fixed-envelope body.
- CTA/safe area: the existing review fixed-slot bottom protection remains in
  force; no CTA copy or navigation behavior changed.

## Validation and compact evidence

- `flutter test test/guards/feedback_repair_session_closure_hierarchy_gate_v1_test.dart test/ui_v2/feedback_dock_allocation_option_a_v1_test.dart test/ui_v2/compact_decision_lower_slot_rebalance_v1_test.dart` — passed (5 tests).
- `./tools/screen_review_fast_v1.sh first_week compact` — passed; its real-text
  repair lifecycle repaired 11 labels.
- `flutter analyze`, `git diff --check`, `git diff --cached --check`, and
  `graphify hook-check` are required final checks for this change.

Evidence is local-only and unstaged:

- Folder: `output/screen_review/current/first_week_fast/`
- Contact sheet:
  `output/screen_review/current/first_week_fast/contact_sheet.png`
- State images: `compact.wrong_feedback.png`, `compact.repair_focus.png`,
  `compact.correct_feedback.png`, `compact.repair_result.png`, and
  `compact.decision.png`
- Local zip: `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Before/after assessment: the prior C2 captures showed a substantial unused
band below wrong-feedback and repair-focus CTA. The fresh compact captures show
the shorter reserved dock bringing each CTA materially nearer its dock bottom,
without an intervening table/dock gap or visible final-CTA clipping. The repair
focus table is now visually secondary to its gold repair card. Correct, repair
result, and decision remain readable controls in the same lane.

## Remaining debt

- Session summary scroll/safe-area remains a separate micro-wave.
- Session repair still has an evidence gap.
- `TERM-010` no-W13 chip copy fit remains separate.
- Sharky final gate is externally paused; motion is later.

## Non-claims

No 10/10, public-readiness, Human-QA-readiness, or tablet-quality claim is
made. No route, progression, telemetry, Sharky asset, W13+, motion, tablet,
or table redesign change is included.
