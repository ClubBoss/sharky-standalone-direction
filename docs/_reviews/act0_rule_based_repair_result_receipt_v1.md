# Act0 Rule-Based Repair Result Receipt v1

Date: 2026-06-19
Branch: `codex/act0-rule-based-repair-result-receipt-v1`
Base commit: `7b31fe9`
Mode: bounded product implementation

## 1. Files Inspected

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/act0_rule_based_repair_visible_reason_surface_v1.md`
- `docs/_reviews/act0_repair_reason_copy_normalization_v1.md`
- `docs/_reviews/act0_rule_based_repair_telemetry_truth_v1.md`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`
- `lib/ui_v2/act0_shell/act0_rule_based_repair_personalization_v1.dart`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`

## 2. Files Changed

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `docs/_reviews/act0_rule_based_repair_result_receipt_v1.md`

## 3. Existing Seam Used

The receipt uses the existing Act0 repair attempt lifecycle:

- `_activeRepairTaskId`
- `_activeRepairSourceTaskId`
- `_openRepairIntentBySourceTaskId`
- `_recordAnswer(...)`
- existing feedback rendering in `Act0FeedbackShellV1`

No new route, screen, dashboard, persistence owner, telemetry owner, or network
event was introduced.

## 4. Receipt Behavior Added

### Fixed

When a learner answers correctly on an active mapped repair hand, the existing
feedback card can now show:

`Repair fixed: you caught the no-bet-yet clue.`

This is specific to the repaired signal and does not claim permanent mastery.

### Repeated

When a learner misses the same mapped repair signal again, the existing feedback
card can now show:

`Still missed: nobody had bet yet. One more repair hand will help.`

The line is calm and non-punitive.

### Needs One More Rep

Deferred.

The current state can distinguish fixed and repeated repair attempts. It does
not expose a separate honest fragile/partial-repair state beyond an incorrect
repeat, so this wave does not invent a third result category.

### Exact Replay

When the repair target is exact replay fallback, the receipt avoids same-signal
generalization:

- Correct: `Replay fixed: you handled this spot correctly.`
- Incorrect: `Replay missed again: try the same spot once more.`

### No-Decision Preservation

Normal non-repair feedback keeps existing behavior. No repair result receipt is
shown unless the current runner is the active repair target.

## 5. Copy Safety

Receipt copy is generated through
`act0RepairResultReceiptCopyGuardLineV1(...)`.

Targeted tests cover that visible receipt copy does not contain:

- AI / adaptive
- GTO / solver / optimal
- win-rate / guarantee
- premium / paywall / trial / unlock
- leak detected

## 6. Telemetry Safety

No new telemetry owner, event name, network call, or duplicate task-result event
was added.

Existing local telemetry remains owned by the runner/shell seams. The existing
`user_choice` before `task_result` truth and required payload fields remain
covered by `test/ui_v2/act0_telemetry_sink_v1_test.dart`.

## 7. What Was Intentionally Not Changed

- No route.
- No Modern Table visual work.
- No table geometry change.
- No commerce, premium, paywall, pricing, purchase, restore, trial, or Premium
  Hub work.
- No session summary.
- No proof packet.
- No analytics dashboard.
- No content expansion.
- No generated outputs.
- No workflow changes.
- No `external_competitors/` changes.

## 8. Tests / Checks Run

TDD red:

- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --reporter expanded`
  failed because no fixed/repeated/exact replay repair result receipt was
  rendered yet.

Focused green:

- `dart format lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --reporter expanded`
- `flutter test test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_telemetry_sink_v1_test.dart --reporter expanded`
- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart test/ui_v2/act0_telemetry_sink_v1_test.dart --reporter expanded`

Final verification:

- `flutter analyze`: passed.
- `git diff --check`: passed.
- `./tools/fast_loop_world1_v1.sh`: passed, FAST LOOP PASS.
- `./tools/release_gate_world1.sh`: passed, World1 release gate passed.

## 9. PR Readiness Verdict

Ready for PR.

## 10. Exact Next Wave

`Session Repair Summary v1`
