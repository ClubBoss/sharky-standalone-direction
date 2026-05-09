# R20 Release Spine Audit v1 (Ship-Critical Gap Cut)

## 1) Current Release Thesis
The product already supports a coherent, deterministic end-to-end learning loop:
- onboarding -> world1 -> world2 -> world10 -> track choice -> track sessions -> result -> map return
- checkpoint loop is discoverable and deterministic (seeded top-3, stable ordering, bounded count)
- release gate discipline exists (`fast_loop`, `release_gate_world1`, contract-heavy guard coverage)

Current status: near first launch-worthy baseline, but not yet launch-ready without a final ship-critical gap cut.

## 2) Ship-Critical Checklist
- Onboarding: present and contract-audited (R12 artifacts). Status: pass with minor copy risk.
- Path/map entry: map-first primary path and deterministic start. Status: pass.
- Runner correctness: key legality and truth invariants are contract-covered. Status: pass.
- Result loop: single-primary-CTA and deterministic back-to-map path are covered. Status: pass.
- Checkpoint loop: pending strip, deterministic checkpoint entry, seed-to-selection determinism covered. Status: pass.
- Content validity: validators and QA tooling in place and repeatedly used. Status: pass.
- Deterministic routing/state: no-dead-end contracts present across core loops. Status: pass.
- Release gates/tests: Tier0 and release gate scripts are established and used. Status: pass.

## 3) Gap Classification (P0/P1/P2)

### P0 Ship Blockers
- None identified from current evidence set.

### P1 Important Before Launch
- P1.1 Paywall conflict verification remains an audit risk (called out earlier, not fully closed with explicit entitlement-state matrix evidence).
- P1.2 Final launch bundle checklist is fragmented across multiple milestone audits; needs one consolidated launch checklist artifact.
- P1.3 Cross-surface copy consistency pass (onboarding, result, checkpoint, track messaging) should be locked to avoid mixed guidance at launch.

### P2 Deferred / After Launch
- Additional polish not tied to core conversion or correctness (visual refinements, broader optional microcopy expansions).
- New drill families beyond current released spine.
- Gamification/economy expansion work.

## 4) Priority-Ranked Next Steps (Top 3)
1. Close entitlement/paywall interaction matrix with explicit deterministic evidence.
Reason: only meaningful unresolved launch risk surface touching conversion and route integrity.
Risk if skipped: launch friction or route ambiguity for non-premium users.
Expected impact: removes highest remaining pre-launch uncertainty.

2. Publish one consolidated launch checklist doc (ship gate SSOT view).
Reason: current evidence is distributed across multiple audit files.
Risk if skipped: execution drift and missed launch-blocking checks.
Expected impact: faster, safer go/no-go decisions.

3. Run final copy consistency lock for ship-critical surfaces only.
Reason: inconsistent copy can degrade first-session trust even with correct logic.
Risk if skipped: perceived product incoherence.
Expected impact: clearer first-launch user experience without runtime risk.

## 5) Remaining Distance to First Release
Estimate: 2 bounded slices.
- Slice A: entitlement/paywall interaction evidence closure (audit + any tiny deterministic contract additions if needed).
- Slice B: consolidated launch checklist and final go/no-go audit cut.

## 6) Explicit Anti-Drift Verdict
Do NOT work on before first release:
- new content trees/world expansions
- new drill formats or schema changes
- gamification/economy/localization expansion
- visual polish not tied to ship-critical flow integrity

Focus only on ship-critical verification closure and launch checklist consolidation.
