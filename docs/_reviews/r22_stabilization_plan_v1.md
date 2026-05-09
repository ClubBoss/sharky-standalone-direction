# R22 Stabilization Plan v1 (Bounded, Deterministic)

## 1) Candidate Stabilization Items
Based on `r22_production_reality_audit_v1.md`, non-zero findings are:
1. Entitlement-ledger convergence debt (P1)
2. Formatting hygiene / gate-block risk (P2)

## 2) Severity + EV Ranking
1) Entitlement-ledger convergence debt
- Severity: P1
- EV: high (highest in R22)
- Why: touches monetization correctness confidence and future route stability.

2) Formatting hygiene / gate-block risk
- Severity: P2
- EV: low-medium
- Why: operational friction only; no route-integrity regression evidence.

## 3) Inclusion Decision
### Item 1: Entitlement-ledger convergence debt
Decision: **include in R22**
Reason:
- Real stabilization value with bounded scope.
- Evidence-backed from `docs/plan/MONETIZATION_SSOT_v1.md` + R20/R21/R22 audits.
- Can be executed via deterministic contract-first slices without feature expansion.

### Item 2: Formatting hygiene / gate-block risk
Decision: **defer after R22**
Reason:
- Not a product/runtime regression.
- Already bounded by existing release gate behavior (`dart format --set-exit-if-changed`).
- Better handled as process hygiene, not active stabilization work.

## 4) Included Item Plan (smallest bounded slice)
### Included Item A: Entitlement convergence contract hardening
Smallest bounded slice:
- Add/lock deterministic contract coverage for entitlement precedence and transition convergence across existing stores.
- No new product flows, no schema changes, no dependency changes.

Expected files/surfaces:
- Services/tests only (likely):
  - `test/services/subscription_status_v1_test.dart`
  - `test/payments/payment_service_restore_verification_policy_v1_test.dart`
  - optionally `test/guards/world_campaign_map_home_contract_test.dart` (only if route-level assertion gap remains)
- Runtime touched only if tests prove deterministic mismatch.

Deterministic contract impact:
- Verify precedence is stable: premium vs trial states.
- Verify restore convergence remains deterministic across startup/path surfaces.
- Verify no dead-end routing change in premium-gated path assumptions.

Gate expectations for execution slice:
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- Content validators only if content files are touched (not expected).

## 5) Deferred Item Note
### Deferred Item B: formatting hygiene
Defer rationale:
- Operational/process item, not launch-critical runtime behavior.
- Keep as checklist discipline under existing release gate; do not spend R22 implementation bandwidth unless it causes repeated release-cut failures.

## 6) Anti-Drift Note
Do NOT pull into R22 stabilization:
- new world/track/drill scope,
- schema or telemetry redesign,
- economy/gamification/localization expansion,
- broad refactors,
- polish unrelated to ranked stabilization findings.
