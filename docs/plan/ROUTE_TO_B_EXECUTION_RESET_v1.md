# Route To B Execution Reset v1
Status: ACTIVE
Purpose: reset execution truth for the publish-ready push after readiness
authority moved from the historical beta-path model to the main-first
final-product model.
Last updated: 2026-04-01

## Authority

Use this document for:

- the current A -> B gap map
- the current execution mode
- the locked Route to B block order
- the next active implementation block

On conflicts about execution mode, block sizing, or near-term route order, this
document overrides older micro-step sequencing in:

- `docs/ROADMAP_FINAL_100_SSOT.md`
- older `_reviews/` direction-lock artifacts
- repo habits that still default to tiny local slices without current bottleneck
  proof

It does not replace product invariants from `docs/plan/MASTER_PLAN_v2.2.md` or
readiness scoring from `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`.

## Evidence Basis

- `docs/plan/MASTER_PLAN_v2.2.md`
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
- `docs/plan/BETA_SHIP_RUNBOOK_CHECKLIST_v1.md`
- current canonical early-path correctness proof on `main`
- current monetization, store-package, release, and ops truth already present in
  repo docs and tests

## Current A -> B Diagnosis

### Closed Enough / Structurally Strong

- the canonical early-path route/action/content truth is materially stronger
  than the historical beta-era baseline
- runner/continuation truth is no longer the highest-EV reopen target by
  default
- the beta ship runbook remains useful as a bounded operational artifact for the
  canonical early learner path

### Strongest Remaining Gap

- final-product readiness is materially lower than the historical beta-path
  score because identity, onboarding/trust, packaging, distribution, and
  full-product release-confidence layers remain open
- the active control-plane bottleneck is stale readiness authority
- once this doc-only wave lands, the strongest implementation bottleneck becomes
  the `I/J -> K -> L/M/N` chain from
  `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`

### What No Longer Wins By Default

- more victory-lap micro-steps on the already-strong canonical beta slice
- more local route/runner cleanup without evidence that it is the top bottleneck
- reusing the historical beta-path score as if it were the current final score

## Execution Mode Reset

The project still executes by bounded waves, not by default micro-steps.

### Active Rules

1. Prefer the largest safe bounded wave that removes one whole bottleneck
   family.
2. Work one strongest bottleneck block at a time.
3. Use one mission prompt per active block.
4. A bounded wave may span docs, validators, runtime, content, and targeted
   tests when all touched surfaces serve the same bottleneck family.
5. Run 1-2 waves, then reassess against the current readiness frontier before
   opening another block.
6. Prefer class-of-issues fixes over local symptom fixes.
7. Use micro-steps only when the medium/large bounded wave is unsafe or
   evidence-incomplete.
8. Closed lanes stay closed unless concrete new evidence reopens them.

### Verification Discipline

- keep the PRE-clean requirement, but a clean detached worktree is acceptable
  when the main checkout is dirty
- use minimum-sufficient verification for the actual changed block
- verify the block against the active readiness frontier and exact bottleneck
  removal, not generic "more progress" language

## Locked Route To B

### Block 1: Main-First Final-Readiness SSOT / Authority Migration

Objective:

- land one canonical readiness authority that recalibrates current `main`
  against full-product readiness instead of historical beta-path readiness

Scope shape:

- doc-chain migration
- scoring-model migration
- historical demotion of the old beta-path SSOT
- aligned tests/guards for the active control plane

Why this block is first:

- the current strongest bottleneck is stale readiness authority
- the rest of the route should not execute against the wrong score meaning

### Block 2: Onboarding / Identity / Trust Closure Wave

Objective:

- close the `I` and `J` prerequisite chain so the product's promise, first
  session, and emotional layer are strong enough for honest packaging

Scope shape:

- first-session trust and aha
- compact identity/persona integration
- cross-surface product promise coherence

Why this block is second:

- `K`, `L`, and parts of `M/N` should not close ahead of identity/trust truth

### Block 3: Monetization / Distribution Truth Wave

Objective:

- close the `K` and `L` chain so monetization/value packaging and store
  packaging become real instead of partially documented or placeholder-backed

Scope shape:

- entitlement/package convergence
- verified commerce flow truth
- real store metadata/legal/support completion
- submission-grade distribution packaging

Why this block is third:

- once `I/J` are stronger, this becomes the highest-EV downstream closure family

### Block 4: Final Production / Ops Confidence Sweep

Objective:

- widen release confidence from bounded beta proof to whole-product final-launch
  confidence

Scope shape:

- full-product release gate coverage
- governed dashboards and ops loops
- explicit go/hold/rollback truth for final launch

Why this block is fourth:

- it should be applied to a stabilized product/packaging layer, not to a still
  moving upstream truth

## Stop / Reassess Logic

- Reassess after each block.
- Mandatory reassess after two waves even if momentum is strong.
- Do not start a new feature lane while the active block is unresolved.
- If a block proves unsafe at the chosen scope, shrink once to the next-largest
  safe bounded wave inside the same bottleneck family.
- Do not fall back to arbitrary micro-slices by habit.

## Next Strongest Implementation Block

The next active block is:

- `Main-First Final-Readiness SSOT / Authority Migration`

Immediately after that wave lands:

- reassess against `I`, `J`, `K`, `L`, `M`, and `N`
- do not reuse the historical beta-path score as the next-route selector
