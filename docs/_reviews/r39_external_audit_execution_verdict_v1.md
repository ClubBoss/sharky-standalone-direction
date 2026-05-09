# R39 External Audit Execution Verdict v1

## 1) Ranked candidate classes
Ranked by user trust impact, learning EV, boundedness, complexity, evidence confidence, and scope risk.

1. **B) Contradictory feedback / primary-correct mismatch fixes**
- User trust impact: Very High
- Learning EV: High
- Boundedness: High (deterministic tooling fence class)
- Complexity: Low-Medium (tooling + targeted content follow-up only where violated)
- Evidence confidence: High
- Scope-explosion risk: Low-Medium

2. **A) Prompt leakage family fixes**
- User trust impact: High
- Learning EV: Very High
- Boundedness: Medium (multiple subfamilies remain)
- Complexity: Medium-High (tooling + potentially broader content cleanup)
- Evidence confidence: High
- Scope-explosion risk: Medium-High

3. **C) Placeholder/TODO leakage fixes**
- User trust impact: High
- Learning EV: Medium-High
- Boundedness: Medium
- Complexity: Medium (tooling + batch cleanup)
- Evidence confidence: High
- Scope-explosion risk: Medium

4. **D) Verify-then-fix candidates (onboarding duplication / misleading Top leak)**
- User trust impact: Medium-High
- Learning EV: Medium
- Boundedness: Medium-Low (needs runtime/path verification)
- Complexity: Medium-High (runtime presentation + flow verification)
- Evidence confidence: Medium
- Scope-explosion risk: High

## 2) Evidence basis
- `docs/_reviews/external_learning_truth_audit_triage_v1.md`
- `docs/_reviews/r34_weakest_link_decision_v1.md`
- `docs/_reviews/r38_personalization_closeout_audit_v1.md`
- SSOT continuity and guard-history context from `docs/ROADMAP_FINAL_100_SSOT.md`

## 3) Why the selected class won
Selected class: **one bounded tooling guard class for contradictory feedback / primary-correct mismatch**.

Reasoning:
- Highest trust-risk reduction per unit scope.
- Most bounded next slice with deterministic pass/fail semantics.
- Lower scope-explosion risk than prompt-leak family continuation (which still contains multiple subfamilies).
- Preserves ability to defer multi-family content rewrites until separately selected.

## 4) Why the others are deferred
- Prompt leakage family: deferred as multi-family cleanup risk unless a single subfamily is explicitly selected in a later milestone.
- Placeholder/TODO leakage: deferred as batch cleanup class; still important but less immediate trust inversion risk than contradictory correctness feedback.
- Verify-then-fix runtime candidates: deferred due to lower evidence confidence and higher runtime-surface complexity.

## 5) Exact recommended next executable slice
Recommended next slice (single family only):
- **Tooling guard: contradictory primary-correct feedback fence v2**.
- Scope target:
  - extend deterministic validator/guard rules for contradiction patterns in `feedback_correct_v1` / `feedback_incorrect_v1`,
  - add minimum targeted contracts for fail-on-broken / pass-on-valid,
  - perform only bounded content cleanup required by the new guard, if any.

## 6) Anti-drift note
This verdict selects exactly one execution family.
Do not combine with prompt-leak, placeholder batch, onboarding dedup, or Top-leak runtime fixes in the same milestone.
