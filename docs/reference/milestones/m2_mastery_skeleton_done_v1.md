# M2 Mastery Skeleton Done V1

## Scope Closed
- Stage: M2 mastery skeleton and read surfaces.
- Status: DONE.
- Scope is service-layer only.

## What M2 Provides
- Single mastery SSOT model and tier config source.
- Read-only mastery snapshot surface.
- Read-only mastery badge derivation surface.
- Read-only mastery read bundle surface.
- Read-only gauntlet planning surface.
- Completion telemetry hook for mastery read bundle.

## Public Service Entrypoints
- `lib/services/progress_service.dart`
- `static Future<Map<String, MasteryProgressV1>> getMasteryProgressV1()`
- `static Future<MasteryTierConfigV1> masteryTierConfigForSessionIdV1(String sessionId)`
- `static Future<MasterySnapshotV1> getMasterySnapshotV1()`
- `static Future<Map<String, MasteryBadgeV1>> getMasteryBadgesV1()`
- `static Future<MasteryReadBundleV1> getMasteryReadBundleV1()`
- `static Future<GauntletPlanV1> getGauntletPlanV1()`

## Determinism Guarantees
- World keys are sorted before snapshot and badge map output.
- Bundle output is normalized with sorted world keys.
- Read maps are returned as unmodifiable maps.
- Plan output ordering is stable:
  - inProgress first by lowest completion ratio,
  - tie-break by `worldId` ascending,
  - complete worlds next by `worldId` ascending,
  - max 3 recommended worlds.
- Serialization stability is locked by service tests with repeated reads.

## Locked Tests
- `test/services/mastery_progress_v1_surface_test.dart`
- Locked invariants:
  - mastery progress read map is unmodifiable and read-only,
  - mastery tier eligibility threshold is deterministic,
  - snapshot and badges serialization are stable across repeated reads,
  - mastery read bundle serialization is stable across repeated reads,
  - mastery telemetry event emits once per new completion and payload is deterministic,
  - gauntlet plan ordering and reason codes are deterministic and ASCII.

## Telemetry Event
- Event: `mastery_read_bundle_v1`
- Emission point: `ProgressService.markModuleCompleted(...)` in `lib/services/progress_service.dart`.
- Payload summary:
  - `schemaVersion`
  - `perWorld` map with ordered world keys
  - each world has `completedSessions`, `totalSessions`, `rollingAccuracy`, `badge`.

## Not Included / Deferred
- No UI surfacing of mastery snapshot, badges, or gauntlet plan.
- No Today routing integration with gauntlet plan.
- No economy coupling with mastery state.
- No content pipeline changes.

## DoD Checklist
- Mastery SSOT remains in services.
- Mastery read APIs remain read-only.
- Deterministic ordering and serialization remain stable.
- Telemetry payload remains JSON-serializable and deterministic.
- Existing service-level mastery tests remain green.
