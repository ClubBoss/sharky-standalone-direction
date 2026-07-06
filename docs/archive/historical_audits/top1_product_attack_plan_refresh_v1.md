# Top-1 Product Attack Plan Refresh v1

Date: 2026-06-19
Branch: `codex/top1-product-attack-plan-refresh-v1`
Mode: docs-only surgical SSOT refresh

## 1. Base Commit

Started from synced `main` at `a6bd1b1` after PR #8 merge.

## 2. Docs Inspected

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/MONETIZATION_SSOT_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/_reviews/ai_personalization_rule_based_repair_v1.md`
- `docs/_reviews/act0_rule_based_repair_runtime_consumption_v1.md`
- `docs/_reviews/act0_rule_based_repair_telemetry_truth_v1.md`
- `docs/_reviews/ci_workflow_rationalization_v1.md`

## 3. Files Changed

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/top1_product_attack_plan_refresh_v1.md`

## 4. Exact Sections Updated

Updated `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` in these sections:

- header status/date area;
- `1. Mission`;
- `3. Sharky Win Condition`;
- `4. Current Accepted State`;
- `5. Target Scorecard`;
- new `5A. Current Delta To 10/10 By Block`;
- `6. Locked Arc Order`;
- `7. Arc EV Table`;
- `8. Operating Mode`;
- `9. Non-Negotiable Guardrails`;
- `10. Deferred Ideas`;
- `11. Source Links`.

## 5. Current State Locked After PR #1-#8

The refresh records the current accepted state:

- PR #1 restored Act0 / repair / broad preview gate confidence.
- PR #2 added monetization entitlement safety contracts without public commerce.
- PR #3 added capture proof tooling source only.
- PR #4 restored docs-only SSOT route and monetization lock material.
- PR #5 rationalized CI workflow hygiene and kept R5 as the primary repo-owned
  gate.
- PR #6 added deterministic `Act0RuleBasedRepairDecisionV1` and
  `buildAct0RuleBasedRepairDecisionV1(...)`.
- PR #7 consumed the deterministic repair decision at the existing Act0
  next-useful-hand / reason receipt seam.
- PR #8 aligned local Act0 telemetry truth with deterministic `user_choice`
  before `task_result`.

## 6. Full 10/10 Delta Captured By Block

The refreshed SSOT now explicitly tracks the path to `10 / 10` by block:

- foundation / deterministic app;
- AI personalization;
- learning effect;
- first-week commercial;
- visual/table;
- monetization readiness;
- telemetry loop;
- content depth;
- CI/delivery.

The shortest path is locked as:

1. Visible Repair Reason Surface
2. Repair Result Receipt
3. Session Repair Summary
4. Compact First-Week Proof Packet
5. Premium/value packaging later

## 7. Scorecard Changes

Updated only rows affected by the repair personalization foundation:

- First promise: `8.9`
- First value before paywall: `9.3`
- Runner/table learning UX: `9.1`
- Personalization credibility: `8.9`
- Feedback quality: `9.3`
- Progress/skill map: `8.2`
- Retention loop: `8.6`
- Monetization readiness: `8.7`
- Technical determinism: `9.6`
- Product coherence: `8.9`

The refresh intentionally does not move personalization or first-week readiness
to `9.5+` because the repair reason and repair outcome are not fully visible in
the learner flow yet.

## 8. Locked Next Product Sequence

Completed:

- Monetization / Route Truth SSOT Lock v1.
- Infrastructure recovery and CI hygiene.
- AI Personalization foundation.

Immediate:

- `Act0 Rule-Based Repair Visible Reason Surface v1`

Then:

- `Repair Result Receipt v1`
- `Session Repair Summary v1`
- `Compact First-Week Proof Packet v1`

Later:

- premium/value packaging after visible learning value;
- Daily Trainer / Habit Loop Expansion and Learning Depth;
- W4/W5 Product Truth Normalization;
- Paywall / Trial Design;
- App Store / Premium Packaging Arc;
- Analytics / Leak Profile Lite.

## 9. Future Deferred Priorities Preserved

The refresh keeps high-EV future ideas deferred rather than rejected:

- full AI coach/chat;
- full analytics dashboard;
- public leak profile surface;
- AI/adaptive marketing language;
- premium repair-depth upsell;
- App Store packaging;
- visual/motion layer;
- broad skill map;
- welcome/placement simplification;
- contextual glossary / tappable definitions;
- concept depth audit / spaced examples;
- world/lesson completion reward layer.

## 10. What Was Intentionally Not Changed

- No product code.
- No tests.
- No workflows.
- No generated outputs.
- No `external_competitors/`.
- No `MASTER_PLAN_v3.0.md` edit.
- No route truth changes.
- No W4/W5 monetization debate reopening.
- No public paywall, trial, price, purchase, restore, or Premium Hub launch.
- No Modern Table visual work.
- No AI/ML/GTO/solver/guaranteed-result/win-rate claims.
- No broad content roadmap expansion.

## 11. Authority Hierarchy Impact

No new competing SSOT was created.

`TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` remains the active top-1 product attack
planning SSOT. The review artifact only records the bounded refresh and does
not create new route, monetization, runtime, or readiness authority.

## 12. Drift Risks Closed

Closed drift risks:

- treating PR #6-#8 repair foundation as still unstarted;
- overinflating personalization to `9.5+` before visible learner proof;
- drifting back into infrastructure cleanup after CI is good enough;
- moving premium/value packaging ahead of first-session repair proof;
- describing deterministic repair as AI/adaptive magic;
- losing the one dominant next wave.

## 13. Checks Run

- `git diff --name-only`
- `git diff --stat`
- `git diff --check`
- `./tools/fast_loop_world1_v1.sh`
  - passed, `FAST LOOP PASS`
  - selected no product tests because the diff is docs-only

Docs-only scope means no runtime tests are required.

## 14. PR Readiness Verdict

Ready after diff hygiene passes and the file scope remains limited to the two
approved docs.

## 15. Exact Next Wave

`Act0 Rule-Based Repair Visible Reason Surface v1`

Scope:

- consume the existing private repair decision / reason receipt only where a
  current surface already has a safe reason slot;
- make missed signal, selected repair hand, and repair reason visible;
- do not add new telemetry ownership;
- do not add AI/ML claims, session summary, commerce behavior, broad dashboard,
  new route, or Modern Table visual work.
