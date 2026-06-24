# Canonical Atom Mapping Tiny Slice v1

Date: 2026-06-24
Scope: fail-closed tuple registry only; no retained-event mutation, tier state,
UI, scheduler, or content expansion.

## 1. Verdict

`implemented_fail_closed_no_approved_shared_atoms`

The registry now provides one canonical decision point for a stable source
tuple, but its approved table is intentionally empty. Every current W5/W6
tuple returns `null`, preserving explicit unmapped retained results rather than
inventing a cross-family atom.

## 2. What changed

- Added `CanonicalAtomMappingInputV1` with only source family, source world,
  source session, exact target ID, and signal family ID.
- Added `CanonicalAtomMappingRegistryV1`, a pure, non-persistent resolver over
  an explicit approved tuple table.
- Kept the table empty because no current W5/W6 target has a reviewed Act0
  equivalent.
- Added focused tests for fail-closed W5 board-texture and W6 range-bucket
  inputs and for different tuple behavior.

## 3. Registry shape

The resolver key is:

`sourceFamily | sourceWorld | sourceSessionId | exactTargetId | signalFamilyId`

All fields are normalized machine IDs. The API has no display clue, learner
copy, Home/Review/Profile text, route event, or visual-label input. It returns
a canonical atom ID only from an explicit map row; all other inputs return
`null`.

## 4. Approved mappings, if any

None.

The table is deliberately empty. No current evidence proves that Act0
`board_read`/`board_cards` is equivalent to W5 board-texture classification,
or that any Act0 atom is equivalent to W6 range-bucket classification.

## 5. Explicitly unmapped records

- W5 `w5_session_drill | world_5 | w5.s01 |
  classify_texture_intro_dry_raise_v1 | board_texture_dry`
- W6 `w6_session_drill | world_6 | w6.s01 |
  classify_missed_fold_recheck | range_bucket_missed`
- Any tuple with a differing source family, world, session, target, or signal.

The retained-result event remains `skillAtomId: null`; this registry is not
wired to enrich results until an approved table entry exists.

## 6. Tests added/updated

Added `test/services/canonical_atom_mapping_registry_v1_test.dart`.

It proves that:

1. unknown W5 board-texture input returns `null`;
2. unknown W6 range-bucket input returns `null`;
3. board-like wording cannot turn W5 texture into Act0 `board_read`; and
4. a matching signal family with a different target tuple remains `null`.

Existing retained-result tests continue to prove explicit result retention and
that `skillAtomId` may remain null.

## 7. Existing behavior preserved

- No retained event is created, changed, enriched, or cleared by the registry.
- Failed-repair receipts and derived Review queue remain unchanged.
- Home, Review, and Profile remain non-owners of mapping or result evidence.
- Route launch, view, continuation, and back-out have no mapping side effect.

## 8. Remaining residue

- No approved shared Act0/W5/W6 atom exists.
- The registry has no mapping rows by design.
- A later source-metadata decision is required before a retained W5/W6 event
  can carry a non-null canonical atom ID.
- No mastery-tier state, mixed recall, leaks resurfacing, or scheduler exists.

## 9. Next recommended wave

`Canonical Atom Metadata Expansion v1`

The registry is safe but has no approved mappings. The next wave must add
reviewed source-target metadata for any real cross-family equivalence; it must
not derive equivalence from copy, labels, or semantic similarity.
