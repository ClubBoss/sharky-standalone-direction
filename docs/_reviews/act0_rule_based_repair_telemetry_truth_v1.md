# Act0 Rule-Based Repair Telemetry Truth Alignment v1

Date: 2026-06-19
Branch: `codex/act0-rule-based-repair-telemetry-truth-v1`
Base commit: `e687470`
Mode: bounded telemetry truth alignment

## 1. Product Goal

Align Act0 local telemetry truth for the deterministic rule-based repair loop
before adding any visible repair feedback or session summary surface.

This wave keeps telemetry local, deterministic, and owned by the existing Act0
runner/shell seams. It does not add analytics infrastructure, vendor telemetry,
network calls, user identity payloads, commerce payloads, public copy, or UI.

## 2. Root Cause of Telemetry Test Drift

`test/ui_v2/act0_telemetry_sink_v1_test.dart` failed on clean main for two
separate reasons.

1. The repair flow assertion was stale about event ordering. Current runtime
   emits both the older aggregate `repair_completed` event and the current repair
   item lifecycle `repair_item_completed` event. The item lifecycle event is
   emitted last and is covered elsewhere in the broad Act0 preview suite.
2. The non-blocking completion test asserted stale visible copy:
   `Daily set complete`. That made a telemetry resilience test depend on copy
   that is no longer the stable contract. The stable behavior is that a throwing
   telemetry sink does not block the learner from returning to the Play surface.

A real narrow contract gap also existed: `task_result` carried `choiceId`,
`result`, and `errorType`, but the active Act0 runner did not emit the
truth-map `user_choice` event or `decisionTimeBucket`.

## 3. Current Telemetry Owner

Telemetry ownership remains split by existing product ownership:

- `Act0LessonRunnerShellV1` owns task exposure, answer choice, answer result,
  and feedback-viewed runner events.
- `Act0ShellPreviewScreenV1` owns route, repair, practice, recheck, prove, and
  completion-loop events.
- `Act0TelemetrySinkV1` remains the local sink interface.

No duplicate owner was added.

## 4. Required Telemetry Concepts Status

| Concept | Status |
| --- | --- |
| `user_choice` | Now emitted by `Act0LessonRunnerShellV1` when an answer option is selected. |
| `choiceId` | Preserved on `user_choice` and `task_result`. |
| `correct` / correctness | Preserved as `result: correct` / `result: incorrect` on `task_result`; repair item lifecycle also carries `correct`. |
| `error_type` / `errorType` | Preserved on `task_result`; incorrect runner results currently use controlled fallback `unknown`. |
| `time_to_decision` equivalent | Represented as `decisionTimeBucket` on `user_choice`; no exact timestamps or raw milliseconds are emitted. |

## 5. Contracts Changed / Unchanged

Changed:

- `Act0LessonRunnerShellV1` now emits local `user_choice` telemetry before
  `task_result`.
- `user_choice` payload contains only stable, privacy-safe fields:
  - `schemaVersion`
  - `worldId`
  - `lessonId`
  - `taskId`
  - `choiceId`
  - `decisionTimeBucket`
  - `attemptOrdinal`
- `act0_telemetry_sink_v1_test.dart` now asserts current repair event ordering
  and route-survival behavior instead of stale copy.

Unchanged:

- `task_result` payload shape.
- `repair_started`, `repair_completed`, `repair_item_completed`,
  `practice_completed`, `recheck_completed`, and `prove_completed` emission
  owners.
- Public UI and copy.
- Route truth.
- Persistence.
- Commerce / premium / trial / paywall behavior.

## 6. Repair Decision Telemetry / Link Status

No repair-decision analytics emission was added.

`Act0RuleBasedRepairDecisionV1` remains available through the private
next-useful-hand runtime receipt/debug payload from the previous wave. Linking
that decision into telemetry should stay deferred until a separate event contract
explicitly decides the privacy-safe fields and owner.

## 7. Files Changed

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`
- `docs/_reviews/act0_rule_based_repair_telemetry_truth_v1.md`

## 8. What Was Intentionally Not Done

- No new analytics system.
- No network telemetry.
- No vendor SDK.
- No user identity, profile, email, device, or hand-history payloads.
- No visible UI or copy changes.
- No Modern Table visual work.
- No public commerce, paywall, pricing, trial, purchase, restore, entitlement,
  or Premium Hub work.
- No generated outputs.
- No workflow edits.
- No `external_competitors/` changes.

## 9. Risk Assessment

Risk: low.

Reason:

- The runtime change is additive and local to the existing runner telemetry
  owner.
- `user_choice` emits only stable IDs and a coarse timing bucket.
- Existing result, feedback, repair, practice, recheck, and prove telemetry
  contracts remain intact.
- Throwing telemetry sinks remain non-blocking.

## 10. Checks Run

TDD red:

- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart`
  - failed because `user_choice` was not emitted.

Initial green:

- `dart format lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart test/ui_v2/act0_telemetry_sink_v1_test.dart`
- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart`

Full branch verification:

- `git diff --name-only`
- `git diff --stat`
- `git diff --check`
- `flutter analyze`
- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
- `./tools/fast_loop_world1_v1.sh`
  - `FAST LOOP PASS`
- `./tools/release_gate_world1.sh`
  - `World1 release gate passed`

## 11. PR Readiness Verdict

Ready for PR.

If gates pass, this is a clean telemetry truth alignment PR: one additive local
runner event, stale test contract refresh, and this review artifact.

## 12. Follow-Up Recommendation

Next exact wave:

`Act0 Rule-Based Repair Visible Reason Surface v1`

Scope:

- consume the existing private repair decision / reason receipt only where a
  current surface already has a safe reason slot;
- do not add new telemetry ownership;
- do not add AI/ML claims, session summary, or commerce behavior.
