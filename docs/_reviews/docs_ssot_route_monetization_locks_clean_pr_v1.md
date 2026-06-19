# Docs SSOT Route / Monetization Locks Clean PR v1

## 1. Branch and base commit

- Branch: `codex/docs-ssot-route-monetization-locks-v1`
- Base branch: `main`
- Base commit: `19cc30b`
- Backup source: `origin/codex/backup-full-project-worktree-2026-06-19`

## 2. Docs restored

Plan / SSOT docs:

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/MONETIZATION_SSOT_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/plan/MONETIZATION_TIMING_GUARD_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md`
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`

Direct review / lock artifacts:

- `docs/_reviews/top1_product_attack_plan_lock_v1.md`
- `docs/_reviews/monetization_route_truth_ssot_lock_v1.md`
- `docs/_reviews/w1_w3_free_foundation_gate_readiness_audit_v1.md`

## 3. Docs excluded

Excluded from this branch:

- `.github/workflows/**`
- `output/playwright/**`
- `docs/competitive/runout/**`
- stale `test/guards/world_campaign_*`
- `tools/audit_worlds_0_4_telemetry_v1.dart`
- `test/tools/worlds_0_4_telemetry_audit_contract_test.dart`
- already-merged PR #1 / PR #2 / PR #3 review artifacts
- generated PNG / JSON / YML proof artifacts
- runtime code
- tests
- capture tooling
- monetization service files already merged
- `external_competitors/`

## 4. Authority hierarchy check

The restored docs keep `docs/plan/MASTER_PLAN_v3.0.md` as the active product-working master plan and add a pointer to `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` for the current top-1 product attack strategy.

`docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` remains a readiness/reference document, not the day-to-day routing authority.

No restored doc changes runtime ownership, routes, tests, CI workflows, or app behavior.

## 5. Monetization boundary check

The restored docs lock the same launch monetization boundary:

- `W1-W4` are the free public foundation.
- `W5+` is the future paid-depth boundary.
- W4 is a future challenger / A-B candidate only, not the launch-default paid gate.
- W3 is not a launch-default paid gate.
- Soft premium preview appears only after completed daily/session learning value.
- No public hard paywall, public trial start, pricing, purchase, restore, Premium Hub exposure, or receipt-verification-dependent commerce ships until production commerce safety is closed.

This is consistent with the merged monetization entitlement safety contracts because those contracts preserve safety state without launching public commerce.

## 6. Route truth check

The restored route truth is:

| World | Launch-facing title |
| --- | --- |
| W1 | Poker from Zero |
| W2 | Hand Discipline |
| W3 | Position Thinking |
| W4 | Preflop Framework |
| W5 | Bet Purpose + Price |
| W6 | Board and Draws |

Older authored/content docs may still use stale W4/W5 meanings. The restored docs explicitly quarantine those older meanings for monetization and commercial copy until a dedicated route/content normalization wave.

## 7. Modern Table non-regression check

No table geometry, Modern Table visuals, screenshot tooling, Playwright tooling, or generated proof output is restored in this branch.

The docs also preserve the prohibition against copying Runout assets, layouts, video treatment, paywall surfaces, icons, chart motifs, typography, or proprietary structure.

## 8. Runtime impact: none

This branch is docs-only. It does not modify product code, tests, CI workflows, generated assets, routes, content, telemetry implementation, entitlement code, commerce code, capture tooling, screenshots, localization, or table geometry.

## 9. Checks run

Completed before commit:

- `git diff --cached --check`: passed
- `git diff --check`: passed
- `./tools/fast_loop_world1_v1.sh`: passed, FAST LOOP PASS; runtime tests skipped by policy because only docs changed

## 10. PR readiness verdict

Ready for PR after commit and push. Scope is docs-only SSOT / route-truth / monetization-boundary lock material.
