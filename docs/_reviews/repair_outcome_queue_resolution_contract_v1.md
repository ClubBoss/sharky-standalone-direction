# Repair Outcome / Queue Resolution Contract v1

## 1. Verdict

blocked_repair_outcome_source_link_missing

## 2. Existing evidence seams inspected

Inspected seams:

- `Act0RepairIntentV1` owns the active repair source, including source world, source lesson, source task, selected choice, error type, missed signal, skill atom, and mapped target.
- `Act0PracticeRepairQueueProjectionV1` turns active repair intents into Practice queue items.
- `Act0PracticeRepairQueueLaunchTargetV1` owns the row CTA launch target.
- `_startPracticeRepairQueueTarget` starts the mapped task through the existing Act0 world/lesson/task path.
- `_recordAnswer` records completed task answers and derives repair source behavior from `_activeRepairTaskId` and `_activeRepairSourceTaskId`.
- `_appendLearningEvidenceV1` appends completed decisions into learning evidence and Review mistake history.

## 3. Outcome owner decision

No new outcome owner was admitted in this PR.

The correct owner is not telemetry and not Review history. A future owner should be a small Act0 repair outcome projection fed by an explicit repair source handoff from queue item to launched task result.

That owner was not implemented because the current queue CTA launch path does not carry a stable source repair intent key or source task id into the answer result.

## 4. Source linkage decision

Source linkage is incomplete for queue-launched active repair rows.

The active queue item still has source context:

- `sourceRecordId`
- `sourceKey`
- `sourceTaskId`
- `selectedId`
- `betterId`
- `context`

But the launch target passed through the CTA only contains:

- `worldId`
- `lessonId`
- `taskId`
- `source`
- `targetType`

`_startPracticeRepairQueueTarget` receives only `Act0PracticeRepairQueueLaunchTargetV1`. It starts the target with `evidenceRunKind: 'repair'` and `evidenceStartedBy: 'practice_repair_queue'`, but it does not set `_activeRepairTaskId` or `_activeRepairSourceTaskId`.

Because `_startTaskByIds` clears `_activeRepairSourceTaskId`, the later answer path cannot honestly prove which source repair intent the queue-launched target was meant to repair.

## 5. Safe outcome states

The preferred future states remain scoped and safe:

- `repair_attempted_v1`
- `repair_correct_v1`
- `repair_still_needs_rep_v1`

They were not admitted into source code in this PR because the source link is missing.

No fixed, cleared, resolved, completed, mastered, leak, AI, GTO, solver, premium, or paywall claim was added.

## 6. Queue effect boundary

No queue resolution effect was added.

Queue rows remain unresolved. This PR does not remove queue items, hide active repair rows, mark queue rows done, or convert launch into a clear/fix/resolve state.

## 7. Review history boundary

No Review history clear or resolution behavior was added.

The existing Review mistake history append path remains unchanged. A future repair outcome projection must not clear Review history unless a separate Review resolution contract is accepted.

## 8. UI/Session Summary/Achievement boundary

No UI surface changed.

No Practice visible copy, Review visible copy, Home surface, Learn surface, Profile surface, Session Summary surface, achievement copy, route, progression, telemetry, or drill engine behavior changed.

## 9. Forbidden-claim proof

The focused guard test verifies no repair outcome model or safe outcome-state constants were admitted without source linkage.

The blocker keeps forbidden resolution and claim families out of this PR:

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

Existing unrelated legacy copy was not edited in this task.

## 10. Tests / validation

Focused test added:

- `test/ui_v2/act0_repair_outcome_contract_v1_test.dart`

The test proves:

- active repair queue items preserve source context outside the launch target;
- the launch target passed to the CTA omits source task/source key/source record linkage;
- `_startPracticeRepairQueueTarget` does not restore `_activeRepairTaskId` or `_activeRepairSourceTaskId`;
- no repair outcome projection/state model was admitted without source linkage.

Validation run:

- `flutter test test/ui_v2/act0_repair_outcome_contract_v1_test.dart` - passed.
- `flutter test test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed test/ui_v2/act0_repair_outcome_contract_v1_test.dart` - passed.
- `git diff --check` - passed.
- `git status --short` - only intended test/review files plus existing generated output directories.

Screenshots were not required because no visible UI changed.

## 11. Next recommended PR

Practice Queue Repair Source Handoff Contract v1.

That PR should decide whether `Act0PracticeRepairQueueLaunchTargetV1` may safely carry source repair context, or whether the row callback should pass a small launch request that includes both target ids and the source repair item identity. Only after that handoff exists should `Act0RepairOutcomeProjectionV1` be admitted.
