# Retained W5/W6 Result Event Tiny Slice v1

Date: 2026-06-24
Scope: bounded retained-result implementation; no tier, UI, queue, or route
behavior expansion.

## 1. Verdict

`implemented`

W5/W6 exact recheck targets now append immutable retained `success` or `miss`
evidence only after an explicit target answer resolves. Navigation and view
paths remain no-ops for retained evidence.

## 2. What changed

- Added `SessionDrillRetainedResultEventV1` and
  `SessionDrillRetainedResultPersistenceV1` in the existing session-drill
  receipt-persistence module, using a separate append-only preferences key.
- Added `persistSessionDrillRetainedResultIfEligibleV1`, which accepts only a
  W5/W6 recheck launch whose current drill exactly equals `initialDrillId` and
  matches an existing persisted repair receipt target.
- Wired the surfaced session-drill runner to persist that event immediately
  after explicit answer evaluation and before its existing pass/miss flow.
- Kept failed-repair receipt writes, queue derivation, Review continuation,
  Home priority, and Profile behavior unchanged.

## 3. Event shape actually implemented

`SessionDrillRetainedResultEventV1` persists:

- `schemaVersion: 1`;
- deterministic `eventId` from source receipt key, target, recheck context,
  and append attempt number;
- `worldId`, `sourceSessionId`, `targetDrillId`, `targetKind`, and
  `sourceReceiptKey`;
- `signalFamilyId` and learner-facing clue name from the existing receipt;
- explicitly unmapped `skillAtomId: null`;
- selected and expected action IDs;
- `result` limited to `success` or `miss`;
- `context: recheck`, `sourceFamily`, and
  `isRetainedForMasteryEvidence: true`.

The event omits receipt error class, queue/card labels, CTA text, severity, and
Profile state. It references the receipt by key instead of copying receipt
state.

## 4. Lifecycle no-op proof

The persistence guard returns no event unless all of these are true:

1. `isRecheckLaunchV1` is true;
2. the current drill exactly matches `initialDrillId`;
3. the session is supported W5/W6;
4. an explicit action answer has an expected-action target; and
5. a matching persisted repair receipt exists.

Therefore launch, target view, normal route continuation, invalid/fallback
target, session completion without an exact target answer, back-out/abort,
receipt copy, Home, Review, and Profile cannot create or mutate retained
result evidence.

## 5. Tests added/updated

Added `test/services/session_drill_retained_result_event_v1_test.dart`.

It proves:

1. W6 exact-target correct answer appends one `success` event;
2. W5 exact-target wrong answer appends one `miss` event;
3. non-recheck launch and non-target answer create no event;
4. event identity contains source family, target, signal, selected/expected
   action, result, context, and explicitly unmapped atom identity;
5. event payload does not use receipt-copy label keys as state; and
6. retained events do not clear the existing receipt or derived Review queue.

## 6. Existing behavior preserved

- Failed-repair receipts still persist by source session/drill.
- Session-drill recheck launch queue remains derived from those receipts.
- Review still launches the exact queued target and cannot resolve it.
- Recheck launches still suppress normal completion/progress signaling.
- No repair is cleared, no tier is promoted, and no Home/Review/Profile state
  is mutated by the new event.

## 7. Remaining residue

- `skillAtomId` is intentionally `null`; no Act0/W5/W6 canonical atom mapping
  exists yet.
- Only `recheck` context is emitted. Initial, repair, and prove producers are
  not inferred.
- No deterministic age/sequence marker exists for W5/W6, so none is invented.
- No tier state, mixed recall, leaks resurfacing, scheduler, dashboard,
  telemetry owner, or UI has been added.

## 8. Next recommended wave

`Canonical Atom Mapping Contract v1`

The exact W5/W6 result event is now retained safely, but it remains explicitly
unmapped to Act0 skill atoms. The next wave must define stable machine-ID
mapping rules, forbidden label-only joins, and the evidence required before a
future normalizer can share cross-family mastery evidence.
