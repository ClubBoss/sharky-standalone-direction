# Canonical Atom Mapping Contract v1

Date: 2026-06-24
Status: local mapping contract; no product implementation
Scope: stable machine-ID mapping between Act0 evidence and retained W5/W6
result events. This contract does not create tier state or infer shared atoms.

## 1. Verdict

`mapping_contract_ready_no_code`

Act0 has stable `skillAtomId` and signal identity. W5/W6 has stable source
family, world/session/target, drill-family, and signal identity, but its
retained results deliberately carry `skillAtomId: null`. No existing source
proves a shared Act0 <-> W5/W6 atom. The safe current mapping is explicit
unmapped state, followed by a small static mapping slice rather than a
copy-string join or broad content-metadata migration.

## 2. Current atom identity evidence

| Surface | Machine identity present | Not identity / limitation |
| --- | --- | --- |
| Act0 repair intent / result | `skillAtomId`, `sourceSignalId`, source world/lesson/task, target task, mapping type, and result. | Retention memory remains task-keyed; display labels do not make an atom global. |
| Act0 recheck / prove | Task ID, deterministic retention state, recheck/prove job identity, and local answer result. | `Act0MasteryStatusV1` is a display status, not cross-family evidence. |
| W5/W6 retained result | World, source session, exact target drill, `signalFamilyId`, target kind, source family, source receipt key, selected/expected action, and explicit result. | `skillAtomId` is intentionally null. |
| Session-drill receipt | Source world/session/drill, `drillFamilyId`, `missedSignalId`, target session/drill, and target kind. | `missedSignalLabel` is rendering copy, not an atom ID. |
| Review card | Queue job/source/target identity. | Card text and visibility are continuation UI only. |
| Home repair reason | Act0 repair target/reason receipt. | Home strings and priority are not mapping ownership. |
| Profile mirror | Derived focus/progress presentation. | Profile is not a source of evidence or identity. |

## 3. Canonical atom ID rule

A canonical atom ID is stable only when an explicit mapping record contains:

1. a stable known ID or enum/constant;
2. source-family ownership;
3. source world/session/task or exact target identity;
4. stable signal family; and
5. an approved curated mapping entry when crossing source families.

The mapping key must be the tuple:

`sourceFamily + sourceWorld + sourceSession/task + exactTargetId + signalFamilyId`

The canonical atom is the output of that tuple, not its display label. A map
entry may return `null` / `unmapped` when no evidence proves an equivalence.

Explicitly rejected as identity: display clue text, learner-facing copy, Review
labels, Home strings, Profile state, route launches, visual badge text, and
matching English phrases.

## 4. Mapping table

| canonicalAtomId | source family | source world | source signal family | known source / target IDs | learner-facing clue | confidence | eligible for shared evidence | reason |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `board_read` | Act0 first-value | Act0 route | `board_cards` | Act0 receipt target when available | Board cards | High | No | Act0 atom means identifying board cards; it is not board-texture classification. |
| `null` / unmapped | `w5_session_drill` | `world_5` / `w5.s01` | `board_texture_*` | `classify_texture_intro_*` exact replay targets | Dry/Wet/Paired board texture | High source identity; no cross-family mapping | No | Stable W5 target and signal exist, but no Act0 atom specifies classifying texture. |
| `null` / unmapped | `w6_session_drill` | `world_6` / `w6.s01` | `range_bucket_*` | `classify_*` range-bucket recheck targets | Range bucket | High source identity; no cross-family mapping | No | Stable W6 target and signal exist, but no Act0 atom specifies range-bucket classification. |

There are no currently proven shared atoms. The table intentionally contains
only source-proven records and explicit non-sharing decisions.

## 5. Act0 <-> W5/W6 sharing rules

Evidence may share one canonical atom only if an approved static mapping entry
matches the complete machine-ID tuple and both sides require the same visible
cue, learner action, expected outcome, beginner-safe vocabulary, and curated
repair/recheck target.

Two similar-looking signals must remain separate when they differ in cue,
action, error class, target, terminology, or content introduction. Therefore:

- Act0 `board_read` / `board_cards` and W5 `board_texture_*` remain separate.
- Act0 first-value atoms and W6 `range_bucket_*` remain separate.
- A W5/W6 retained event stays unmapped when no static entry exists.
- Future content must add explicit target metadata before a new cross-family
  atom can share evidence.
- A same-signal miss may reopen/downgrade only the mapped canonical atom; with
  `null` mapping it remains source-local and cannot affect Act0 state.

## 6. Required future source changes

Recommended: **one static mapping table** owned beside the W5/W6 receipt/result
contract. Each row must match source family, world, session, exact target drill,
and signal family, then return a canonical atom ID or `null`.

This is safer than copy matching because it is reviewable, deterministic,
target-specific, and fails closed for new content. It avoids a broad content
metadata migration and preserves explicit unmapped results until real Act0 and
W5/W6 equivalence is authored and reviewed.

Do not populate `skillAtomId` from labels, titles, queue text, or an inferred
semantic similarity. The tiny slice may initially contain only `null` entries
and one future explicitly approved mapping; that is useful because it gives
the event producer one canonical decision point without claiming equivalence.

## 7. Test contract

The future mapping tiny slice must prove:

1. an approved W5/W6 exact target maps to its expected canonical atom ID;
2. unknown target or signal remains explicitly unmapped;
3. changing learner-facing clue text does not change the mapping result;
4. same English copy from different source families does not force sharing;
5. launch, target view, route continuation, and back-out create no mapping
   evidence;
6. Home, Review, and Profile strings cannot be mapping owners; and
7. Act0 and W5/W6 share evidence only through the canonical atom ID returned
   by the mapping table.

No test is added in this contract wave. There is no approved shared mapping to
exercise, and a test would otherwise encode an invented cross-family taxonomy.

## 8. Ownership boundary

| Role | Owner / boundary |
| --- | --- |
| Source target metadata owner | W5/W6 session-drill content/receipt contract; provides stable source and target IDs. |
| Atom mapping owner | Future static mapping table; owns only tuple-to-atom or tuple-to-null decisions. |
| Retained result producer | W5/W6 surfaced session-drill answer flow; appends exact-target outcomes. |
| Future normalizer | Reads retained result and mapping output; cannot infer or mutate source evidence. |
| Future mastery tier state owner | May consume normalized evidence only after mapping and tier contracts are separately admitted. |
| View/mirror surfaces | Home, Review, and Profile may display/continue derived state only. |

## 9. Later candidate decision

`Canonical Atom Mapping Tiny Slice v1`

The mapping contract is ready, while the mapping decision point does not exist
in code. The smallest safe implementation is a static, fail-closed table plus
tests for an explicitly approved target mapping and unknown-target null result.
Mastery Tier State Tiny Slice v1 remains blocked because no atom is currently
proven shared across Act0 and W5/W6.

## 10. Guardrails

- No copy-string joins.
- No tier UI or dashboard.
- No XP economy or streak pressure.
- No scheduler.
- No new telemetry schema or owner.
- No commerce, paywall, or trial work.
- No Modern Table changes.
- No first-week polish continuation.
- No Runout taxonomy cloning.
- No broad content expansion.
- No fake AI, adaptive, or mastery claims.
- No generated outputs committed.
- No cross-family state aggregation or mastery-tier implementation.

## Evidence consulted

- `docs/_reviews/retained_w5_w6_result_event_tiny_slice_v1.md`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/services/session_drill_repair_receipt_adapter_v1.dart`
- `lib/services/board_texture_repair_receipt_mapping_v1.dart`
- `lib/services/session_drill_repair_receipt_persistence_v1.dart`
