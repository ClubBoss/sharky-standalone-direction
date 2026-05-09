# Content Factory Release Gate v1

Purpose:

- define the first canonical readiness contract for surfacing new learning content
- make future world / module / session expansion depend on explicit source truth and guard coverage instead of local judgment
- stay bounded to release-gate truth only, not runtime enforcement, boredom systems, monetization, or a full production handbook

## Governs Now

This SSOT governs:

- what counts as a unit that may be considered ready to surface
- the minimum structured source truth required before a unit can surface
- the minimum validator / guard expectation for a new bounded slice
- what must be explicit in source instead of inferred by runner logic
- what “ready to surface” means at the current stage of the project

This SSOT does not yet govern:

- runtime gating implementation
- CI/release automation
- staffing/workflow ownership
- anti-boredom / novelty policy
- monetization or entitlement logic

## Release-Gate Unit Types

The release gate applies to these planning units:

- bounded drill family slice
- session slice
- module slice
- world slice

Default rule:

- the smallest unit that introduces new semantic risk should satisfy the release gate first
- larger units inherit readiness only if their constituent bounded slices already meet the gate

## Minimum “Ready To Surface” Meaning

A unit is ready to surface only if all of these are true:

- source truth is explicit enough that the runner does not need to guess key semantics
- the unit’s cognitive job is clear and matches the intended family/pacing/prerequisite layer
- minimum validation or guard coverage exists for the unit’s highest-risk contradiction class
- any exclusions or deferred residue are explicit rather than silently tolerated
- the unit’s current status is honest under the readiness policy

Ready to surface does not mean:

- fully optimized
- globally complete
- future-proof for every adjacent family
- already automated at scale

## Minimum Structured Source Requirements

Before surfacing, a bounded unit must have:

- stable content identity
  - canonical ids and bounded family membership
- explicit expected outcome
  - expected answer / target / action / truth field as appropriate for the family
- enough structured payload to derive the intended truth
  - examples: cards, seats, street, board, visible anchors, ordered steps
- explicit teaching copy
  - prompt plus correction/reinforcement fields appropriate to the family
- explicit exclusions where source truth is intentionally missing

Disallowed:

- relying on runner inference to invent missing semantic truth
- relying on prose alone when the family claims deterministic truth
- treating a reachable shell as proof of content readiness

## Source vs Runner Boundary

Source must own:

- correct answer truth
- visible or structured semantic payload
- bounded instructional intent
- acceptable alternatives if soft-pass behavior is intentional
- recap/reinforcement copy if the slice needs it

Runner must not own:

- hidden prerequisite assumptions
- inferred winner/intent/outs/order semantics from vague prose alone
- “fix-up” logic that rescues under-authored content at runtime

## Minimum Validator / Guard Expectation

Each new bounded slice must have at least one of:

- a deterministic validator for its primary truth seam
- or a bounded guard that proves family membership / route / contract integrity

Default rule:

- the first surfaced slice in a family should prove one real contradiction class or one real source/route seam
- later slices in the same family may reuse the same validator/guard path if the seam is unchanged

Disallowed:

- broad surfacing of a new family with no explicit validator/guard story
- claiming readiness based only on manual review when the family is deterministic enough to guard

## Minimum Coverage Rules By Unit Size

| Unit size | Minimum gate |
| --- | --- |
| bounded drill family slice | explicit source contract + one targeted validator/guard proof for the highest-risk contradiction class |
| session slice | all new bounded sub-slices satisfy their own gate; pacing and prerequisite assumptions are explicit |
| module slice | all surfaced sessions are status-honest; no hidden “to be filled later” dependency is required for the learner to complete the current path |
| world slice | core progression path is coherent under pacing + prerequisite SSOTs; deferred residue is explicit and non-blocking |

## Status Honesty Rule

Do not surface a unit as if it were more complete than it is.

Operational rule:

- if the unit is bounded/pilot-only, label it that way
- if the unit has explicit exclusions, record them
- if a validator only covers a slice, state the slice boundary
- if a world/module/session depends on future fill to make sense, it is not ready under this gate

## Required Explicitness Before Surfacing

These must be explicit before a new slice surfaces:

- family boundary
- expected learner job
- structured truth payload for the chosen family
- whether the slice is intro, practice, apply, review, recap, or checkpoint
- whether any adjacent residue is intentionally excluded

These may remain later-stage:

- broader scale automation
- anti-boredom tuning
- monetization packaging
- future cross-world expansion plans

## Release-Gate Questions

Before surfacing a new unit, ask:

1. What exact unit is surfacing: bounded slice, session, module, or world?
2. What structured truth does the source provide directly?
3. What highest-risk contradiction class or seam is guarded?
4. What remains excluded or deferred, and is that acceptable?
5. Does the unit still make sense without hidden runner rescue logic?
6. Is its status label honest?

If those answers are unclear, the unit is not ready to surface.

## Out of Scope For Later Docs

These belong to later SSOTs or policies:

- runtime enforcement / unlock implementation
- CI/content factory automation details
- anti-boredom / novelty scheduling
- monetization and entitlement gating
- staffing / author workflow handbook details
