# Practice Repair Queue Launch Contract v1

## 1. Verdict

practice_repair_queue_active_repair_launch_contract_ready

## 2. Prior blocker addressed

The prior blocker was `blocked_queue_launch_route_contract_missing`: queue rows did not expose a projection-owned launch target.

This PR addresses that blocker for active repair rows only. The projection now owns a typed launch target object, and the consumer can read launchability without inferring from labels or visible copy.

## 3. Existing resolver/route seams used

The contract uses existing `Act0RepairIntentV1` target fields:

- `targetWorldId`
- `targetLessonId`
- `targetTaskId`

Those fields are already produced by the existing repair intent resolver path. No new route family, route truth, drill engine, or launch behavior was added.

## 4. Launchability owner contract

Launchability is owned by `Act0PracticeRepairQueueProjectionV1`.

The consumer receives launchability from `Act0PracticeRepairQueueItemV1.launchTarget`; it does not infer from `safeLabel`, `errorDetail`, `context`, or visible text.

## 5. Launch target schema

New value object:

`Act0PracticeRepairQueueLaunchTargetV1`

Fields:

- `worldId`
- `lessonId`
- `taskId`
- `source`
- `targetType`

Target types:

- `active_repair_target_v1`
- `not_launchable_v1`

Passive targets serialize only `source` and `targetType`, so passive rows do not expose target IDs.

## 6. Active repair launchability decision

Active repair rows are launchable only when the active repair source has non-empty target world, lesson, and task IDs.

If any target ID is missing, the active row remains passive with `not_launchable_v1`.

## 7. History-only passive boundary

Review-history rows remain passive by default.

History rows are not mapped to `weak_spots` merely because they are repair-like. They do not infer targets from skill label, error detail, context, or other learner-facing strings.

## 8. Consumer/UI admission status

Consumer model admission only.

`Act0PracticeRepairQueueItemViewModelV1` now exposes `isLaunchable` and optional `launchTarget` for downstream UI, but no visible CTA, row tap, callback, route transition, or launch behavior was added.

## 9. Resolution-state boundary

The launch target contract does not resolve a queue item.

It does not remove a row, mark a row fixed, clear, resolved, completed, mastered, or imply repair success.

## 10. Route/progression/telemetry boundary

No route behavior changed.

No progression mutation changed.

No telemetry call changed.

No new drill engine, launch path, or route family was added.

## 11. Tests / validation

Focused tests added/updated:

- Active repair row with a valid target exposes launch target metadata.
- Active repair row without a valid target remains passive.
- History-only rows remain passive and expose no target IDs.
- Consumer distinguishes launchable vs passive from projection metadata only.
- Ordering, dedup, unresolved state, forbidden copy, and no-UI-dependency checks remain covered.

Validation run:

- `flutter test test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed` on touched Dart/test files - passed.
- `git diff --check` - passed.
- `git status --short` - only intended source/test/review files plus generated output directories.

Screenshot commands were not run because no visible UI behavior changed.

## 12. Next recommended PR

Practice Repair Queue Row CTA v1: add a minimal row action only for rows with `active_repair_target_v1`, reusing the existing repair/practice path and preserving passive history rows.
