# Practice Queue Target Launch Audit v1

## 1. Verdict

practice_queue_active_repair_launch_proven

## 2. Active repair launch path proven

A focused Act0 shell test now creates a real active repair intent by answering `fold` on `actions_legal_context`, opens Practice, finds the Repair queue CTA, taps `Practice this`, and verifies the shell selected task becomes `actions_check_drill`.

## 3. Test fixture/source ownership

The fixture uses the existing `act0_repair_intent_resolver_v1_test.dart` Act0 shell harness.

Source ownership remains unchanged:

- active repair source: `Act0RepairIntentV1`;
- launch metadata source: `Act0PracticeRepairQueueProjectionV1`;
- consumer/view model: `Act0PracticeRepairQueueConsumerV1`;
- shell launch path: existing Act0 world/lesson/task handling.

## 4. Target assertion result

The test asserts the active repair intent owns:

- `targetWorldId: world_1`
- `targetLessonId: fold_check_call_raise`
- `targetTaskId: actions_check_drill`

After tapping `Practice this`, `debugSelectedTaskIdV1()` reports `actions_check_drill`.

## 5. History-row passive proof

History/passive row behavior remains covered by the focused Practice shell tests:

- passive rows do not render `Practice this`;
- history rows do not expose target IDs through the launch contract.

No history-row launch behavior was added in this PR.

## 6. Resolution-state boundary

The launch audit test verifies the active repair intent payload remains present after CTA launch.

The CTA does not remove the queue item, mark it fixed, cleared, resolved, completed, or mutate Review history resolution state.

## 7. Route/progression/telemetry boundary

No product code changed in this PR.

No new route family, route truth, progression mutation, telemetry call site, or drill engine behavior was added.

## 8. Forbidden-copy proof

The queue-scoped CTA copy remains `Practice this`.

The new audit test checks the Repair queue section for forbidden CTA/result families: fix, clear, resolve, complete, and leak.

## 9. Fixes, if any

No product blocker fix was required.

The only adjustment during the proof was scoping the test assertion away from unrelated pre-existing Practice copy that contains `Fix`.

## 10. Tests / validation

Focused test added:

- `Practice queue CTA launches mapped active repair target`

Validation run:

- `flutter test test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed test/ui_v2/act0_repair_intent_resolver_v1_test.dart` - passed.
- `git diff --check` - passed.
- `git status --short` - only intended test/review changes plus generated output directories.

Screenshot commands were not run because no visible UI changed in this audit PR.

## 11. Next recommended PR

Practice Queue CTA polish can wait. The safer next PR is a route/progression audit note confirming whether `practice_repair_queue` should keep using the existing evidence run metadata or stay as-is until broader telemetry/evidence policy is reopened.
