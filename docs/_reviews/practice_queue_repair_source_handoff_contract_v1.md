# Practice Queue Repair Source Handoff Contract v1

## 1. Verdict

practice_queue_source_handoff_data_ready

## 2. Prior blocker addressed

The prior Repair Outcome / Queue Resolution Contract v1 verdict was `blocked_repair_outcome_source_link_missing`.

This PR addresses that blocker only at the source-handoff layer. Practice queue active-repair rows can now pass target identity and repair source identity together through a typed launch request.

No repair outcome projection or resolution state was admitted.

## 3. Target/source separation decision

The existing `Act0PracticeRepairQueueLaunchTargetV1` remains the target contract:

- `worldId`
- `lessonId`
- `taskId`
- `source`
- `targetType`

The new `Act0PracticeRepairQueueLaunchRequestV1` is the source-aware launch handoff:

- target fields answer where to launch;
- source fields answer why this launch is repair-owned.

The target task id is not treated as the source task id. `sourceTaskId` is carried separately from `repairTaskId`.

## 4. Launch request schema

`Act0PracticeRepairQueueLaunchRequestV1` fields:

- `targetWorldId`
- `targetLessonId`
- `targetTaskId`
- `targetType`
- `sourceType`
- `sourceTaskId`
- `repairTaskId`
- `repairFocusKey`
- `queueItemId`

`isLaunchable` requires:

- `targetType == active_repair_target_v1`;
- non-empty target world, lesson, and task ids;
- `sourceType == active_repair_v1`;
- non-empty `sourceTaskId`, `repairTaskId`, and `queueItemId`.

## 5. Active repair handoff behavior

Active repair queue rows derive a launch request from the accepted active repair intent and queue item.

The Practice row CTA now passes the launch request, not the bare target, into the shell callback.

`_startPracticeRepairQueueTarget` consumes the request, starts the existing target task path, then restores:

- `_activeRepairTaskId = request.repairTaskId`
- `_activeRepairSourceTaskId = request.sourceTaskId`
- `_activePracticeGroupId = 'weak_spots'`

This makes the answered task context observable as repair-launched without creating an outcome.

## 6. History-row passive boundary

History-only rows remain passive.

They keep `not_launchable_v1` targets and do not receive `Act0PracticeRepairQueueLaunchRequestV1`.

No history row CTA or inferred source handoff was added.

## 7. Shell answered-task readiness

Focused shell coverage verifies that tapping `Practice this` from a real active repair state launches `actions_check_drill` and exposes this debug repair context:

- `sourceTaskId: actions_legal_context`
- `repairTaskId: actions_check_drill`
- `practiceGroupId: weak_spots`

This is sufficient for a future Repair Outcome Projection v1 to consume source task, repair task, and answered result together.

## 8. Outcome admission status

No `Act0RepairOutcomeProjectionV1` was added.

No repair outcome states were added:

- no `repair_attempted_v1`;
- no `repair_correct_v1`;
- no `repair_still_needs_rep_v1`.

This PR only makes the future outcome owner possible.

## 9. Queue/Review/progression/telemetry boundaries

No queue item is removed, resolved, cleared, fixed, or completed.

No Review history clear or mutation was added.

No progression mutation was added.

No new telemetry call site was added.

No new route family or drill engine behavior was added.

## 10. Forbidden-claim proof

No visible UI copy changed.

Forbidden claim families were not added:

- fixed
- cleared
- resolved
- completed
- mastered
- leak
- AI
- GTO
- solver
- premium
- paywall

The existing row CTA copy remains `Practice this`.

## 11. Tests / validation

Focused tests updated or added coverage for:

- active repair queue rows build a launch request with target ids and source repair identity;
- history rows remain passive and have no launch request;
- the Practice CTA emits the source-aware launch request and keeps the row visible;
- the Act0 shell restores source repair context after queue launch;
- no repair outcome projection or outcome states are admitted;
- existing repair resolver behavior remains intact.

Validation run:

- `flutter test test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_repair_outcome_contract_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed` on touched Dart/test files - passed.
- `git diff --check` - passed.
- `git status --short` - only intended source/test/review changes plus existing generated output directories.

Screenshots were not required because no visible UI changed.

## 12. Next recommended PR

Repair Outcome Projection v1.

That PR may consume the source handoff plus answered-task result and decide whether to admit `repair_attempted_v1`, `repair_correct_v1`, and `repair_still_needs_rep_v1` without clearing the queue or Review history.
