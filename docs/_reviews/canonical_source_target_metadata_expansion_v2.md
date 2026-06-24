# Canonical Source Target Metadata Expansion v2

## 1. Verdict

`implemented_metadata_expansion_null_canonical`

## 2. What changed

Expanded the read-only canonical source-target metadata catalog with seven
source-proven W5/W6 classifier recheck targets. No runtime consumer or
persistence path changed.

## 3. Source targets added

- W5 `classify_texture_intro_wet_call_v1` / `board_texture_wet` / `call`
- W5 `classify_texture_intro_paired_fold_v1` / `board_texture_paired` / `fold`
- W6 `classify_strong_call_control` / `range_bucket_strong` / `call`
- W6 `classify_strong_raise` / `range_bucket_strong` / `raise`
- W6 `classify_medium_call_control` / `range_bucket_medium` / `call`
- W6 `classify_weak_fold_pressure` / `range_bucket_weak` / `fold`
- W6 `classify_missed_fold` / `range_bucket_missed` / `fold`

Each has an explicit source family, world, session, target, signal, machine
cue, expected action, and recheck outcome/context.

## 4. Source targets rejected

W6 action-choice targets (`choose_call_range`, `choose_fold_trap`,
`choose_raise_range`) and seat/card/board anchor targets are rejected. They
are not owned by the existing classifier receipt/recheck source contract and
would require a separate stable signal and target-policy review.

## 5. Metadata shape / invariants

Identity remains exactly source family, world, session, exact target, and
signal. Machine cue is independent of learner display copy. Added records use
`source_local` downgrade scope, `source_proven` confidence,
`session_drill_content` ownership, and the existing availability semantics.

## 6. Canonical ID behavior

All seven added records set `canonicalAtomId: null`. No cross-family
equivalence is asserted or inferred.

## 7. Mapping rows added, if any

None. The canonical mapping registry remains empty and fail-closed.

## 8. Tests added/updated

Focused metadata coverage now resolves each added tuple, verifies its expected
action, null canonical ID, machine cue, downgrade scope, and confidence. The
mapping registry and retained-result suites remain regression coverage.

## 9. Existing behavior preserved

Retained events are still read only; they are not enriched or persisted.
Receipt, Review queue, Home, Profile, route, UI, scheduler, telemetry,
commerce, and content behavior are unchanged.

## 10. Remaining residue

Canonical mappings remain unsupported. Non-classifier and display-copy-only
targets remain deliberately absent. No mastery aggregation, mixed recall, or
product-visible metadata consumer has been introduced.

## 11. Next recommended wave

`Volume I Visible Depth Plan v1`. Metadata coverage now represents the stable
W5/W6 classifier repair targets without requiring a broad taxonomy; the next
bottleneck is deciding how existing depth becomes visible in the learner route,
not adding more unconsumed metadata.
