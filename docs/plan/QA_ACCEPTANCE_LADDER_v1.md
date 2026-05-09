# QA / Acceptance Ladder v1
Status: SSOT-lite
Purpose: Record the canonical acceptance and verification discipline for current milestone types so future rollout uses explicit evidence rules instead of ad hoc habits.
Last updated: 2026-03-09

## Use

This document sits alongside:

- `docs/plan/CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md`
- `docs/plan/STATUS_READINESS_POLICY_v1.md`
- current guard and truth-map work

It does not replace runtime guards or release gates.
It defines the minimum acceptance standard for bounded implementation work in the current project phase.

Core rule:

- use the smallest sufficient verification for the slice you changed
- do not confuse more commands with better evidence

## Why This Ladder Exists

Without an explicit ladder, two bad patterns appear:

- optimistic closure with too little proof
- noisy closure with many unrelated checks that do not increase confidence

The project needs a middle path:

- enough proof to justify build-on
- not so much validation that every bounded slice turns into process drag

## Milestone Types

This ladder covers the current practical categories:

- doc-only
- audit / proof-only
- planning-doc + guard
- content-only
- bounded runtime/content slice
- surface rollout / pilot slice
- truth/status update tied to real evidence

## Acceptance Ladder

### 1. Doc-Only

Accepted means:

- one bounded document lands in the right canon location
- content is consistent with current in-repo truth

Minimum evidence:

- doc scope is respected
- no runtime/code changes piggybacked in

Minimum verification budget:

- none by default

Safe to build on when:

- the document is committed and referenceable in repo

### 2. Audit / Proof-Only

Accepted means:

- the conclusion is grounded in current repo/runtime evidence
- no hidden implementation work is mixed in

Minimum evidence:

- inspected source of truth is named
- conclusion is bounded and specific

Minimum verification budget:

- none if no executable or doc changes occur
- one directly affected proof only if the audit updates a tiny test/doc seam

Safe to build on when:

- the audit conclusion is specific enough to guide the next bounded slice

### 3. Planning-Doc + Guard

Accepted means:

- the planning canon is updated
- one matching anti-gap or anti-jump guard is added or refined

Minimum evidence:

- the guard checks a real claim from the planning canon
- the doc and guard use the same vocabulary

Minimum verification budget:

- one directly affected targeted suite
- `flutter analyze` only if executable test/helper code changed

Safe to build on when:

- the canon is machine-checkable for the intended claim

### 4. Content-Only

Accepted means:

- bounded content changes land on an existing supported surface
- content is structurally valid and aligned with the current authoring contract

Minimum evidence:

- content files and manifests stay coherent
- the targeted content path is identifiable and intentional

Minimum verification budget:

- one directly affected targeted suite if a real content-backed test exists
- `flutter analyze` only if executable code changed alongside content

Safe to build on when:

- the new content is real, coherent, and exercised by the intended slice proof

### 5. Bounded Runtime / Content Slice

Accepted means:

- one real product slice works on its intended surface
- the slice stays within its declared seam and scope

Minimum evidence:

- one real user-visible effect is proven
- no known compile/analyze regressions remain

Minimum verification budget:

- `flutter analyze`
- one directly affected targeted suite
- no unrelated suites unless a directly affected seam proves otherwise

Safe to build on when:

- the slice is green on its direct proof and no analyzer issues remain

### 6. Surface Rollout / Pilot Slice

Accepted means:

- a new pilot or new visible surface is live in a bounded way
- intro/practice/review or equivalent bounded loop is coherent

Minimum evidence:

- the surface is actually reachable
- the pilot is not just infrastructure without visible user effect

Minimum verification budget:

- `flutter analyze`
- one directly affected targeted suite
- one extra directly affected suite only if the first proof exposes a second real seam dependency

Safe to build on when:

- the pilot is reachable, deterministic, and bounded

### 7. Truth / Status Update Tied To Real Evidence

Accepted means:

- a truth-map or status change reflects an already-proven runtime or structural change

Minimum evidence:

- the status change is justified by a real proof, not by aspiration
- the related truth/dev surfaces are updated consistently

Minimum verification budget:

- `flutter analyze` if executable code changes
- one directly affected targeted suite for the underlying runtime or truth seam
- one additional directly affected truth/dev-hub suite only if the status is surfaced there

Safe to build on when:

- the status/readiness label is honest and supported by direct evidence

## Verification Discipline

### Smallest Sufficient Verification

Default rule:

- run the smallest set of checks that can actually falsify the slice claim

Practical defaults:

- doc-only: no tests
- proof-only: no tests unless the proof itself changes executable seams
- runtime/content slice: `flutter analyze` + one targeted suite
- broader surface work: only justified extra checks

### No Big Bang Validation By Default

Do not:

- run large unrelated suites for a tiny bounded slice
- treat broad test spam as a substitute for slice precision

Do:

- add one extra suite only when the first direct proof exposes a second directly affected seam

### Determinism Rule

Acceptance should rely on:

- deterministic runtime behavior
- deterministic content loading
- deterministic targeted tests

If the only evidence is flaky or manual-only, the slice is not yet a strong base for follow-up work.

## Promotion And Build-On Relation

This ladder works with the status/readiness policy:

- acceptance decides whether a slice is good enough to land
- status/readiness decides how honestly the system should classify what landed

Practical rule:

- a slice can be accepted without being promoted to the strongest status
- build-on is allowed when the acceptance proof matches the claimed scope
- status promotion is allowed only when the policy evidence threshold is met

Examples:

- a bounded pilot slice can be accepted and still remain `pilotLive`
- a host alignment can be accepted first, then promoted from `productionLiveLegacy` to `productionLiveModernized` only after direct proof
- a scaffolded world shell can be accepted structurally without being treated as dense or live

## What Should Block Acceptance

Do not close a slice as accepted if:

- the proof does not actually touch the claimed seam
- analyzer errors remain for executable changes
- the visible user effect is still only assumed
- a truth/status promotion is optimistic rather than evidenced
- the diff quietly broadened beyond the declared slice

## Practical Anti-Chaos Rules

- no Big Bang validation
- smallest sufficient verification
- no unrelated test spam
- preserve determinism
- prefer honest acceptance over optimistic closure
- if the first targeted proof fails because a second seam is directly affected, add only that extra seam proof
- if a slice cannot be proven cleanly, stop at the narrowest verified blocker

## Near-Term Implication

Future implementation prompts should reference this ladder when they specify:

- slice type
- expected evidence
- verification budget
- promotion/build-on expectations

Future rollout should use this ladder instead of inventing new acceptance rules every turn.
