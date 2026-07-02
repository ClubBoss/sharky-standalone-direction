# Spaced Repetition Engine v1

## Verdict

`spaced_repetition_engine_landed_engine_only`

This PR adds a deterministic Act0 spaced-repetition scheduling read model. It does not route the schedule into Home, Practice, Review, notifications, persistence, telemetry, or a new screen.

## Existing scheduling seams found

- `Act0ConceptFamilyStateHistoryV1` already exposes concept-family state, last outcome, evidence order, and last session id.
- `Act0LearningTransferMeasurementV1` already exposes transfer verdicts across sessions.
- `Act0RepairIntentV1` already exposes unresolved active repair intent metadata.
- `Act0PersonalizedReturnReasonV1` explains why a return target matters, but it is not timing truth.
- `Act0PracticeRepairQueueProjectionV1` selects concrete repair tasks, but it does not accept a schedule without changing learner routing behavior.

No existing consumer seam was narrow enough to admit schedule input without route or practice behavior expansion.

## Schedule contract

`Act0SpacedRepetitionScheduleV1.fromSources` derives a stable list of `Act0SpacedRepetitionFamilyScheduleV1` records from:

- active repair intents;
- concept-family state;
- learning-transfer signals;
- explicit `currentSessionOrdinal`.

Each family record includes:

- `conceptFamilyId`;
- `scheduleState`;
- `dueReason`;
- optional last evidence session/order;
- optional `dueAfterSessionOrdinal`;
- optional evidence references;
- deterministic `priorityClass`.

The model is derived-only. `tryParse` is present for safe optional payload reads, skips unknown schema versions, and fails closed on malformed entries.

## Interval policy

- unresolved active repair: due now;
- unresolved miss: due now;
- repair not yet succeeded / attempted: due now;
- repair succeeded: due after one later session;
- improved same-family transfer: due after one later session;
- held same-family transfer: due after two later sessions;
- insufficient or same-session evidence: insufficient, not due.

The policy uses session ordinals, not wall-clock time.

## Due-family selector

`nextDueFamily` filters to `due_now` records and sorts deterministically by:

1. priority class;
2. oldest due-after session ordinal;
3. most recent evidence order;
4. lexical concept-family id.

## Persistence and derivation impact

No persistence writer was added. No existing stored payload shape was changed. The schedule can be recomputed from existing Act0 source models.

## Consumer admission result

Consumer admission result: engine-only.

Practice routing was not changed because converting a scheduled concept family into a concrete task would require expanding target selection behavior. Home was not changed because it already consumes return reasons and the prompt blocked mixed Home/Practice integration without a clear single seam.

## Return-reason alignment

The schedule aligns with the current return-reason priority family:

- active unresolved repair remains due now;
- failed repair remains due now;
- improved transfer becomes a conservative one-session reinforcement;
- held transfer becomes a longer two-session reinforcement;
- insufficient transfer evidence remains not due.

The return reason remains explanatory copy. The schedule is timing truth.

## Telemetry impact

No telemetry event, metric, logger, or analytics field was added.

## Scope proof

This PR adds:

- one pure Act0 schedule engine file;
- one focused unit test file;
- this review artifact.

It does not add a route, screen, notification, server dependency, vendor scheduler, ML model, broad practice redesign, queue mutation, monetization behavior, ranking display, or percentage-based skill claim.

## Known limitations

- The engine does not yet map due concept families to concrete Practice tasks.
- The engine does not persist schedule snapshots.
- The engine does not expose UI copy.
- The interval ladder is intentionally small and deterministic for v1.

## Phase 2 closure decision

Phase 2 should be a separate PR only after choosing one consumer seam. The safest next seam is a read-only adapter that maps `nextDueFamily` into an existing repair target without changing Practice route structure.
