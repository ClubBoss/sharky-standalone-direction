# Act0 Rule-Based Repair Visible Reason Surface v1

Date: 2026-06-19
Branch: `codex/act0-rule-based-repair-visible-reason-surface-v1`
Base commit: `5ccf702`
Mode: bounded product implementation

## 1. Files Inspected

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/ai_personalization_rule_based_repair_v1.md`
- `docs/_reviews/act0_rule_based_repair_runtime_consumption_v1.md`
- `docs/_reviews/act0_rule_based_repair_telemetry_truth_v1.md`
- `lib/ui_v2/act0_shell/act0_rule_based_repair_personalization_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`

## 2. Files Changed

- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `docs/_reviews/act0_rule_based_repair_visible_reason_surface_v1.md`

## 3. Existing Seam Used

The visible reason uses the existing deterministic next-useful-hand seam:

- `_learningRecommendation(...)`
- `_nextUsefulHandReasonReceiptV1(...)`
- `_Act0NextUsefulHandCopyBridgeV1.fromReceipt(...)`
- `act0RepairIntentCopyGuardLineV1(...)`

No new route, screen, telemetry owner, persistence owner, or copy owner was
created.

## 4. Visible Behavior Added

### Same-Signal Repair

When the next-useful-hand receipt resolves from an open mapped repair intent,
Home's existing next-useful-hand line can now show the guarded same-clue reason:

`You missed No bet yet. This hand repairs the same clue.`

This communicates the missed table signal and why the selected hand is useful.

### Exact Replay

When the mapped target is unavailable and the receipt resolves to exact replay,
Home's existing next-useful-hand line can now show the guarded replay reason:

`Replay this spot to fix No bet yet.`

This does not claim same-signal transfer or generalization.

### No Decision

When there is no open repair decision, Home keeps the existing generic line:

`Sharky has your next useful hand ready.`

Correct answers and closed/missing intents do not create visible repair reason
copy.

## 5. Copy Safety

Visible repair copy is still generated only through
`act0RepairIntentCopyGuardLineV1(...)`.

The tested visible reason copy excludes:

- AI / ML / adaptive claims;
- GTO / solver / optimal / win-rate claims;
- guarantee claims;
- premium / paywall / trial / purchase / restore / unlock claims.

## 6. Telemetry Safety

No telemetry event names, payload owners, network calls, vendor SDKs, or
analytics dashboards were added.

Existing `user_choice` before `task_result` telemetry truth remains covered by
`test/ui_v2/act0_telemetry_sink_v1_test.dart`.

## 7. What Was Intentionally Not Changed

- No new route.
- No Modern Table visual work.
- No table geometry changes.
- No commerce, premium, paywall, pricing, purchase, restore, trial, or Premium
  Hub work.
- No Repair Result Receipt.
- No Session Repair Summary.
- No dashboard.
- No content expansion.
- No generated outputs.
- No workflow changes.
- No `external_competitors/` changes.

## 8. Tests / Checks Run

TDD red:

- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --reporter expanded`
  failed because Home did not expose the mapped/exact visible reason yet.

Focused green:

- `dart format lib/ui_v2/act0_shell/act0_home_shell_v1.dart lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --reporter expanded`
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart test/ui_v2/act0_telemetry_sink_v1_test.dart --reporter expanded`

Final verification:

- `flutter analyze`: passed.
- `git diff --check`: passed.
- `./tools/fast_loop_world1_v1.sh`: passed, FAST LOOP PASS.
- `./tools/release_gate_world1.sh`: passed, World1 release gate passed.

## 9. PR Readiness Verdict

Ready for PR.

The implementation is bounded to the existing Act0 next-useful-hand / Home line
surface and uses the existing guarded repair copy bridge.

## 10. Exact Next Wave

`Repair Result Receipt v1`
