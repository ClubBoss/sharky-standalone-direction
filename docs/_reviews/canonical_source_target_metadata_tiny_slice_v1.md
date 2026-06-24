# Canonical Source Target Metadata Tiny Slice v1

## 1. Verdict

`implemented_metadata_null_canonical`. The catalog is a reviewed, read-only
source-target record at the existing W5/W6 session-drill seam. It does not
assert any canonical atom equivalence.

## 2. Scope and Guardrails

This slice adds only static metadata lookup. It does not change retained
receipt/result behavior, mapping rows, tier state, UI, dashboard, scheduler,
telemetry, commerce, Modern Table, or learner-facing copy.

## 3. Metadata Record Shape

Each record contains canonical atom ID or null; source family/world/session,
exact target, and signal tuple; machine cue; display clue; expected answer;
outcome semantics and context; downgrade scope; curated repair/recheck/prove
availability; content owner; evidence confidence; and review stamp.

## 4. Reviewed W5/W6 Coverage

The catalog covers the source-proven W5 dry-texture recheck target
`classify_texture_intro_dry_raise_v1` and W6 missed-range-bucket recheck
target `classify_missed_fold_recheck`. Their expected actions are `raise` and
`fold` respectively.

## 5. Canonical Atom Behavior

Both reviewed records keep `canonicalAtomId: null`. The retained result event
also remains unchanged with `skillAtomId: null`; the catalog reads its tuple
without enriching or persisting it.

## 6. Mapping Policy

No mapping rows were added. The existing canonical mapping registry remains
empty and fails closed for every tuple, including the reviewed metadata tuples.
Similar wording, signals, or actions are not equivalence proof.

## 7. Identity and Copy Separation

Lookup identity is exactly source family, world, session, target, and signal.
The machine cue is recorded independently from learner-facing display copy, so
copy changes cannot alter source-target identity.

## 8. Test Evidence

`canonical_source_target_metadata_v1_test.dart` verifies known W5/W6 metadata,
the complete tuple, null canonical IDs, cue/copy separation, display-copy
non-identity, unknown fail-closed behavior, and retained-event null canonical
behavior. Mapping-registry and retained-result suites remain green.

## 9. Preserved Behavior and Residue

Receipt persistence, retained events, Review-queue derivation, and all
learner-facing behavior are unchanged. No dashboard, scheduler, mixed-recall,
telemetry, entitlement, or cross-family aggregation behavior exists in this
slice.

## 10. Next Candidate

`Canonical Source Target Metadata Expansion v2` is the single next candidate:
add further source-proven records or review evidence while preserving null
canonical IDs until a separately reviewed mapping is justified.
