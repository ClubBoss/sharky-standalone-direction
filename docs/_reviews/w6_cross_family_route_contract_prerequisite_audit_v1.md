# W6 Cross-Family Route-Contract Prerequisite Audit v1

Date: 2026-06-23

Origin main: `79fa6802f450c672c094cb5b5eae4bf7738a7553`

Status: architecture audit; no route, runtime, UI, telemetry, content, or
generated-output change.

## Scope and non-scope

This audit evaluates whether a persisted W6 range-bucket repair candidate can
launch its exact session-drill target without losing target identity or
pretending it is an Act0 task repair.

It does not add a visible consumer, `initialDrillId`, a new route, telemetry,
progress behavior, content, Modern Table work, or archive movement.

## Current W6 chain

```
W6 range-bucket miss
  -> SessionDrillRepairReceiptCandidateV1
  -> SessionDrillRepairReceiptPersistenceV1
  -> SessionDrillRepairRecheckCandidateV1
  -> SessionDrillRecheckLaunchQueueItemV1
  -> STOP
```

The queue item preserves sufficient provenance: source world/session/drill,
family, signal and error data, chosen/expected action, target session/drill,
target kind, and a deterministic job id. It accepts only supported W6
`range_bucket_classifier_v1` data.

The requested `session_drill_repair_receipt_store_v1.dart` does not exist in
this checkout; `session_drill_repair_receipt_persistence_v1.dart` is the
current durable-store owner.

## Canonical session-drill launch path

1. Direct session owners call `canonicalSessionDrillRouteV1(sessionId: ...)`
   in `lib/ui_v2/runner/canonical_launcher_api_v1.dart`.
2. The route builds `CanonicalLauncherV1.sessionDrill`.
3. The launcher creates a `CanonicalTerminalSessionDrillSurfacedPayloadV1`.
4. `CanonicalTerminalRunnerSurfaceV1` dispatches that payload to
   `CanonicalTerminalSessionDrillSurfacedRunnerV1`.
5. The surfaced runner loads all drills for `widget.sessionId` through
   `DrillRuntimeAdapterV1`.

Current launch parameters are session and World1/handoff support values. None
represent a target session-drill id or recheck launch semantics.

## Target-drill support findings

No existing `initialDrillId`, target-drill parameter, or equivalent selection
contract exists in the canonical route, launcher, terminal payload/dispatch,
or surfaced runner.

The surfaced runner initializes `_currentIndex` to `0`, loads the full session,
and advances sequentially. On a pass at the final current drill it calls
`ProgressService.markModuleCompleted(widget.sessionId)` and emits
`session_drills_complete_v1` with the full session drill count.

Therefore, adding only a start index or drill id would not be semantics-free:
it could allow a partial recheck path to mark the complete session or emit a
misleading normal-session completion event. No tests prove an alternative
progress/completion/telemetry policy for targeted rechecks.

## Act0 and session ownership mismatch

Act0's visible repair path is task-centric:

- `Act0RepairIntentV1` requires source and target world/lesson/task ids.
- `_Act0LearningRecommendationV1`, `_startRecommendation`, and
  `_startMistakeRepair` resolve and launch Act0 lesson tasks.

The W6 queue item instead owns session/drill ids. Converting it into an
`Act0RepairIntentV1` would invent unsupported task identity. Launching only
`w6.s01` would discard `targetDrillId`, violating the recheck contract.

## Minimal safe contract candidate

The smallest future design is two explicitly owned contracts, delivered and
tested in a dedicated route-contract wave:

1. `SessionDrillLaunchTargetV1` or equivalent canonical payload with validated
   `sessionId`, `targetDrillId`, and a named launch purpose such as recheck.
   Invalid target ids must fail closed without progress or telemetry mutation.
2. A runner completion policy for targeted rechecks that is distinct from a
   normal session completion. It must define drill ordering, completion,
   persistence, and telemetry before the runner accepts a target start.

Only after those contracts exist can a separate cross-family Act0 launch-target
adapter expose a user-initiated W6 continuation without fabricating an Act0
task repair. The visible consumer remains a later scoped decision.

## Unsafe actions explicitly rejected

- Dropping `targetDrillId` and launching only the session.
- Inferring an Act0 world/lesson/task id from a session-drill id.
- Reusing normal session completion and telemetry for a targeted recheck.
- Adding a visible Home/Review consumer before target-launch semantics exist.
- Moving/archive-cleaning runner files as part of the route-contract work.

## Verdict

`unsafe_missing_contract_stop`

The queue descriptor is complete, but no safe existing route reaches its exact
target. A theoretically additive `initialDrillId` cannot be treated as a small
adapter because it changes completion/progress/telemetry semantics owned by the
session runner and canonical launch boundary.

## Required next wave

If W6 visible recheck continuation remains a product priority, open one
dedicated cross-family route-contract wave. It must explicitly authorize the
canonical route, terminal payload, surfaced runner, progress/telemetry policy,
focused contract tests, and a separate later decision about visible Act0
consumer ownership.

## Validation run

- Read-only PIEC over the W6 receipt/queue, canonical launch, terminal
  dispatch, surfaced runner, and Act0 repair owners.
- Three targeted Graphify queries for canonical route, target-drill support,
  and Act0 queue ownership; source findings above take precedence.
- `graphify hook-check`, `flutter analyze`, diff check, and status check.

Known baseline: the lifecycle visible-copy failure in
`act0_repair_intent_lifecycle_v1_test.dart` is not touched or claimed green.
