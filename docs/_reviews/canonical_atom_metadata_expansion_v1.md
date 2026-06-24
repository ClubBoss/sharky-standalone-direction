# Canonical Atom Metadata Expansion v1

Date: 2026-06-24
Scope: audit source-target equivalence only; no mapping rows, retained-event
enrichment, tier state, or content expansion.

## 1. Verdict

`accepted_no_safe_mappings`

The audit found no genuine, repo-proven Act0/W5/W6 source-target equivalence.
The registry remains empty and W5/W6 retained results remain explicitly
unmapped. This is the safe no-op result.

## 2. Audit evidence

| Family | Stable source identity | Actual skill tested | Relevant Act0 identity | Result |
| --- | --- | --- | --- | --- |
| Act0 first-value | `skillAtomId`, `sourceSignalId`, task/target identity | First table signals such as `board_cards`, `no_bet_yet`, action and price reads. | `board_read` is specifically board-card identification. | Source-local atom identity exists. |
| W5 board texture | `w5_session_drill`, `world_5`, `w5.s01`, exact target drill, `board_texture_*`. | Classifies board texture and chooses a response. | No Act0 atom that classifies dry/wet/paired texture. | Explicitly unmapped. |
| W6 range bucket | `w6_session_drill`, `world_6`, `w6.s01`, exact target drill, `range_bucket_*`. | Classifies range bucket and chooses a response. | No Act0 atom that classifies range buckets. | Explicitly unmapped. |

The retained result already provides world/session/target/signal/result
identity. Its null `skillAtomId` is intentional and is not an incomplete copy
field. The mapping registry accepts the full machine tuple and has no display
copy input.

## 3. Candidate mappings considered

| Candidate | Evidence for | Evidence against | Decision |
| --- | --- | --- | --- |
| Act0 `board_read` <-> W5 `board_texture_*` | Both refer to board information. | Act0 tests identifying board cards; W5 tests texture classification plus response. Different cue, action, target, and content meaning. | Reject. |
| Act0 table/starting-hand reads <-> W6 `range_bucket_*` | Both are poker classification exercises. | W6 tests a range bucket and action; no Act0 atom has that machine-owned skill definition. | Reject. |
| Act0 `action_read` / `no_bet_yet` <-> W5/W6 target actions | Both can have action answers. | Same answer format does not establish the same visible signal or decision skill. | Reject. |

## 4. Approved mappings added, if any

None. No registry row was added and no retained result was enriched.

## 5. Rejected mappings and why

Every candidate would require one forbidden inference: semantic similarity,
matching English copy, matching action labels, or a shared Review/Home/Profile
presentation. None is a stable authored equivalence. Mapping any candidate
would collapse adjacent concepts and allow a W5/W6 miss to affect an unrelated
Act0 atom.

## 6. Tests added/updated

No tests were added. Existing registry tests already prove:

- W5 `board_texture_*` remains unmapped;
- W6 `range_bucket_*` remains unmapped;
- different source/target tuples remain unmapped; and
- retained result behavior remains independent of mapping.

Adding a positive mapping test would encode a taxonomy not supported by source
or content truth.

## 7. Existing behavior preserved

- The mapping registry remains pure, static, and fail-closed.
- Retained W5/W6 events keep `skillAtomId: null`.
- Failed-repair receipts and derived Review queue are unchanged.
- Home, Review, Profile, route launch, target view, continuation, and back-out
  remain non-owners of mapping evidence.
- No repair clears, proof, tier state, mixed recall, or scheduler behavior is
  introduced.

## 8. Remaining residue

The missing artifact is not more display copy. It is a reviewed source-target
metadata contract that can explicitly state, for any future cross-family
equivalence:

1. canonical atom ID;
2. complete source tuple;
3. same visible cue and learner action;
4. same expected outcome and curated target; and
5. permitted downgrade scope.

Without all five, a tuple remains `null`.

## 9. Next recommended wave

`Canonical Source Target Metadata Contract v1`

The current source families are genuinely distinct, not merely missing a
mapping row. The next useful work is a contract for future authored
equivalence—not a mastery-tier implementation or a broad taxonomy expansion.
