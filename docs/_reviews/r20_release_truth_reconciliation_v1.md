# R20 Release Truth Reconciliation v1

## Purpose
Reconcile formal milestone closure claims with launch-critical proof so release decisions are evidence-based.

## 1) Closed-vs-Proven Matrix
| Area | Status |
|---|---|
| Onboarding | FORMALLY CLOSED + PROVEN |
| Today/Map entry | FORMALLY CLOSED + PROVEN |
| Runner loop | FORMALLY CLOSED + PROVEN |
| Result loop | FORMALLY CLOSED + PROVEN |
| Checkpoint loop | FORMALLY CLOSED + PROVEN |
| Track routing/followups | FORMALLY CLOSED + PROVEN |
| Content validity/determinism | FORMALLY CLOSED + PROVEN |
| Monetization/paywall/entitlements | FORMALLY CLOSED + NOT YET PROVEN |
| Release gate/checklist consolidation | OPEN / STILL ACTIVE |

Evidence basis:
- Core loop contracts and gates: `docs/_reviews/r13_rc_cut_report_v1.md`, `docs/_reviews/r18_mastery_checkpoints_ux_audit_v1.md`, `docs/_reviews/r19_checkpoint_content_quality_audit_v1.md`.
- Monetization proof gap: `docs/plan/MONETIZATION_SSOT_v1.md` (split entitlement stores, unresolved v2b/v2c items), and `docs/_reviews/r13_rc_cut_report_v1.md` (paywall scan `NOT-VERIFIED`).

## 2) Contradictions List
1. R4 closure claim vs current monetization proof:
- Formal claim: R4 DoD says purchases are reliable and recoverable (`docs/ROADMAP_FINAL_100_SSOT.md`, Milestone R4).
- Current evidence: monetization SSOT still documents unresolved entitlement convergence and restore/verification hardening items (`docs/plan/MONETIZATION_SSOT_v1.md`).
- Verdict: real release-readiness contradiction (formal closure exceeds currently proven launch evidence).

2. RC report risk declaration mismatch:
- `docs/_reviews/r13_rc_cut_report_v1.md` marks paywall scan as `NOT-VERIFIED`.
- Same report says `Open P0/P1 Issues: P0 none, P1 none`.
- Verdict: proof-gap inconsistency (risk acknowledged but not carried into open-issues list).

3. Launch distance confidence mismatch:
- `docs/_reviews/r20_release_spine_audit_v1.md` estimated 2 slices but did not enforce pass/fail criteria for monetization matrix closure.
- Verdict: wording/proof-gap mismatch; estimate needs explicit bounded acceptance criteria.

## 3) Corrected Launch Spine (Minimum Remaining)
### P0 launch blocker
1. Entitlement/paywall interaction matrix closure with deterministic evidence.
- Must prove no dead-end and correct routing for both entitled and non-entitled states across map/start/result/checkpoint surfaces.
- Must prove restore/premium/trial precedence is deterministic and convergent at runtime boundaries.

### P1 pre-launch must-fix
2. Consolidated launch checklist artifact (single go/no-go source).
- Merge distributed audit requirements into one authoritative checklist with explicit pass criteria and rollback owner.

3. Final release readiness reconciliation pass.
- Re-run checklist against current main and publish a final launch verdict (PASS/BLOCKED) with open-risk list.

### Deferred after v1
- New drill families or schema expansions.
- Additional worlds/content growth beyond launch spine.
- Gamification/localization/extra polish not tied to conversion or route integrity.

## 4) Distance-to-Launch Verdict
Bounded estimate: **3 slices remaining**.
1. Slice A (P0): monetization/entitlement interaction matrix closure with deterministic evidence.
2. Slice B (P1): single consolidated launch checklist (authoritative go/no-go doc).
3. Slice C (P1): final reconciliation run on current main, publish launch verdict and freeze scope.

Rationale: 2-slice estimate is not yet evidence-tight because Slice A can invalidate assumptions and must be separated from final launch verdict.

## 5) Anti-Drift Verdict
Before first launch, do NOT work on:
- new product scope (new formats/world expansions),
- non-critical UI polish,
- gamification/economy expansions,
- refactors unrelated to launch blockers.

Only execute the 3 slices above in order.
