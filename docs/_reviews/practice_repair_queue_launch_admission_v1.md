# Practice Repair Queue Launch Admission v1

## 1. Verdict

blocked_queue_launch_route_contract_missing

## 2. Existing launch seams inspected

- Practice group launch owner: `Act0PlayShellV1.onStartGroup`.
- Practice launch router: `_startPracticeGroup` in `act0_shell_preview_screen_v1.dart`.
- Existing repair launch path: `weak_spots` group calls `_startMistakeRepair`.
- Existing repair resolver: `_openRepairIntentTargetForSourceTaskV1` / `_repairIntentTargetForSourceV1`.
- Existing active repair tests: `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`.
- Queue projection/consumer: `Act0PracticeRepairQueueProjectionV1` and `Act0PracticeRepairQueueConsumerV1`.

## 3. Queue item source mapping

Queue items currently expose source-backed metadata for display:

- `sourceRecordId`
- `sourceKey`
- `sourceTaskId`
- `skillTag`
- `safeLabel`
- `errorDetail`
- `selectedId`
- `betterId`
- `context`
- `sourceType`
- `state`

The projection does not expose an admitted launch target contract such as `targetWorldId`, `targetLessonId`, `targetTaskId`, `launchKind`, or `selectionSource`.

Active repair intent records do own target IDs, but the queue projection intentionally does not pass those target IDs to the Practice consumer.

Review-history rows expose unresolved source history, not an admitted Practice launch target.

## 4. Launch admission decision

No queue row launch is admitted in this PR.

The existing `weak_spots` group is launchable, but making a queue row launch through it would not be row-specific unless a contract proves the row maps to the same safe target. That proof is not present in the queue projection/consumer contract.

## 5. If admitted: exact allowed launch behavior

Not admitted.

The only future behavior that appears plausibly safe is an action on a row whose projection includes an explicit existing target contract and whose launch reuses the already-owned repair/practice path.

## 6. If blocked: exact missing contract

Missing contract:

- Queue projection must expose an explicit launch target owned by an existing route/path.
- The target must not be inferred from learner-facing copy.
- The target must identify an existing world/lesson/task or an already-admitted existing Practice repair group target.
- The contract must say whether the row is launchable or passive.
- The contract must preserve `queued_unresolved_v1` and must not imply fixed/cleared/resolved/completed state.
- The contract must define how active repair rows and Review-history rows differ, including whether history rows remain passive until they have a route target.

## 7. Resolution-state boundary

No row launch was added.

No row is removed from the queue. No row is marked fixed, cleared, resolved, completed, mastered, or repaired by this decision.

## 8. Route/progression/telemetry boundary

No route behavior changed.

No progression mutation changed.

No telemetry call changed.

No new drill engine, route family, or launch path was added.

## 9. Forbidden-claim proof

No product copy was added in this PR.

The blocker artifact does not introduce AI, leak, mastery, GTO, solver, premium, paywall, fixed, cleared, resolved, or completed claims into the product surface.

## 10. Tests / validation

Added focused blocked-path coverage:

- `test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart` now verifies the consumer remains passive and the projection payload has no launch target fields.

Required validation results are recorded in the final report.

Validation run:

- `flutter test test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart` - passed.
- `git diff --check` - passed.
- `git status --short` - only intended test/review changes plus generated output directories.

Screenshot commands were not run because no UI behavior changed.

## 11. Next recommended PR

Practice Repair Queue Launch Contract v1: extend the projection contract, if safe, with explicit launchability and target metadata for active repair rows first. Keep Review-history rows passive unless they receive an equally explicit route-owned target.
