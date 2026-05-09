# Status / Readiness Policy v1
Status: SSOT-lite
Purpose: Record the canonical meaning and promotion discipline for the status and readiness labels already used across truth-map, Dev Hub, and planning layers.
Last updated: 2026-03-09

## Use

This document sits alongside:

- `docs/plan/CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md`
- `docs/plan/CANONICAL_ID_NAMING_REGISTRY_CONVENTIONS_v1.md`
- `docs/plan/WORLD_NODE_MODE_MATRIX_v1.md`
- current truth-map and Dev Hub state-console work

It does not replace runtime truth.
It defines the meaning of the status/readiness labels already in use, what they do not guarantee, and what evidence is needed before promotion.

Core rule:

- prefer honest status over optimistic status
- do not promote a surface because it is merely reachable or mapped

## Scope Of This Policy

This policy covers the current labels already present or clearly implied in the repo:

- `productionLive`
- `productionLiveModernized`
- `productionLiveLegacy`
- `pilotLive`
- `placeholder`
- `scaffold`
- `legacy`
- `devOnly`
- `representedReady`
- `needsSkeletonShell`

It is intentionally small.
It does not define a giant product lifecycle beyond what the current project actually uses.

## Canonical Status Meanings

### `productionLive`

Meaning:

- reachable on a real current product path
- not just a doc, scaffold, or hidden pilot

Does not guarantee:

- modernized UX quality
- complete world density
- latest instructional seam quality

Typical evidence:

- reachable through canonical production routing
- backed by real runtime content
- not only a dev-only or pilot surface

Type:

- product-facing runtime status

### `productionLiveModernized`

Meaning:

- production-live and already aligned to the newer intended seam/presentation standard for its class

Does not guarantee:

- full world completeness
- all adjacent hosts are equally modernized
- perfect polish across the entire family

Typical evidence:

- real host is reachable in production
- visible seam proof exists on the intended host family
- the surface no longer behaves like the known older legacy-feel variant for that class

Type:

- product-facing runtime status
- quality-refined subset of `productionLive`

### `productionLiveLegacy`

Meaning:

- still live on a real product path, but known to retain an older seam, older presentation style, or legacy-feel behavior relative to the current standard

Does not mean:

- broken
- hidden
- dev-only

Typical evidence:

- real production reachability exists
- a newer class standard exists elsewhere
- the host has not yet been aligned to that newer standard

Type:

- product-facing runtime status
- transitional honesty label

### `pilotLive`

Meaning:

- real and reachable, but intentionally bounded
- live as a pilot or secondary-surface proving ground, not yet broad mainline product coverage

Does not guarantee:

- main campaign ownership
- scale readiness
- broad world integration

Typical evidence:

- real runtime surface exists
- real user or dev-visible entry exists
- bounded scope is explicit

Type:

- product-facing or secondary-live status
- transitional rollout label

### `placeholder`

Meaning:

- explicitly reserved as a future surface or node but not yet meaningfully implemented

Does not mean:

- live
- instructionally useful
- enough for readiness promotion

Typical evidence:

- explicit reserved slot or placeholder shell exists

Type:

- structural status

### `scaffold`

Meaning:

- structural truth exists and the object is represented in topology/registry, but the actual learning surface is still coarse, thin, or not meaningfully filled

Does not mean:

- the world/node is ready
- the skill family is covered
- live quality is acceptable

Typical evidence:

- canonical topology/registry entry exists
- basic routing or skeleton truth exists
- meaningful content depth is not yet there

Type:

- structural status

### `legacy`

Meaning:

- outdated or misaligned relative to the current intended path
- still present in the repo or runtime, but not the preferred current product state

Does not mean:

- necessarily still reachable from the main path

Typical evidence:

- known older seam or route remains
- newer intended surface/path already exists

Type:

- historical or cleanup status

### `devOnly`

Meaning:

- intentionally present for developer visibility, validation, or tooling only

Does not mean:

- part of the user-facing product path

Typical evidence:

- debug-only access
- no normal production path ownership

Type:

- dev-surface status

## Canonical Readiness Meanings

### `representedReady`

Meaning:

- sufficiently represented in the current truth map to be treated as a real current node/surface for later skeleton work or scaling decisions

Does not guarantee:

- production quality
- modernization
- healthy world density

Typical evidence:

- the node is real enough to classify and reason about in current truth
- it is not merely an absent idea
- current project logic can point to a real owned surface

Type:

- structural readiness label

### `needsSkeletonShell`

Meaning:

- not yet represented strongly enough for later scaling/fill work
- still needs a clearer shell, more explicit ownership, or stronger structural presence

Does not mean:

- the concept is unimportant
- it should disappear from the roadmap

Typical evidence:

- coarse scaffold only
- no meaningful current owned surface
- not yet strong enough for density/fill judgment

Type:

- structural readiness label

## Transition / Promotion Rules

### `scaffold` -> `productionLive`

Minimum evidence:

- real reachable runtime surface exists
- content is not just a shell
- the surface is used on a real product path, not only as a dev or pilot artifact

Promotion blockers:

- topology exists but runtime still does not
- content is too thin or placeholder-only
- only a pilot/secondary surface exists

### `productionLive` -> `productionLiveModernized`

Minimum evidence:

- visible seam proof on the real host/class
- host is aligned to the newer intended standard for its family
- difference is validated by real host behavior, not by optimism

Promotion blockers:

- the host is reachable but still uses older legacy-feel presentation
- only adjacent hosts are modernized
- the upgrade exists only in planning docs, not the actual runtime surface

### `productionLiveLegacy` -> `productionLiveModernized`

Minimum evidence:

- direct host-level alignment work landed
- real path proof exists for the same host/class
- the host no longer behaves as the older legacy-feel variant

Promotion blockers:

- only copy changed while the seam remained effectively old
- only a neighboring host in the family was modernized
- evidence is indirect or speculative

### `pilotLive` -> `productionLive`

Minimum evidence:

- no longer only a bounded proving slice
- surface has a clear world/node home in the main product structure
- enough stability exists to justify treating it as current product truth

Promotion blockers:

- still limited to a pilot cluster on a secondary surface
- unclear mainline ownership
- not enough evidence for broader rollout

### `needsSkeletonShell` -> `representedReady`

Minimum evidence:

- clear owned surface/node exists in current truth
- enough structure exists to classify and reason about the node honestly

Promotion blockers:

- only architecture intent exists
- topology shell is too coarse to support real placement/readiness reasoning

## Practical Policy Rules

- Avoid status inflation.
- Do not mark something `live` if only scaffold truth exists.
- Do not mark something `modernized` without visible seam proof.
- Do not treat `representedReady` as a synonym for high quality.
- Do not treat `productionLive` as proof of curriculum completeness.
- Prefer additive evolution of the status model over status renames.
- If uncertainty exists, choose the more conservative status.

## What These Labels Explicitly Do Not Replace

These labels do not replace:

- skill coverage judgment
- progression/prerequisite judgment
- world density judgment
- pilot-vs-mainline product strategy decisions

They are one control layer, not the entire product truth.

## Near-Term Implication

Future work should use this policy for:

- truth-map updates
- Dev Hub labeling
- readiness judgments
- future guard logic where status or readiness promotion is tested

Practical rule:

- update status only when the evidence changes
- update readiness only when structural representation changes
- do not use status labels to hide unresolved product gaps
