# PROJECT_READINESS_EPICS_SSOT_v1
Status: REFERENCE
Purpose: auxiliary launch-readiness reference for release/store-prep framing on current product.
Last updated: 2026-04-02

Current calibration basis for this version:

- `branch=main`
- `HEAD=ff489a229e86c5ec0940cf037c2024ae2a4d7367`
- `origin/main=ff489a229e86c5ec0940cf037c2024ae2a4d7367`
- clean tree before wave: `yes`

## Purpose / scope

This document is no longer the active day-to-day product authority.

Use `docs/plan/MASTER_PLAN_v3.0.md` for:

- what to build next
- product bottleneck selection
- day-to-day route order
- bounded-wave prioritization

Use this document only for:

- launch/store-prep readiness framing
- broad release checklists
- historical completeness/reference context

It replaces the older beta-path release-readiness model as the canonical source
for:

- what `100%` means
- how readiness is scored
- which blocks are foundational versus downstream
- which epics are actually blocking rollout
- which bottlenecks should be worked next

This document is deliberately broader than:

- `docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md`
- `docs/ROADMAP_FINAL_100_SSOT.md`

Do not use this document as the default driver for current product work.

Use `docs/plan/WORLD_READINESS_REGISTRY_v1.md` for subordinate world-level
quality/control visibility, route-selection support, and per-world
release-grade notes.

Use `docs/plan/PRODUCT_SURFACE_READINESS_v1.md` for subordinate learner-facing
surface-quality visibility, first-user spine quality truth, and future
surface-wave route selection.

Use `docs/ROADMAP_FINAL_100_SSOT.md` for milestone and backlog sequencing.

Use `docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md` only as a historical record of
the earlier beta-capable A-G calibration.

Authority rule:

- `docs/plan/MASTER_PLAN_v3.0.md` wins for active product decisions, next-wave selection, and product bottleneck choice.
- This document is advisory/reference-only unless the question is specifically about launch/readiness framing.

Registry rule:

- this document no longer acts as the top bottleneck authority for daily product work
- the world registry and product-surface layers remain supporting references
- active product routing should flow through `docs/plan/MASTER_PLAN_v3.0.md`

Scope rule:

- This is a main-first audit model.
- Readiness is recalibrated from current repo truth, not inherited from older summary percentages.
- Beta-capable progress is real progress, but it is not the same thing as full-product final readiness.

## Definition of true 100%

True `100%` means the shipped product is genuinely complete, trustworthy, and
ready for broad public distribution.

It means all of the following are true at the same time:

- the core learner experience is structurally sound, poker-truthful, and
  pedagogically credible
- the product feels like one coherent product rather than a stitched set of
  subsystems
- first-session framing, identity, and trust are strong enough to support mass
  distribution
- monetization and value packaging amplify an already-valuable product instead
  of compensating for missing value
- store/distribution packaging is complete, real, and free of placeholders
- release confidence, telemetry, and operational confidence are strong enough to
  support real launch and iteration

True `100%` does not mean theoretical perfection.

True `100%` does mean:

- no unresolved hard blockers in active scope
- no placeholder launch packaging or fake-complete commercial surfaces
- no dependency layer being declared closed before its prerequisites are real
- no final-readiness claim that depends on beta-only interpretation

## Core vs Ship vs Final readiness model

The project now tracks three explicit readiness layers.

`Core Product Readiness`

- Measures whether the product itself is structurally real, learner-trustworthy,
  coherent, and valuable.
- Includes blocks `A` through `J`.
- A product can be materially strong here without yet being ready for mass
  distribution.

`Ship / Distribution Readiness`

- Measures whether the product can honestly be packaged, commercialized,
  distributed, observed, and released with confidence.
- Includes blocks `K` through `N`.
- This layer is downstream from the core product and must not be closed ahead of
  it.

`Final Product Readiness = Core + Ship/Distribution complete`

- Final readiness is the full weighted score across all active blocks.
- It is not allowed to reach `100%` unless both the core-product layer and the
  ship/distribution layer are fully complete.
- A strong bounded beta slice may still coexist with a materially lower final
  readiness score if shipping/distribution layers remain incomplete.

Current audited snapshot on current `main` from the registry below:

- Core Product Readiness: `65.9 / 100`
- Ship / Distribution Readiness: `49.7 / 100`
- Final Product Readiness: `62.0 / 100`

Interpretation:

- The repo is materially stronger on product core than on shipping/distribution
  closure.
- The older historical `85/100` beta-path score is not comparable to this
  broader final-product model and must not be reused as the current final score.
- These are governance-calibrated reporting values rounded to one decimal
  place, not measurement-grade claims of objective precision.

## Layered readiness architecture

The project uses a layered model so downstream work can progress honestly
without pretending to be closed too early.

### Layer 0. Foundation truth

Blocks:

- `A Structural / Canonical Ownership`
- `C Table / Action / Betting Truth`
- `E Content-Runtime Alignment`
- `H Anti-Recurrence / Guards / Audit Truth`

Role:

- These blocks establish whether the product has one canonical structural truth,
  poker-truth correctness, content/runtime alignment, and recurrence-resistant
  proof.

Prerequisite type:

- Hard prerequisite for most later work.

### Layer 1. Experience coherence

Blocks:

- `B Runner Consistency / UX Invariants`
- `D Feedback / Explanation Quality`
- `F Learning Effect / Pedagogy`
- `J Onboarding / Trust / First-Session Framing`

Role:

- Turns the correct product into a believable learner experience.

Prerequisite type:

- Depends on Layer 0.
- `J` also depends softly on `I` once identity work becomes real.

### Layer 2. Product coherence and promise

Blocks:

- `G Cross-World Product Consistency`
- `I Product Identity / Persona / Emotional Layer`

Role:

- Makes the product read as one product with one promise and one emotional
  language.

Prerequisite type:

- Depends on Layers 0 and 1.
- `I` should not be closed before enough of `F` and `G` are real.

### Layer 3. Commercial/value packaging

Blocks:

- `K Monetization / Value Packaging`

Role:

- Converts product value into honest packaging and entitlement behavior.

Prerequisite type:

- Hard prerequisite: `F`, `I`, and `J` must be real enough that monetization is
  amplifying value rather than rescuing a weak product.
- Soft prerequisite: `G` should be strong enough that packaging is coherent
  across the product.

### Layer 4. Ship surfaces and release confidence

Blocks:

- `L Store / Distribution / Launch Packaging`
- `M Production / Release Confidence`
- `N Analytics / Operational Confidence`

Role:

- Makes the finished product packageable, releasable, observable, and
  maintainable.

Prerequisite type:

- `L` hard-depends on `I`, `J`, and `K`.
- `M` hard-depends on `H` and representative closure across `A` through `J`;
  it may progress in parallel but cannot honestly close before those layers are
  strong enough.
- `N` hard-depends on `H`; it soft-depends on `J`, `K`, and `M` because
  analytics without governed product/release questions become noise.

### Parallel-capable work

These lanes may progress in parallel when they do not violate prerequisites:

- `I` and `J`
- `K` hardening and `M` gate expansion
- `N` telemetry/ops cleanup alongside `M`

### Explicit unlock rules

- `A`, `C`, `E`, and `H` unlock honest closure in `B`, `D`, `F`, `J`, and `M`.
- `B`, `D`, and `F` unlock honest closure in `G` and `J`.
- `F`, `G`, and `J` unlock honest closure in `I`.
- `I` plus `J` unlock honest closure in `K` and `L`.
- `K` unlocks honest commercial/store closure in `L`.
- `L`, `M`, and `N` together unlock a final mass-distribution claim.

### Running-ahead prevention rules

- Monetization/value packaging must not be declared closed before the product
  has enough value, trust, and identity to justify it.
- Store/distribution packaging must not be declared closed while product promise
  or store/legal metadata still contain placeholders or unresolved ambiguity.
- Production/release confidence must not be declared closed while it is still
  beta-slice-only or while final-product gates remain undefined.

## Fixed readiness blocks

Core Product Readiness blocks:

- `A Structural / Canonical Ownership` — canonical route, entry, continuation,
  and structural ownership truth
- `B Runner Consistency / UX Invariants` — shared behavior across runner/result
  surfaces and route-adjacent UX invariants
- `C Table / Action / Betting Truth` — poker legality, action availability,
  reveal/street correctness, and betting truth
- `D Feedback / Explanation Quality` — wrong-answer specificity, clarity, and
  explanation usefulness
- `E Content-Runtime Alignment` — content manifests, loaders, validators, and
  runtime behavior agree
- `F Learning Effect / Pedagogy` — the learner actually learns and the product
  teaches effectively
- `G Cross-World Product Consistency` — worlds and active families behave as one
  product
- `H Anti-Recurrence / Guards / Audit Truth` — recurrence guards, audits, and
  control-plane truth keep regressions from silently reopening
- `I Product Identity / Persona / Emotional Layer` — product promise, Sharky
  identity, and emotional continuity
- `J Onboarding / Trust / First-Session Framing` — first-open, intake, trust,
  aha, and first-session framing quality

Ship / Distribution Readiness blocks:

- `K Monetization / Value Packaging` — entitlement, offer/value packaging, and
  monetization timing truth
- `L Store / Distribution / Launch Packaging` — store assets, metadata, legal
  placeholders, and submission package completeness
- `M Production / Release Confidence` — gating, smoke paths, rollback/go-no-go
  discipline, and release confidence
- `N Analytics / Operational Confidence` — telemetry, dashboards, low-ops
  burden, and operational decision confidence

Epic scope tags used in the registry:

- `core` = primarily closes core-product strength inside the current readiness
  model
- `ship` = primarily closes ship/distribution readiness
- `final` = primarily closes whole-product or distribution-grade completeness
  beyond bounded core strength
- `multi` = cross-layer prerequisite or governance surface that materially spans
  more than one readiness layer

Scope rule:

- scope is routing/reporting metadata for honesty and prioritization
- scope does not override the block that owns the epic
- scope does not create a second hidden scoring formula in v1

Block weights for future reporting:

- `A=7`
- `B=7`
- `C=10`
- `D=8`
- `E=8`
- `F=8`
- `G=6`
- `H=7`
- `I=4`
- `J=5`
- `K=8`
- `L=8`
- `M=8`
- `N=6`

Weight-governance rule:

- these are governance weights for readiness reporting and route selection, not
  objective natural law
- they express the current version's judgment about relative readiness impact
- weight drift is not allowed through casual edits
- changing block weights requires a new versioned readiness SSOT revision with
  explicit rationale

Core weight total: `70`

Ship/distribution weight total: `30`

## Status model

Allowed statuses:

- `not_started`
- `in_progress`
- `blocked`
- `proof_pending`
- `human_proof_pending`
- `done`
- `deferred`

Status rules:

- `done` requires the definition of done plus all required machine proof and all
  required human proof.
- `proof_pending` means implementation or authored closure exists, but machine
  proof is incomplete for the level of confidence this epic requires.
- `human_proof_pending` means machine-side confidence is sufficient to proceed,
  but the required human validation is still open.
- `human_proof_pending` may remain open without blocking unrelated work if the
  epic is not itself a blocker.
- `blocked` means forward progress is materially constrained by another missing
  dependency, unresolved blocker, or unavailable proof path.
- `in_progress` means active closure work is underway but the epic is not yet at
  proof floor.
- `not_started` means the scope is admitted but not yet materially worked.
- `deferred` means the scope exists but is out of current active scoring unless
  it is explicitly brought back in scope.
- a downstream epic may remain `done` while an upstream dependency is still
  `proof_pending` or `human_proof_pending` only when the missing proof does not
  contradict the downstream claim and the notes explicitly say why

No epic may be marked `done` merely because the implementation looks complete.

## Blocking model

Allowed blocking levels:

- `hard_blocker`
- `soft_blocker`
- `non_blocking`

Blocking rules:

- `hard_blocker` means the epic blocks honest closure of one or more downstream
  epics or blocks.
- `soft_blocker` means the epic materially reduces downstream confidence or
  honesty but does not fully prevent unrelated work.
- `non_blocking` means the epic matters for score and completeness but does not
  currently control the route.

A block cannot be declared `100%` while any in-scope `hard_blocker` epic in that
block remains unresolved.

Final readiness cannot be declared `100%` while any required ship/distribution
hard blocker remains unresolved.

Block closeout rules:

- a block may be treated as `100%` only when every required in-scope epic in
  that block is `done`
- no unresolved in-scope `hard_blocker` remains inside the block
- required machine proof is complete for every required epic
- required human proof is complete where the epic mandates it
- no conflicting repo truth remains for the claimed closure
- the closeout report states block-level confidence explicitly instead of
  inferring it from score alone

## Proof model

Every epic must define both machine proof and human proof requirements.

`Machine proof`

- deterministic tests
- targeted audits
- validator output
- script/report output
- repo-state artifacts that directly prove the claimed closure

`Human proof`

- device walkthroughs
- visual/product review
- store-console/manual packaging checks
- pedagogical review where the repo alone cannot prove learner trust

Proof rules:

- machine proof should be the default whenever the claim is deterministic enough
  to guard
- human proof is still required where product trust, store packaging, or
  pedagogy cannot honestly be inferred from automation alone
- lack of human proof does not erase real implementation progress, but it does
  prevent `done`

## Scoring model

State weights:

- `done = 1.00`
- `human_proof_pending = 0.85`
- `proof_pending = 0.70`
- `in_progress = 0.40`
- `blocked = 0.20`
- `not_started = 0.00`
- `deferred = excluded from active-scope scoring unless explicitly in scope`

Score-reporting rule:

- scores are governance outputs derived from the registry states below
- they are reported to one decimal place for comparability, not as a claim that
  readiness has sub-point scientific precision

Scoring method:

1. Epic raw score
   - Take the state weight for the epic status.
2. Block raw score
   - Average the raw scores of the block's active epics.
3. Block effective score
   - Start from block raw score.
   - Apply only the minimum closure cap needed for honesty:
     - if hard prerequisites are not sufficiently real, the block may not report
       beyond `in_progress` effective closure (`0.40`)
     - if the implementation exists but hard-proof floor is incomplete, the
       block may not report beyond `proof_pending` effective closure (`0.70`)
     - if only required human proof is open, the block may not report beyond
       `human_proof_pending` effective closure (`0.85`)
   - Raw progress is still retained for planning, but effective score is the
     reporting score.
4. Core Product Readiness
   - Weighted average of effective scores across blocks `A` through `J`,
     normalized to `100`.
5. Ship / Distribution Readiness
   - Weighted average of effective scores across blocks `K` through `N`,
     normalized to `100`.
6. Final Product Readiness
   - Weighted average of effective scores across all blocks using the fixed
     block weights above.

Why this model is used:

- it preserves real progress already made in downstream layers
- it prevents fake closure when prerequisites are still missing
- it avoids the dishonest pattern where a beta-ready product is treated as
  final-ready simply because core blocks are strong

Current block scores from the registry below:

- `A=0.85`
- `B=0.75`
- `C=0.80`
- `D=0.55`
- `E=0.80`
- `F=0.55`
- `G=0.35`
- `H=0.85`
- `I=0.33`
- `J=0.47`
- `K=0.47`
- `L=0.37`
- `M=0.70`
- `N=0.43`

Current rolled-up scores:

- Core Product Readiness = `65.9 / 100`
- Ship / Distribution Readiness = `49.7 / 100`
- Final Product Readiness = `62.0 / 100`

## Update protocol

When updating this document:

1. Re-audit current repo truth first.
2. Change epic state only when the epic itself moved.
3. Update dependencies/unlocks when the graph changed, not when rhetoric
   changed.
4. Add proof references or notes for every materially changed epic.
5. Recompute block, core, ship, and final scores from the new epic states.
6. Record the exact date of recalibration.
7. If any accepted epic is downgraded, document the exact contradictory repo
   truth or the exact SSOT-definition change that forced it.

Score-discipline rules:

- no percentage rises unless at least one epic state actually changed
- rebucketing or renaming epics must be score-neutral on the rebucket turn
  unless actual state movement also occurred
- closed seams should not be reopened without concrete new evidence
- if current `main` changes materially, re-admit against actual repo truth
  instead of reusing older percentages
- already accepted epic progress may not be downgraded because the model became
  rhetorically stricter; downgrade only on contradictory repo truth or explicit
  definition change, and record the reason in the epic notes or recalibration
  summary

## Reporting protocol

Future reporting must use the following format:

1. Exact readiness SSOT version path, audit date, branch, and `HEAD`
2. Previous readiness report reference: exact date plus `HEAD`
3. Core Product Readiness: previous -> current, with delta
4. Ship / Distribution Readiness: previous -> current, with delta
5. Final Product Readiness: previous -> current, with delta
6. Block movement:
   - which blocks moved
   - raw score change
   - effective score change
7. Epic movement:
   - exact epic IDs that changed state
   - old status -> new status
8. Raw vs effective readiness notes for any block whose effective score is
   capped by prerequisites or proof floor
9. Active bottleneck:
   - one top bottleneck block
   - one top bottleneck epic
10. Parallel-capable next work
11. Hard blockers still open
12. Explicit "must not be declared closed yet" list

Use exact dates, not vague relative dates, whenever there is any risk of
timeline ambiguity.

## Block-by-block epic registry

Registry framing:

- this registry is the v1 honest baseline, not a claim that decomposition is
  complete forever
- the registry is intentionally expandable and has no artificial epic cap per
  block
- additional epics must be added when repo truth reveals genuinely distinct
  work, blockers, or proof surfaces
- tidy symmetry is not a validity rule; if one block needs more epics than
  another, the registry should reflect that honestly

### A Structural / Canonical Ownership
Layer: Core foundation
Current score: `0.85`

#### A1. Canonical first-user landing and continuation ownership
- id: A1
- title: Canonical first-user landing and continuation ownership
- scope: core
- status: done
- definition_of_done: Boot, onboarding/intake, Today, map, and immediate continuation resolve from one canonical decision path with no contradictory active-route owner.
- dependencies: []
- unlocks: [B1, J1, M1]
- blocking_level: hard_blocker
- machine_proof: `test/guards/world_campaign_map_home_contract_test.dart`, `test/guards/onboarding_legacy_completion_boot_parity_contract_test.dart`
- human_proof: Fresh-install and returning-user walkthrough on the canonical early path.
- notes: Status retained as `done` in the 2026-04-01 hardening audit because current guard-backed canonical route ownership shows no contradictory repo truth and the open later whole-product ownership work sits in `A3`, not here.

#### A2. Canonical runner -> result -> review ownership
- id: A2
- title: Canonical runner -> result -> review ownership
- scope: core
- status: human_proof_pending
- definition_of_done: Session result, review, retry, and continuation ownership no longer drift across the active learner path.
- dependencies: [A1]
- unlocks: [B2, J1, M1]
- blocking_level: hard_blocker
- machine_proof: `test/guards/session_result_spine_continuation_parity_contract_test.dart`, `lib/ui_v2/screens/session_result_screen.dart`
- human_proof: Manual cross-device walkthrough of result/review/retry behavior on the primary path.
- notes: Machine-side parity is strong; broader manual proof is still required.

#### A3. Extended-surface structural ownership registry
- id: A3
- title: Extended-surface structural ownership registry
- scope: final
- status: proof_pending
- definition_of_done: Later-world and non-canonical entry surfaces have explicit ownership mappings with no unresolved active-owner ambiguity.
- dependencies: [A1, A2]
- unlocks: [G2, M2]
- blocking_level: soft_blocker
- machine_proof: Ownership/audit docs plus route-guard coverage for admitted surfaces.
- human_proof: Spot-check later-world entry surfaces after ownership registry refresh.
- notes: The bounded beta slice is strong; full-product ownership proof is not yet complete.

### B Runner Consistency / UX Invariants
Layer: Core experience coherence
Current score: `0.75`

#### B1. Canonical early-path runner invariants
- id: B1
- title: Canonical early-path runner invariants
- scope: core
- status: done
- definition_of_done: The core runner family shares stable entry, state, exit, and continuation invariants across the canonical learner path.
- dependencies: [A1, A2]
- unlocks: [F1, J1]
- blocking_level: hard_blocker
- machine_proof: `test/guards/world1_readiness_smoke_contract_test.dart`, `lib/ui_v2/screens/session_drill_player_v1_screen.dart`, `lib/ui_v2/screens/drill_runner_screen.dart`
- human_proof: Manual playthrough of the canonical runner family.
- notes: Status retained as `done` in the 2026-04-01 hardening audit because canonical runner invariants are already guard-backed on admitted scope; the still-open proof in `A2` concerns broader result/review confirmation, not a direct contradiction to this epic.

#### B2. Result/review invariant parity across active runner families
- id: B2
- title: Result/review invariant parity across active runner families
- scope: core
- status: human_proof_pending
- definition_of_done: Similar runner families resolve result/review affordances through the same UX invariants instead of family-specific exceptions.
- dependencies: [A2, B1]
- unlocks: [G1, G2]
- blocking_level: soft_blocker
- machine_proof: `test/guards/session_result_spine_continuation_parity_contract_test.dart`
- human_proof: Manual parity check across active runner families.
- notes: Canonical-path parity is strong, but broader family confirmation is still partly manual.

#### B3. Broader active-family invariant normalization
- id: B3
- title: Broader active-family invariant normalization
- scope: final
- status: in_progress
- definition_of_done: Broader active runner families outside the canonical beta slice obey the same invariant set without special-case residue.
- dependencies: [A3, B2]
- unlocks: [G2, M2]
- blocking_level: soft_blocker
- machine_proof: Expanded runner audit/guard coverage on non-canonical families.
- human_proof: Cross-family exploratory pass after machine proof expands.
- notes: This remains behind the early-path-strength baseline.

### C Table / Action / Betting Truth
Layer: Core foundation
Current score: `0.80`

#### C1. Canonical early-path legal action truth
- id: C1
- title: Canonical early-path legal action truth
- scope: core
- status: done
- definition_of_done: Available actions, to-call truth, and outcome legality are correct on the canonical learner path.
- dependencies: []
- unlocks: [D1, F1, M1]
- blocking_level: hard_blocker
- machine_proof: `test/tools/canonical_early_path_correctness_audit_v1_test.dart`, table/action guard coverage on current `main`
- human_proof: Manual sanity pass on the canonical early path.
- notes: The canonical early-path correctness audit is clean.

#### C2. Street, board, and reveal truth on admitted active families
- id: C2
- title: Street, board, and reveal truth on admitted active families
- scope: core
- status: proof_pending
- definition_of_done: Street transitions, reveal state, and visible board truth stay aligned on all admitted active families.
- dependencies: [C1]
- unlocks: [D2, G2]
- blocking_level: hard_blocker
- machine_proof: World/session validators and table-projection audits across admitted families.
- human_proof: Representative manual inspection of reveal-heavy flows.
- notes: Repo evidence is good, but not yet closed enough to call fully done at whole-product scope.

#### C3. Cross-world action/betting truth scale-out
- id: C3
- title: Cross-world action/betting truth scale-out
- scope: final
- status: proof_pending
- definition_of_done: Cross-world action, betting, and outcome truth is proven beyond the canonical early slice.
- dependencies: [C1, C2]
- unlocks: [G2, M2]
- blocking_level: hard_blocker
- machine_proof: Additional world validators and audit outputs across active worlds.
- human_proof: Spot checks on later/high-variance families.
- notes: Stronger than weak/invented debt, but not fully closed for final-readiness purposes.

### D Feedback / Explanation Quality
Layer: Core experience coherence
Current score: `0.55`

#### D1. Canonical-path feedback floor
- id: D1
- title: Canonical-path feedback floor
- scope: core
- status: human_proof_pending
- definition_of_done: Wrong-answer feedback on the canonical learner path is specific, scenario-first, and no longer trust-breaking.
- dependencies: [C1, E1]
- unlocks: [F1, J2]
- blocking_level: hard_blocker
- machine_proof: `test/tools/early_world_feedback_quality_generic_template_wave_test.dart`, `test/tools/worlds1_3_gold_spine_preflop_chain_feedback_wave_test.dart`
- human_proof: Human review of explanation quality and tone on the canonical early path.
- notes: Stronger than the historical baseline, but still not final-product-closed.

#### D2. Cross-world explanation depth and specificity
- id: D2
- title: Cross-world explanation depth and specificity
- scope: core
- status: in_progress
- definition_of_done: Active worlds beyond the canonical early slice consistently explain why, not just what, with scenario-appropriate depth.
- dependencies: [C2, E2, D1]
- unlocks: [F2, G2]
- blocking_level: hard_blocker
- machine_proof: Expanded feedback-quality audits across active worlds.
- human_proof: Pedagogical review on representative later-world packs.
- notes: Repo truth still shows this as mixed, not closed.

#### D3. Weak/generic feedback family prevention at scale
- id: D3
- title: Weak/generic feedback family prevention at scale
- scope: multi
- status: in_progress
- definition_of_done: Tooling and audits catch generic, circular, or placeholder-like feedback patterns before they ship.
- dependencies: [D1, H1]
- unlocks: [F3, H3]
- blocking_level: soft_blocker
- machine_proof: Feedback-audit tooling and regression tests for weak-feedback families.
- human_proof: Periodic sampled review of audit misses.
- notes: Audit tooling exists, but whole-product closure is not yet proven.

### E Content-Runtime Alignment
Layer: Core foundation
Current score: `0.80`

#### E1. Canonical content bundle and runtime handoff truth
- id: E1
- title: Canonical content bundle and runtime handoff truth
- scope: core
- status: done
- definition_of_done: Canonical content bundles, loaders, and runtime paths agree on what the learner sees and plays.
- dependencies: [A1]
- unlocks: [D1, F1, J1]
- blocking_level: hard_blocker
- machine_proof: Content/runtime validator suite plus canonical path audits.
- human_proof: Representative learner-path walkthrough using canonical content packs.
- notes: Current `main` is materially strong here.

#### E2. Validator-backed active-world alignment
- id: E2
- title: Validator-backed active-world alignment
- scope: core
- status: proof_pending
- definition_of_done: Active-world content/runtime alignment is validator-backed beyond the bounded early slice.
- dependencies: [E1]
- unlocks: [C3, D2, F2]
- blocking_level: hard_blocker
- machine_proof: `docs/audit/M1_READINESS_AUDIT_v4.md`, world/session validator outputs, content QA tools
- human_proof: Sampled later-world validation review.
- notes: Good evidence exists, but final-product closure is still incomplete.

#### E3. Specialized-family content/runtime alignment
- id: E3
- title: Specialized-family content/runtime alignment
- scope: final
- status: proof_pending
- definition_of_done: Specialized packs, checkpoints, and active non-spine families stay aligned across authored content and runtime behavior.
- dependencies: [E2]
- unlocks: [G2, M2]
- blocking_level: soft_blocker
- machine_proof: Checkpoint and specialized-family validator coverage.
- human_proof: Sampled manual walkthrough of specialized families.
- notes: More proven than not, but not fully closed.

### F Learning Effect / Pedagogy
Layer: Core experience coherence
Current score: `0.55`

#### F1. Early-world learning loop usefulness
- id: F1
- title: Early-world learning loop usefulness
- scope: core
- status: human_proof_pending
- definition_of_done: The canonical early learner path teaches something tangible, preserves rhythm, and gives the learner believable improvement.
- dependencies: [B1, C1, D1, E1]
- unlocks: [J2, I1]
- blocking_level: hard_blocker
- machine_proof: Early-world feedback/explanation audits, canonical-path correctness audit, progression guards
- human_proof: Fresh-user and returning-user pedagogy walkthrough.
- notes: The early path is materially improved, but whole-product pedagogy is not done.

#### F2. Checkpoint and later-world pedagogy consistency
- id: F2
- title: Checkpoint and later-world pedagogy consistency
- scope: core
- status: in_progress
- definition_of_done: Checkpoints and broader worlds reinforce skill growth with coherent teaching value instead of isolated completion mechanics.
- dependencies: [D2, E2, G1]
- unlocks: [G2, I1]
- blocking_level: hard_blocker
- machine_proof: Checkpoint quality audits and later-world pedagogy tooling.
- human_proof: Pedagogical review across checkpoint and later-world families.
- notes: Still mixed.

#### F3. Teaching-value audit and anti-shallow-pedagogy guardrail
- id: F3
- title: Teaching-value audit and anti-shallow-pedagogy guardrail
- scope: multi
- status: in_progress
- definition_of_done: The repo has a governed audit path that detects shallow teaching patterns before they are treated as readiness progress, and learner-visible teaching copy stays natural enough to preserve comprehension and trust.
- dependencies: [D3, H1]
- unlocks: [K1, N2]
- blocking_level: soft_blocker
- machine_proof: Teaching-value audit tooling and deterministic report outputs.
- human_proof: Review of false-positive and false-negative audit behavior.
- notes: Useful signals exist, but closure is not yet final-grade. Learner-visible prompts, `why_v1`, and feedback can still read as understandable to internal authors while sounding too abstract or system-shaped to actual learners. That is a real product-quality problem, not cosmetic polish: it weakens clarity, trust, retention, learning effect, and accessibility for non-native English readers. Canonical learner-language contract lives in `docs/EXECUTION_RULES.md` and future F3/content waves must follow it without treating this governance pass as a trigger for a broad rewrite.

### G Cross-World Product Consistency
Layer: Core product coherence
Current score: `0.35`

#### G1. Worlds 1-3 canonical arc coherence
- id: G1
- title: Worlds 1-3 canonical arc coherence
- scope: core
- status: human_proof_pending
- definition_of_done: The canonical early arc reads as one coherent product journey rather than disconnected world slices.
- dependencies: [B2, D1, F1]
- unlocks: [I1, J2]
- blocking_level: soft_blocker
- machine_proof: Canonical early-path audits, progression/routing guards, beta runbook bounded scope
- human_proof: Manual continuity walkthrough from first entry through early continuation.
- notes: Downgraded from `done` to `human_proof_pending` in the 2026-04-01 hardening audit because the coherence claim still leans on open human-proof in `B2`, `D1`, and `F1`; the canonical arc is strong, but `done` overstated closure.

#### G2. Broader cross-world consistency beyond the canonical beta slice
- id: G2
- title: Broader cross-world consistency beyond the canonical beta slice
- scope: final
- status: blocked
- definition_of_done: Active worlds beyond the canonical early arc present one coherent product and progression language.
- dependencies: [A3, B3, C3, E3, F2]
- unlocks: [I2, M2]
- blocking_level: hard_blocker
- machine_proof: Expanded cross-world audits and consistency checks.
- human_proof: Product review of active-world progression continuity.
- notes: This is a real blocker for whole-product closure.

#### G3. Cross-track/world product-feel normalization
- id: G3
- title: Cross-track/world product-feel normalization
- scope: final
- status: not_started
- definition_of_done: Worlds and track-capable families no longer feel like separate products when viewed as a launchable whole.
- dependencies: [G2, I2]
- unlocks: [L1, L2]
- blocking_level: soft_blocker
- machine_proof: Cross-surface consistency inventory with resolved top divergences.
- human_proof: Launch-surface review across track/world transitions.
- notes: Not yet materially closed on current `main`.

### H Anti-Recurrence / Guards / Audit Truth
Layer: Core foundation
Current score: `0.85`

#### H1. High-EV regression guard coverage
- id: H1
- title: High-EV regression guard coverage
- scope: multi
- status: done
- definition_of_done: The highest-EV route, truth, and content regressions are guarded or audited deterministically.
- dependencies: []
- unlocks: [D3, F3, M1, N1]
- blocking_level: hard_blocker
- machine_proof: Policy-loop scripts, guard suites, targeted audit tests, `./tools/fast_loop_world1_v1.sh`
- human_proof: Periodic review that guard coverage still matches actual risk.
- notes: Strong on current `main`.

#### H2. Readiness control-plane continuity
- id: H2
- title: Readiness control-plane continuity
- scope: multi
- status: human_proof_pending
- definition_of_done: The active readiness authority, doc chain, tests, and agent instructions all point to one canonical readiness model.
- dependencies: [H1]
- unlocks: [M1, N2]
- blocking_level: hard_blocker
- machine_proof: Active doc/test/tool references point to this document and historical docs are demoted.
- human_proof: Spot-check that no active operational doc still treats the old beta model as current authority.
- notes: This wave closes the machine side; manual spot-check remains prudent.

#### H3. Final-readiness audit expansion beyond beta-only evidence
- id: H3
- title: Final-readiness audit expansion beyond beta-only evidence
- scope: multi
- status: proof_pending
- definition_of_done: Audit truth distinguishes bounded beta strength from full-product final readiness and keeps those claims from drifting together again.
- dependencies: [H1, H2]
- unlocks: [M2, N2]
- blocking_level: hard_blocker
- machine_proof: This SSOT plus aligned audit/reporting tests.
- human_proof: Review of future reporting for honesty against this model.
- notes: Landed in control-plane truth, but future operational behavior must still prove out.

### I Product Identity / Persona / Emotional Layer
Layer: Core product coherence
Current score: `0.33`

Block-split note:

- Keep `I` unified in v1 because product promise coherence and persona
  embodiment are still tightly coupled and currently share blockers and proof
  surfaces.
- Split `I` only in a future SSOT revision if repo truth shows persona
  embodiment and product-promise coherence have become independently large
  readiness surfaces with different blockers, proofs, or route owners.

#### I1. Compact Sharky persona integration
- id: I1
- title: Compact Sharky persona integration
- scope: core
- status: in_progress
- definition_of_done: Sharky exists as a compact coach/product layer in live product flow, not only as service-side or deferred skeleton work.
- dependencies: [F1, G1]
- unlocks: [I2, J2, K1]
- blocking_level: hard_blocker
- machine_proof: Live UI integration plus regression coverage for persona/emotional surfaces.
- human_proof: Product review that Sharky feels supportive rather than noisy.
- notes: Repo truth shows service-side and theme/persona groundwork, but not final integrated product closure.

#### I2. Coherent product promise and emotional language
- id: I2
- title: Coherent product promise and emotional language
- scope: multi
- status: in_progress
- definition_of_done: App surfaces, onboarding, recap, and external packaging share one product promise and one coherent emotional language.
- dependencies: [G2, I1, J2]
- unlocks: [K1, L2]
- blocking_level: hard_blocker
- machine_proof: Governed copy inventory with resolved top inconsistencies.
- human_proof: Product/brand review across in-app and distribution surfaces.
- notes: Canonical first-session product promise and compact Sharky continuity materially advanced on the admitted path, but cross-surface and distribution-grade proof remain open.

#### I3. Identity SSOT across visual and voice surfaces
- id: I3
- title: Identity SSOT across visual and voice surfaces
- scope: multi
- status: blocked
- definition_of_done: There is one governed identity layer covering tone, emotional reinforcement, and distribution-facing product language.
- dependencies: [I2]
- unlocks: [L1, L2]
- blocking_level: soft_blocker
- machine_proof: Identity inventory/SSOT with active-surface coverage.
- human_proof: Review that the identity is launchable and coherent.
- notes: Current repo truth is fragmented across deferred canon, service skeletons, and release copy docs.

### J Onboarding / Trust / First-Session Framing
Layer: Core experience coherence
Current score: `0.47`

#### J1. Canonical onboarding/intake/today route truth
- id: J1
- title: Canonical onboarding/intake/today route truth
- scope: core
- status: done
- definition_of_done: First-session routing through onboarding/intake/Today is canonical, deterministic, and non-contradictory on the active learner path.
- dependencies: [A1, B1, E1]
- unlocks: [J2, K1, M1]
- blocking_level: hard_blocker
- machine_proof: `lib/ui_v2/screens/universal_intake_plan_screen.dart`, onboarding/intake/home guards
- human_proof: First-open walkthrough.
- notes: Status retained as `done` in the 2026-04-01 hardening audit because the claim is structural route truth on the admitted first-session path; the still-open `J2` and `J3` work concerns trust quality and distribution-grade proof, not route ownership contradiction.

#### J2. First-session trust framing and aha quality
- id: J2
- title: First-session trust framing and aha quality
- scope: multi
- status: in_progress
- definition_of_done: The first meaningful session proves the product's value, preserves trust, and gives a believable reason to return.
- dependencies: [D1, F1, G1, I1]
- unlocks: [K1, I2, N2]
- blocking_level: hard_blocker
- machine_proof: Governed first-session rubric plus telemetry-backed first-session audit.
- human_proof: Bounded novice walkthrough focused on trust, clarity, motivation, and whether the first meaningful session creates a real aha.
- notes: Canonical first-session trust framing, aha reinforcement, and deterministic telemetry now exist on the admitted path, but bounded novice proof and wider distribution-grade proof remain open.

#### J3. Distribution-grade onboarding proof
- id: J3
- title: Distribution-grade onboarding proof
- scope: final
- status: not_started
- definition_of_done: First-session and onboarding quality are proven at the level required for public distribution, not just internal confidence.
- dependencies: [J2, L2, M2]
- unlocks: [L3, N2]
- blocking_level: soft_blocker
- machine_proof: Release-grade onboarding checklist and repeatable proof path.
- human_proof: Launch readiness review of first-session experience.
- notes: Not yet admitted as closed work.

### K Monetization / Value Packaging
Layer: Ship/commercial packaging
Current score: `0.47`

#### K1. Value-first monetization timing contract
- id: K1
- title: Value-first monetization timing contract
- scope: ship
- status: proof_pending
- definition_of_done: Monetization is governed by an explicit value-first/habit-first rule and is applied only where it does not outrun product value and trust.
- dependencies: [F1, J1]
- unlocks: [K2, L1]
- blocking_level: hard_blocker
- machine_proof: `docs/plan/MONETIZATION_TIMING_GUARD_v1.md`, `docs/plan/MASTER_PLAN_v2.2.md`
- human_proof: Product review that any active monetization surface obeys the timing rule.
- notes: The policy exists, but whole-product application is not fully proven.

#### K2. Unified entitlement and package truth
- id: K2
- title: Unified entitlement and package truth
- scope: ship
- status: proof_pending
- definition_of_done: Entitlement, trial, premium, and package behavior converge on one governed runtime truth instead of split stores and heuristic gates.
- dependencies: [K1, I2, J2]
- unlocks: [K3, L1, L2]
- blocking_level: hard_blocker
- machine_proof: `lib/services/entitlement_ssot_v1.dart`, `lib/services/subscription_status_v1.dart`, `docs/plan/MONETIZATION_SSOT_v1.md`, `test/services/subscription_status_v1_test.dart`, `test/services/trial_service_v1_test.dart`
- human_proof: Manual verification of premium/trial messaging on live product surfaces.
- notes: Canonical Today, premium-entry, entitlement, restore, and lifecycle-refresh truth materially converged on current main; live human verification on premium/trial surfaces remains open.

#### K3. Verified commerce flow and offer/value package closure
- id: K3
- title: Verified commerce flow and offer/value package closure
- scope: ship
- status: not_started
- definition_of_done: Purchase, restore, receipt verification, offer/package messaging, and entitlement delivery are launch-grade and no longer stubbed or placeholder-like.
- dependencies: [K2, L2, M2]
- unlocks: [L3, N3]
- blocking_level: hard_blocker
- machine_proof: Non-stub verification path, restore/purchase contract tests, package-copy closure.
- human_proof: End-to-end commerce review using store-ready builds.
- notes: Current repo truth still includes stub verification and unfinished package closure.

### L Store / Distribution / Launch Packaging
Layer: Ship/distribution
Current score: `0.37`

#### L1. Deterministic store asset pipeline and package artifact path
- id: L1
- title: Deterministic store asset pipeline and package artifact path
- scope: ship
- status: in_progress
- definition_of_done: Store assets, proof archives, and package assembly use one deterministic artifact path with aligned docs and tests.
- dependencies: [K1, H2]
- unlocks: [L2, M2]
- blocking_level: soft_blocker
- machine_proof: `docs/release/store_package_v1.md`, `docs/release/store_assets_v1.md`, `out/modern_table_screenshots_v1.zip`, `test/contracts/store_package_assets_contract_test.dart`
- human_proof: Manual review that the artifact set is actually usable for release packaging.
- notes: Pipeline proof exists, but it is not the same thing as a complete store package.

#### L2. Real metadata/legal/support/marketing closure
- id: L2
- title: Real metadata/legal/support/marketing closure
- scope: ship
- status: proof_pending
- definition_of_done: Store metadata, support URLs, marketing URLs, legal identity, and compliance details are real and no longer placeholder-driven.
- dependencies: [I2, K2, L1]
- unlocks: [L3, J3]
- blocking_level: hard_blocker
- machine_proof: Store package docs with placeholders removed and linked real assets.
- human_proof: Release-owner review in actual store submission materials.
- notes: Placeholder-driven launch/support/legal metadata was replaced by explicit ownership truth and unresolved-state policy, but release-owner review of actual submission materials remains open.

#### L3. Submission-ready distribution bundle
- id: L3
- title: Submission-ready distribution bundle
- scope: ship
- status: not_started
- definition_of_done: iOS and Android launch packages are complete, reviewable, and ready for actual submission without manual patchwork.
- dependencies: [L2, K3, J3, M2]
- unlocks: [final_launch_claim]
- blocking_level: hard_blocker
- machine_proof: Generated bundle/checklist artifacts with complete contents.
- human_proof: Final store-console submission dry run.
- notes: This is materially incomplete on current `main`.

### M Production / Release Confidence
Layer: Ship/release confidence
Current score: `0.70`

#### M1. Policy-gated validation loop aligned to current repo truth
- id: M1
- title: Policy-gated validation loop aligned to current repo truth
- scope: multi
- status: done
- definition_of_done: The default fast loop, release gate, and checkpoint cadence are defined and usable for the current repo.
- dependencies: [A1, H1, H2]
- unlocks: [M2, N1]
- blocking_level: hard_blocker
- machine_proof: `AGENTS.md`, `./tools/fast_loop_world1_v1.sh`, `./tools/release_gate_world1.sh`, `./tools/checkpoint_world1_v1.sh`
- human_proof: Verification that active contributors can follow the documented loop.
- notes: This is real and active.

#### M2. Final-product release gate coverage
- id: M2
- title: Final-product release gate coverage
- scope: ship
- status: proof_pending
- definition_of_done: Release-confidence proof covers the full final-product scope, not only the bounded beta slice.
- dependencies: [A3, C3, G2, H3, L1]
- unlocks: [M3, K3, L3]
- blocking_level: hard_blocker
- machine_proof: Full-product release checklist, smoke path, and gate coverage aligned to this SSOT.
- human_proof: Release-owner review that the gate scope matches the actual product.
- notes: Current main now has a bounded executable release smoke family plus explicit release-confidence owners, but the verdict remains HOLD and whole-product breadth/human proof are still open.

#### M3. Repeatable go/no-go, rollback, and release discipline
- id: M3
- title: Repeatable go/no-go, rollback, and release discipline
- scope: ship
- status: in_progress
- definition_of_done: The project has a repeatable release decision protocol with explicit go/hold/rollback truth for full-product launch, not only bounded beta shipment.
- dependencies: [M2, N2]
- unlocks: [final_launch_claim]
- blocking_level: hard_blocker
- machine_proof: Aligned release docs, runbooks, and decision artifacts.
- human_proof: Dry-run release review with explicit go/hold outcome.
- notes: Elements exist, but full-product closure is not yet proven.

### N Analytics / Operational Confidence
Layer: Ship/ops confidence
Current score: `0.43`

#### N1. Release-critical telemetry presence
- id: N1
- title: Release-critical telemetry presence
- scope: ship
- status: proof_pending
- definition_of_done: Release-critical telemetry references and report generation exist for key launch surfaces.
- dependencies: [H1, M1]
- unlocks: [N2, M3]
- blocking_level: hard_blocker
- machine_proof: `docs/EXECUTION_RULES.md`, `test/contracts/store_package_telemetry_guard_test.dart`, `release/_reports/telemetry.jsonl`
- human_proof: Review that telemetry is decision-useful rather than merely emitted.
- notes: Presence is better than absence, but usefulness is not fully closed.

#### N2. Governed dashboards and operational review loops
- id: N2
- title: Governed dashboards and operational review loops
- scope: ship
- status: in_progress
- definition_of_done: Telemetry/reports feed a governed operational review loop instead of a large ungated report pile.
- dependencies: [H3, J2, M2, N1]
- unlocks: [M3, J3]
- blocking_level: hard_blocker
- machine_proof: Promoted dashboard/ops docs plus deterministic summary tools for the active release questions.
- human_proof: Review cadence showing the dashboards materially drive decisions.
- notes: The repo has many reports; governance over which ones matter is still incomplete.

#### N3. Low-ops burden and recovery confidence
- id: N3
- title: Low-ops burden and recovery confidence
- scope: ship
- status: blocked
- definition_of_done: Launch and maintenance can proceed without hidden manual heroics, and recovery playbooks are proven for the active release surface.
- dependencies: [K3, M3, N2]
- unlocks: [final_launch_claim]
- blocking_level: soft_blocker
- machine_proof: `docs/ops/low_ops_burden_proof_v1.md` plus launch/recovery artifact proofs aligned to current release scope.
- human_proof: Dry-run operational review confirming low-touch maintenance and recovery realism.
- notes: There is useful ops proof material, but final-launch confidence is still blocked by upstream gaps.

## Execution graph / dependency notes

Block graph:

- `A -> B, J, M`
- `C -> D, F, M`
- `E -> D, F, G, M`
- `H -> D, F, M, N`
- `B + D + F -> G`
- `F + G + J -> I`
- `F + I + J -> K`
- `I + J + K -> L`
- `A..J + H + L -> M`
- `H + J + K + M -> N`
- `L + M + N -> final launch claim`

Epic dependency notes:

- `J2` remains one of the clearest core-product bottlenecks because it gates
  honest packaging and monetization closure, even after the admitted first-path
  trust slice landed.
- `K2` and `K3` should not be treated as isolated commerce work; they are
  downstream of trust, identity, and value proof.
- `L2` is materially stronger now that metadata/support/legal ownership is
  explicit, but `L3` still cannot close until submission-ready materials are
  human-reviewed.
- `M2` is now bounded executable proof rather than owner-doc-only truth, but it
  still must widen from bounded confidence to whole-product final-launch
  confidence before `M3` can be honestly closed.
- `N2` should be governed by launch questions; producing more reports alone does
  not count as readiness movement.

Parallel-capable next waves after this SSOT sync:

- `M3` release-owner review and decision-discipline closeout
- `K3` verified commerce flow closure
- `L3` submission-ready bundle assembly
- `N2` governed dashboard and ops-loop consolidation

Do not advance as if already closable:

- `K3`
- `L2`
- `L3`
- `M3`
- final launch claim

## Current bottlenecks / active frontier

Top bottleneck blocks:

1. `M Production / Release Confidence`
2. `K Monetization / Value Packaging`
3. `L Store / Distribution / Launch Packaging`
4. `I Product Identity / Persona / Emotional Layer`
5. `J Onboarding / Trust / First-Session Framing`

Top bottleneck epics:

1. `M3` repeatable go/no-go, rollback, and release discipline
2. `K3` verified commerce flow and offer/value package closure
3. `L3` submission-ready distribution bundle
4. `N2` governed dashboards and operational review loops
5. `I3` identity SSOT across visual and voice surfaces

Hard blockers:

- `G2`
- `K3`
- `L3`
- `M3`
- `N2`

Soft blockers:

- `A3`
- `B3`
- `D3`
- `E3`
- `F3`
- `G3`
- `I3`
- `J3`
- `L1`
- `N3`

Parallel-capable now:

- `K3` with `M3`
- `L3` with `M3`
- `N2` with `M3`

Must not be declared closed yet:

- `I Product Identity / Persona / Emotional Layer`
- `J Onboarding / Trust / First-Session Framing`
- `K Monetization / Value Packaging`
- `L Store / Distribution / Launch Packaging`
- `M Production / Release Confidence`
- final launch claim

Active frontier after this status sync:

- keep `I` and `J` advancing, but treat their admitted first-path gains as real
  current-main progress
- close `M3` owner/human-proof discipline on top of the bounded executable smoke
  family
- close `K3` verified commerce flow and `L3` submission-ready bundle truth
- widen `N2` only where it supports release questions already owned by `M`

## Rules against false readiness

- No epic closes on summary rhetoric alone.
- No block closes because several related things feel better.
- No percentage rises unless epic state actually changed.
- No block reaches `100%` with unresolved hard blockers.
- No block reaches `100%` without explicit closeout confidence and resolved
  proof requirements.
- No final readiness reaches `100%` unless all required ship/distribution layers
  are complete.
- No downstream block may report closure beyond its prerequisite cap.
- No placeholder support URL, marketing URL, legal identity, or store metadata
  may coexist with a final-ready claim.
- No beta-slice strength may be reused as proof of final-product readiness.
- No report may quote the historical `85/100` beta-path score as the current
  final-readiness score.
- No already accepted epic progress may be downgraded without documented
  contradictory repo truth or explicit SSOT definition change.
