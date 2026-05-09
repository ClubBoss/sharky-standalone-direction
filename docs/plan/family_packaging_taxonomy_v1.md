# Family Packaging Taxonomy v1

Purpose:

- define the repo-level packaging taxonomy for bounded production/content frontiers
- turn the already-proven package patterns into one reusable playbook
- reduce re-litigation of package type, seam requirements, anchor requirements, and exclusion rules

## Package Types

### 1) Deterministic / factual lane

Use when:

- a family resolves to one deterministic authored fact or one source-owned symbolic anchor
- the family boundary is clean enough to onboard as a bounded lane, not a subset pilot

Required ingredients:

- one canonical authored truth seam
- bounded supported grammar / target vocabulary
- validator anchor
- targeted validator test
- runtime/UI contract anchor or explicit runtime event anchor
- explicit exclusions when needed

Representative examples:

- `docs/plan/deterministic_board_tap_lane_v1.md`
- `docs/plan/deterministic_seat_tap_lane_v1.md`

### 2) Exact-subset pilot

Use when:

- a family is only partially clean
- one exact subset already resolves from structured authored truth
- the remaining residue should stay excluded until a cleaner seam exists

Required ingredients:

- explicit supported subset boundary
- canonical authored truth seam for that subset
- supported exact question / label / target shapes
- validator anchor
- targeted validator guard
- runtime/UI contract anchor if already present
- explicit exclusions for blocked residue

Representative examples:

- `docs/plan/exact_initiative_subset_pilot_v1.md`
- `docs/plan/exact_board_texture_subset_pilot_v1.md`

### 3) Trainer-policy pilot

Use when:

- the family or residue is not objective truth
- the answer expresses an authored trainer-policy default or pressure rule
- a canonical non-prose policy seam exists and policy-consistency can be checked honestly

Required ingredients:

- explicit statement that the pilot is trainer-policy semantics, not canonical truth
- canonical authored policy seam
- bounded policy-shape vocabulary
- policy/semantic boundary references
- validator/test references for the neighboring family boundary
- runtime/UI contract anchor if already present
- explicit separation from any exact-truth subset in the same family

Representative example:

- `docs/plan/initiative_pressure_subset_policy_pilot_v1.md`

## Canonical Seam Rule

Every package must identify one canonical authored seam before onboarding:

- deterministic / factual lane:
  - source-owned truth such as `expected.boardSlot`, `expected.role`, `expected.seatId`, `last_aggressor_v1`, `initiative_owner_v1`
- exact-subset pilot:
  - exact structured subset truth such as explicit cards, seats, actors, or labels
- trainer-policy pilot:
  - explicit policy seam such as `expected.actionId`, `initiative_policy_shape_v1`, `pressure_owner_v1`, `intent_v1`, `acceptable_actions`

Do not onboard a family boundary that still depends primarily on prose wording when no canonical seam exists.

## Minimum Anchor Set

Every package should name:

- the package type
- the supported family or subset boundary
- the canonical seam
- the validator anchor
- the targeted guard/test anchor
- the runtime/UI anchor if one already exists
- explicit exclusions

## Honest Exclusion Rule

If part of a family is still blocked, say why explicitly:

- missing canonical seam
- heuristic / policy-coupled residue
- missing authored payload
- mixed multi-step semantics

Do not widen a clean package to absorb blocked residue just to make the family look uniform.

## Selection Heuristic

When choosing the next bounded frontier:

1. prefer deterministic / factual lane if a clean full-family seam exists
2. otherwise prefer exact-subset pilot if one exact structured subset is already clean
3. otherwise prefer trainer-policy pilot only after a canonical non-prose policy seam is authored
4. otherwise stop and refine the authored seam before packaging
