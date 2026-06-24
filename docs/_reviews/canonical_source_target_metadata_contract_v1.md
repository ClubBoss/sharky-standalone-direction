# Canonical Source Target Metadata Contract v1

Date: 2026-06-24
Status: local metadata admission contract; no runtime or content implementation.

## 1. Verdict

`metadata_contract_ready_no_code`

The source ownership boundary is clear enough for a future small metadata
slice. No current target has complete reviewed metadata proving a shared Act0
and W5/W6 atom, so this contract admits no mapping row today.

## 2. Current blocker

No current mapping is safe because the source skills are distinct:

- Act0 `board_read` identifies board cards.
- W5 `board_texture_*` classifies texture and selects a response.
- W6 `range_bucket_*` classifies a range bucket and selects a response.

Similar poker words, table surfaces, answer formats, or action labels do not
establish one skill atom. The current records prove source-local outcomes only.

## 3. Required metadata fields

Every target proposed for mapping must carry a reviewed metadata record with:

| Field | Requirement |
| --- | --- |
| `canonicalAtomId` | Stable machine-owned destination ID, or explicit `null`/unmapped. |
| `sourceFamily` | Stable producer family, for example `act0_first_value`, `w5_session_drill`, or `w6_session_drill`. |
| `sourceWorld` | Stable world identity. |
| `sourceSessionId` | Stable source session or Act0 source-session/task namespace. |
| `exactTargetId` | Exact target task/drill identity. |
| `signalFamilyId` | Stable machine-owned cue/signal identity. |
| `learnerFacingClueName` | Display-only clue; never a join key. |
| `machineCueDefinition` | Reviewed statement of what visible table/card/action cue is being recognized. |
| `expectedAnswer` | Expected action/answer and allowed answer semantics. |
| `outcomeSemantics` | What `success`, `miss`, and any supported suboptimal outcome mean. |
| `context` | Explicit `initial`, `repair`, `recheck`, or `prove` source context. |
| `downgradeScope` | Exact canonical atom or explicitly linked atom family a later miss may reopen. |
| `curatedTargetAvailability` | Whether a route-valid curated target exists. |
| `repairTargetAvailability` | Exact/same-signal repair target availability. |
| `recheckProveTargetAvailability` | Recheck and prove path availability, or explicit not-eligible state. |
| `mixedRecallEligible` | Boolean, default false until a curated beginner-safe mixed target exists. |
| `contentOwner` | Authored content/source metadata owner responsible for meaning and target truth. |
| `evidenceConfidence` | Reviewed confidence with concrete source references. |
| `reviewStamp` | Version/date/reviewer marker for the admitted metadata record. |

The complete source tuple is:

`sourceFamily | sourceWorld | sourceSessionId | exactTargetId | signalFamilyId`

## 4. Mapping admission rule

A registry row may be admitted only when all conditions hold:

1. the same `canonicalAtomId` is explicitly authored and reviewed for each
   source record;
2. the complete source tuple is stable;
3. the machine cue/signal is the same, not merely adjacent;
4. expected answer and outcome semantics match;
5. downgrade scope is explicit;
6. the target has a curated repair/recheck/prove path or is explicitly marked
   not eligible for the unavailable stage; and
7. the decision uses no display copy, English phrase, UI label, Home/Review/
   Profile text, or route event.

## 5. Mapping rejection rule

A record remains `null` when any of these are true:

- `canonicalAtomId` is missing;
- the source tuple is incomplete;
- concepts are adjacent rather than the same atom;
- answer format is shared but cognitive task differs;
- copy is shared but table signal differs;
- surface is shared but decision skill differs;
- source proves only launch, view, or continuation;
- downgrade scope is unclear; or
- no curated target path exists and the record is not explicitly ineligible.

## 6. Downgrade scope rule

Future mastery logic may downgrade/reopen only the exact mapped canonical atom
or a separately reviewed linked atom family. Specifically:

- a W5 texture miss must not mutate Act0 board-card identification;
- a W6 range-bucket miss must not mutate Act0 board/hand reading unless both
  records explicitly author the same atom; and
- an unmapped retained result remains source-local evidence only.

## 7. Source ownership model

| Role | Owner / boundary |
| --- | --- |
| Content/source metadata owner | Authored source family and its content contract; owns cue, target, expected answer, and semantic truth. |
| Mapping registry owner | Static reviewed tuple-to-atom/null registry; cannot invent content meaning. |
| Retained result producer | W5/W6 exact-target answer flow; appends source-local success/miss evidence. |
| Future normalizer | Reads retained result plus admitted mapping; cannot mutate source evidence. |
| Future mastery tier owner | May consume normalized evidence only after separate tier admission. |
| Home/Review/Profile | Read, continue, or mirror derived state only; never source metadata or mapping owners. |

## 8. Minimal source metadata examples

### W5 safe unmapped record

`w5_session_drill | world_5 | w5.s01 |
classify_texture_intro_dry_raise_v1 | board_texture_dry`

- `canonicalAtomId: null`
- machine cue: dry board texture
- expected answer: authored W5 board-texture response
- downgrade scope: source-local W5 texture evidence only
- reason: no reviewed Act0 target tests dry-texture classification.

### W6 safe unmapped record

`w6_session_drill | world_6 | w6.s01 |
classify_missed_fold_recheck | range_bucket_missed`

- `canonicalAtomId: null`
- machine cue: missed range bucket
- expected answer: authored W6 range-bucket response
- downgrade scope: source-local W6 range evidence only
- reason: no reviewed Act0 target tests range-bucket classification.

### Hypothetical mapped record (not approved)

A future W5/W6 target could map only if its metadata names an existing Act0
`canonicalAtomId`, repeats the same machine cue and learner action, has the
same outcome semantics, names matching curated repair/recheck targets, and
receives a review stamp. This example does not authorize any current mapping.

## 9. Test plan

Before metadata implementation, tests must prove:

1. complete reviewed metadata maps only by `canonicalAtomId` plus full tuple;
2. missing metadata remains null;
3. W5 board texture cannot map to Act0 board read;
4. W6 range bucket cannot map to Act0 board/hand read;
5. same display copy cannot map;
6. same action answer cannot map;
7. a miss affects only the mapped atom's explicit downgrade scope; and
8. unmapped retained result cannot affect tier state.

## 10. Later candidate decision

`Canonical Source Target Metadata Tiny Slice v1`

Fields and source ownership are clear. The next slice may introduce the
smallest reviewed metadata record at an existing source-target seam, defaulting
to `canonicalAtomId: null`; it must not add a mapping row until content truth
proves equivalence.

## 11. Guardrails

- No copy-string joins or broad atom taxonomy.
- No tier UI, dashboard, XP economy, streak pressure, or scheduler.
- No telemetry schema/owner, commerce/paywall/trial, or Modern Table changes.
- No first-week polish continuation, Runout taxonomy cloning, or broad content
  expansion.
- No fake AI/adaptive/mastery claims.
- No generated outputs committed.
- No retained-event mutation, mapping-row approval, mastery tier, or leaks
  resurfacing implementation in this wave.

## Evidence consulted

- `docs/content/CONTENT_EXCELLENCE_CANON_v1.md`
- `docs/plan/CONTENT_AUTHORING_CONTRACT_CONTENT_GRAMMAR_v1.md`
- `docs/_reviews/canonical_atom_metadata_expansion_v1.md`
- `lib/services/session_drill_repair_receipt_adapter_v1.dart`
- `lib/services/board_texture_repair_receipt_mapping_v1.dart`
- `lib/services/canonical_atom_mapping_registry_v1.dart`
