# Cross-Family Mastery Owner Boundary v1

Date: 2026-06-24
Status: local owner-boundary contract; no product implementation
Scope: define what a future mastery-state owner may consume from Act0 and
W5/W6 without turning Home, Review, or Profile into state owners.

## 1. Verdict

`blocked_missing_w5_w6_result_event`

Act0 can produce and retain task-level repair, recheck, and candidate-prove
evidence. W5/W6 session drills can retain a failed-repair receipt and derive a
recheck launch target, but they cannot retain the result of answering that
target. A shared mastery state must not consume route launch or UI visibility
as a substitute for that missing result event.

## 2. Current evidence families

| Family | Current evidence | Current owner boundary |
| --- | --- | --- |
| Act0 task repair | `Act0RepairIntentV1` carries source task/world/lesson, `skillAtomId`, signal identity, clue label, result, and repair target. A correct exact or mapped repair clears its matching intent. | Act0 task flow and its persisted task-keyed retention memory. |
| Act0 recheck / prove | `fixedRecent` ages by deterministic sequence to `agedRecheck`; a clean recheck makes `ownedCandidate`; an owned-candidate completion emits the existing prove-completed event. | Act0 retention memory, keyed by `taskId`; it is not an atom-global store. |
| W5/W6 session-drill receipt | `SessionDrillRepairReceiptCandidateV1` retains world/session/drill, family, missed signal, clue, selected/expected action, and exact/same-signal target. | Session-drill receipt persistence; it replaces a source-drill candidate but has no resolved/attempted result. |
| W5/W6 recheck route | `SessionDrillRecheckLaunchQueueV1` derives a queue item and `pushSessionDrillRecheckLaunchV1` starts the targeted drill in recheck mode. | Queue/route continuation only; it is not durable resolution evidence. |
| Review continuation | Review renders Act0 repair cards and only real W5/W6 queue items; it launches the selected continuation. | View/continuation surface, not a global mastery state owner. |
| Home priority | Existing Act0 selection ranks open repair, aged recheck, owned/prove candidate, then route continuation. | Priority selection over existing Act0 state; it must not mutate or infer state. |
| Profile mirror | Profile renders focus, recent proof, and progress after evidence is recorded elsewhere. | Mirror only; it cannot create, promote, downgrade, or resolve mastery. |
| Atom / signal identity | Act0 first-value receipts have `skillAtomId` and `sourceSignalId`; W5/W6 receipts have stable drill-family and missed-signal IDs. | These are separate identity vocabularies until an explicit mapping contract exists. |

`Act0MasteryStatusV1` remains a per-run display status, not a durable shared
mastery owner.

## 3. Ownership table

Allowed roles are: **evidence producer** (records an answer outcome),
**evidence normalizer** (converts a producer record into canonical evidence),
**durable state owner** (persists tier eligibility), **view/mirror owner**
(renders derived state), and **priority selector** (chooses an action without
mutating state).

| Family / surface | Evidence producer | Evidence normalizer | Durable state owner | View / mirror owner | Priority selector | Decision |
| --- | --- | --- | --- | --- | --- | --- |
| Act0 repair/task flow | Yes: answer/repair result. | Local only: repair intent/receipt fields. | Yes, task-local only: open/fixed/aged/owned retention. | Act0 feedback. | No. | May provide local evidence; cannot own cross-family atom tiers. |
| W5/W6 session-drill flow | Yes internally: runner evaluates target answer. | No retained normalizer. | No result-resolution owner. | Session-drill route. | No. | Cannot contribute successful shared evidence yet. |
| Act0 retention memory | No independent answer production. | Local task-state transition only. | Yes for Act0 task retention. | No. | Supplies candidates. | Must not absorb W5/W6 receipts by label. |
| Home | No. | No. | No. | Yes. | Yes. | Reads state to choose next action; never mutates tiers. |
| Review | No. | No. | No. | Yes. | Continuation only. | May launch repair/recheck; never silently clears or promotes state. |
| Profile | No. | No. | No. | Yes. | No. | Mirror only. |
| Future mastery tier state | No raw UI production. | Consumes only canonical retained records. | Yes, when explicitly introduced. | May expose derived state later. | May expose eligibility, not choose routes. | Absent in this wave; no implementation is authorized. |

## 4. Retained W5/W6 result event

No such retained result event currently exists. The current receipt store only
loads/saves failed-repair candidates, and the queue is derived from those
candidates. The surfaced runner knows an answer result locally, but does not
persist a recheck outcome or resolution record. Existing paths:

- `lib/services/session_drill_repair_receipt_persistence_v1.dart`
- `lib/services/session_drill_recheck_launch_queue_v1.dart`
- `lib/services/session_drill_recheck_user_launch_consumer_v1.dart`
- `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`
- `docs/_reviews/w6_recheck_resolution_policy_audit_v1.md`

The required future contract must retain one immutable result record per exact
target-answer attempt. Its minimum shape is:

| Field | Requirement |
| --- | --- |
| `skillAtomId` | Canonical atom key after an approved mapping; absent mapping means no shared mastery consumption. |
| `worldId` and `sourceFamily` | Stable source context such as `world_5`/`world_6` and session-drill family. |
| `signalFamilyId` | Stable missed-signal/drill-family identity, not display copy. |
| `learnerFacingClueName` | Normalized clue text for rendering only; it cannot be the join key. |
| `resultType` | Exact target answer outcome, at minimum `correct` or `wrong`; launch/view/back-out are not outcomes. |
| `attemptContext` | One of `repair`, `recheck`, or `prove`, plus target session/drill identity. |
| `sequenceMarker` | Deterministic source sequence/age if the producing family has one; otherwise absent, never invented from wall-clock UI timing. |
| `sourceReceiptKey` | Stable source-session/source-drill identity to preserve auditability and prevent duplicate receipt copy becoming state. |

The record must not contain UI-only severity/CTA labels and must not duplicate
the full receipt payload as a second state store. It is required future
contract work, not a request to implement a telemetry schema or new UI.

## 5. Canonical atom mapping

### Same-signal rule

Evidence may share one future mastery atom only when an approved mapping gives
both families the same canonical `skillAtomId`, and both records identify the
same visible cue, learner action, beginner-safe clue, and target outcome.
The mapping must be explicit by stable machine IDs, never by matching strings.

### Separate-atom rule

Two surfaces remain separate atoms when they differ in any of: cue being read,
required learner behavior, error class, introduced vocabulary, expected action,
or safe repair target. A W5/W6 drill-family ID does not automatically equal an
Act0 first-value `skillAtomId`.

### Sharing rule

One atom may consume cross-family evidence only after all of the following
exist:

1. approved `skillAtomId` mapping for both records;
2. retained correct/wrong W5/W6 result event for the exact target;
3. deterministic same-signal mapping and target identity;
4. shared downgrade policy for a same-signal miss; and
5. curated, beginner-safe target availability for the learner's route.

### Forbidden mappings

- Display-label equality alone, including a repeated clue string.
- Route launch, target view, CTA tap, session completion, or back-out.
- A W5/W6 receipt copied into `Act0RepairIntentV1`.
- An Act0 `taskId` treated as an atom-global key.
- `Act0MasteryStatusV1` display labels treated as proof records.

## 6. Success-resolution owner

| State statement | Current permitted owner | Future cross-family rule |
| --- | --- | --- |
| Repair still open | Act0 open repair/retention state; W5/W6 pending receipt remains open. | Canonical owner may read each family record but must not infer closure from navigation. |
| Repair cleared | Act0 exact/mapped repair completion. | W5/W6 needs retained exact-target `correct` result before it can say cleared. |
| Ready to prove | Act0 `ownedCandidate` after its deterministic recheck policy. | Future tier owner may derive it only from normalized evidence. |
| Prove passed | Act0 emits a local prove completion signal. | Shared claim requires retained, mapped, exact-target proof evidence. |
| Speed eligible | No current owner. | Only a future mastery-tier state owner may persist this after the approved proof/mixed-context policy. |
| Downgraded after same-signal miss | Act0 reopens local repair on answer miss. | Future tier owner may downgrade only the canonically mapped atom; unrelated same-copy records remain untouched. |

Home remains a priority surface, Review remains a continuation surface, and
Profile remains a mirror. None may become a durable success-resolution owner.

## 7. Stop boundaries

Implementation must stop, with no tier mutation, when:

1. W5/W6 does not expose a retained exact-target result event.
2. Atom mapping is ambiguous or only a prospective label match.
3. The same string exists as copy but no stable atom/signal identity exists.
4. A source proves UI text, CTA visibility, or route construction rather than
   a durable answer outcome.
5. A clean route launch, target view, invalid fallback, or back-out is offered
   as mastery evidence.
6. A proposed owner would move Home, Review, or Profile from their current
   read/continuation roles into competing durable state ownership.

## 8. Minimal test contract

Before implementation, the smallest contracts must prove:

1. A clean Act0 repair normalizes to canonical atom evidence without changing
   unrelated atoms.
2. A correct W5/W6 exact target answer normalizes to one retained result event.
3. A same-signal miss reopens/downgrades only the matching canonical atom.
4. Normal route continuation is a no-op for evidence and tier state.
5. App launch, CTA tap, target view, invalid fallback, and back-out are no-ops.
6. Profile rendering cannot mutate mastery state.
7. Home priority reads existing state but cannot own or mutate it.
8. Review may continue repair/recheck but cannot silently clear it.

No test is added in this wave: the missing W5/W6 result record means a test
would be a test for an unapproved owner implementation rather than a useful
boundary regression.

## 9. Later candidate decision

`Retained W5/W6 Result Event Contract v1`

This is the only safe next candidate because the retained W5/W6 exact-target
result event is missing. Canonical atom mapping and a mastery-tier tiny slice
remain blocked behind that contract. It should be test-first, preserve source
receipt identity, and make launch/back-out no-ops.

## 10. Guardrails

- No UI implementation or dashboard.
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
- No route changes and no cross-family aggregator implementation.

## Evidence consulted

- `docs/_reviews/mastery_tier_contract_v1.md`
- `docs/_reviews/w6_recheck_resolution_policy_audit_v1.md`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/services/session_drill_repair_receipt_persistence_v1.dart`
- `lib/services/session_drill_recheck_launch_queue_v1.dart`
- `lib/services/session_drill_recheck_user_launch_consumer_v1.dart`
