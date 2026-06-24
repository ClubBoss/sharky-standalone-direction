# Retained W5/W6 Result Event Contract v1

Date: 2026-06-24
Status: local contract; no product implementation
Scope: immutable exact-target result evidence for W5/W6 session drills before
future mastery logic may consume an outcome.

## 1. Verdict

`event_contract_ready_no_code`

The session-drill runner evaluates explicit target answers. The missing piece
is a durable, retained result-record owner. Adding that owner is a new product
state implementation, so this wave defines the record and test contract only.

## 2. Current W5/W6 evidence lifecycle

| Step | Current source | Retained now | Boundary |
| --- | --- | --- | --- |
| Answer evaluation | Surfaced canonical session-drill runner evaluates `DrillUserEventV1` against the current drill, including `isRecheckLaunchV1` targets. | Local evaluation only. | Local evaluation is not durable mastery evidence. |
| Failed-repair receipt | `buildSessionDrillRepairReceiptCandidateV1` and board-texture mapping build a candidate from failed `DrillEvalResultV1`. | Source world/session/drill, family, missed signal/label, selected/expected action, and target. | Failure/repair routing, not recheck result. |
| Receipt persistence | `SessionDrillRepairReceiptPersistenceV1` stores `session_drill_repair_receipts_v1` and replaces the same source session/drill candidate. | One latest candidate per source drill. | Cannot append answer history or mark target resolved/attempted. |
| Launch target | `SessionDrillRepairReceiptConsumerV1` and `SessionDrillRecheckLaunchQueueV1` derive supported W5/W6 queue items. | Exact target session/drill and target kind. | Queue is derived, not result state. |
| Review continuation | Review renders a real queue card and calls `pushSessionDrillRecheckLaunchV1`. | A route launch only. | Review cannot clear or fabricate success. |
| Target result | Runner knows correct/wrong for the current target. | No retained W5/W6 recheck/prove outcome. | This is where success is lost. |

CTA tap, route launch, target view, route continuation, session completion,
invalid fallback, back-out/abort, receipt copy, queue-card visibility, Home
priority, Review state, and Profile mirror state are not success evidence.

## 3. Immutable result event shape

The future result owner appends one immutable record only after an explicit
answer resolves on the exact target. Repo-native names may differ, but the
following semantics are mandatory.

| Field | Contract |
| --- | --- |
| `schemaVersion` | Required integer; initial value `1`. |
| `eventId` | Deterministic from source receipt key, exact target, context, and answer-attempt sequence. Never derive it from UI labels or wall-clock text. |
| `createdAtSequence` | Optional non-negative deterministic producer sequence. W5/W6 currently has none retained; omit rather than invent age. |
| `worldId` | Required stable `world_5` or `world_6`. |
| `sourceSessionId` | Required source session, such as `w5.s01` or `w6.s01`. |
| `targetDrillId` | Required exact target drill identity; task-equivalent key for this family. |
| `skillAtomId` | Required after approved canonical mapping; until then explicit unmapped/null, never guessed from copy. |
| `signalFamilyId` | Required stable missed-signal/drill-family identity. |
| `learnerFacingClueName` | Required normalized display clue; never an identity join key. |
| `targetKind` | Required `exact_replay` or `same_signal_recheck`. |
| `selectedActionId` | Required action selected on the exact target. |
| `expectedActionId` | Required expected action on the exact target. |
| `result` | Required enum: `success` or `miss`. `suboptimal` is not supported by this family and must not be emitted until a producer supports it. |
| `context` | Required enum: `initial`, `repair`, `recheck`, or `prove`. This contract applies `recheck` only when `isRecheckLaunchV1` is true; other contexts need explicit producers. |
| `sourceFamily` | Required `w5_session_drill` or `w6_session_drill`. |
| `isRetainedForMasteryEvidence` | Required bool; true only for an explicit answer outcome meeting this contract. |
| `sourceReceiptKey` | Required source-session/source-drill identity for auditability and deduplication. |

The event must contain no severity/CTA/card/Profile labels and must reference,
not duplicate, the failed-repair receipt. A receipt copy is not event state.

## 4. Lifecycle rules

1. Create an event only when the exact `targetDrillId` receives an explicit
   evaluated answer result.
2. Append immutable `success` or `miss`; never overwrite the failed-repair
   receipt or infer a result from navigation.
3. Do not create or mutate an event on launch, target view, route continuation,
   session completion, invalid fallback, or Home/Review/Profile rendering.
4. Back-out/abort creates no success event and no result event unless a later
   explicit non-result abort contract is approved.
5. Receipt or queue-copy changes cannot mutate a retained result.
6. Home may prioritize, Review may continue, and Profile may mirror only; none
   may fabricate or resolve result evidence.
7. A future normalizer may read retained events but cannot mutate them. A future
   mastery-tier owner may derive state only after separate atom mapping approval.

## 5. Atom identity requirements

A W5/W6 retained result becomes eligible for future mastery consumption only
when it has:

1. stable canonical `skillAtomId` from an approved mapping;
2. stable `signalFamilyId` from source drill/missed-signal identity;
3. learner-facing clue name that is display-only;
4. exact target session/drill identity;
5. curated repair, recheck, or prove target on the learner route; and
6. explicit answer result under this contract.

An abstract copy string, drill title, queue label, or matching Act0 text is not
atom identity and cannot establish cross-family sharing.

## 6. Test contract

The later tiny slice must prove:

1. correct exact-target answer appends one retained `success` event;
2. wrong exact-target answer appends one retained `miss` event;
3. launch/view alone produces no event;
4. normal route continuation alone produces no event;
5. back-out/abort alone produces no success event;
6. receipt copy is not event source of truth;
7. event includes target identity, signal family, result, context, source
   family, and mapped-or-explicitly-unmapped atom identity; and
8. event excludes UI-copy/state duplication.

No test is added here. The retained-result owner does not exist, so a new test
would prescribe an unapproved owner implementation rather than lock behavior.
The later tiny slice must use red-green TDD.

## 7. Ownership boundary

| Role | Owner / rule |
| --- | --- |
| W5/W6 flow | Evidence producer: evaluates exact target answer and submits an immutable event to its future result store. |
| Future result store | Durable owner of retained W5/W6 result records only; not a tier owner. |
| Future normalizer | Consumer/bridge: reads retained records and approved mappings without mutating source evidence. |
| Future mastery tier state | Durable tier-eligibility owner only after normalizer and mapping contracts are approved. |
| Home | Priority surface only; may read derived state but cannot create results. |
| Review | Continuation surface only; may launch target work but cannot silently resolve it. |
| Profile | Mirror only; cannot create, mutate, or resolve evidence. |

## 8. Later candidate decision

`Retained W5/W6 Result Event Tiny Slice v1`

Exact answer evaluation exists; retention shape and a durable result owner do
not. The smallest safe slice appends exact-target records, leaves receipts and
queue derivation intact, and locks all navigation-only flows as no-ops.
Canonical Atom Mapping Contract v1 follows because `skillAtomId` cannot yet be
inferred.

## 9. Guardrails

- No tier UI or dashboard.
- No XP economy or streak pressure.
- No new scheduler.
- No new telemetry schema or owner.
- No commerce, paywall, or trial work.
- No Modern Table changes.
- No first-week polish continuation.
- No Runout taxonomy cloning.
- No broad content expansion.
- No fake AI, adaptive, or mastery claims.
- No generated outputs committed.
- No cross-family atom aggregation or mastery-tier state implementation.

## Evidence consulted

- `docs/_reviews/cross_family_mastery_owner_boundary_v1.md`
- `docs/_reviews/w6_recheck_resolution_policy_audit_v1.md`
- `lib/services/session_drill_repair_receipt_persistence_v1.dart`
- `lib/services/session_drill_repair_receipt_consumer_v1.dart`
- `lib/services/session_drill_recheck_launch_queue_v1.dart`
- `lib/services/session_drill_recheck_user_launch_consumer_v1.dart`
- `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`
- `test/services/session_drill_repair_receipt_consumer_v1_test.dart`
