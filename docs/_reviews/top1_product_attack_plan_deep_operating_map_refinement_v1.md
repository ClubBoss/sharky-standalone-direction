# Top-1 Product Attack Plan Deep Operating Map Refinement v1

Date: 2026-06-19
Branch: `codex/top1-product-attack-plan-deep-map-refinement-v1`
Mode: docs-only SSOT refinement

## 1. Base Commit

Started from synced `main` at `891974b` after PR #9 merge.

## 2. Docs Inspected

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/top1_product_attack_plan_refresh_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/MONETIZATION_SSOT_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`

## 3. Files Changed

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/top1_product_attack_plan_deep_operating_map_refinement_v1.md`

## 4. Sections Refined

Refined `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` in these areas:

- header authority note;
- `5. Target Scorecard`;
- `5A. 10/10 Operating Map By Product Block`;
- new `5B. 10/10 Acceptance Gates`;
- `6. Locked Arc Order`;
- `11. Source Links`.

## 5. Why This Refinement Was Needed After PR #9

PR #9 refreshed the Top-1 Product Attack Plan after PR #1-#8 and locked the
current path from deterministic repair foundation to visible repair value.

This refinement makes that strategy more operational. It turns the high-level
delta into block-by-block acceptance guidance so the next product waves can
move toward `10 / 10` without reopening closed scope or drifting into
infrastructure, visual polish, broad content, or monetization launch work.

## 6. Authority / Hierarchy Note Added

The SSOT now states:

- `docs/plan/MASTER_PLAN_v3.0.md` remains the day-to-day product priority
  authority.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` remains the active top-1
  product attack planning SSOT.
- If there is a conflict, Master Plan, Monetization SSOT, and active route truth
  win.
- TOP1 constrains product attack direction; it does not replace Master Plan.

## 7. 10/10 Operating Map Expansion

The prior compact `5A` delta table was replaced with a product-block operating
map covering:

- foundation / deterministic app;
- AI personalization / repair;
- learning effect;
- first-week commercial readiness;
- UX/UI sequencing;
- activation / Welcome / Placement;
- Review / Home / re-entry;
- visual / Modern Table / feedback rhythm;
- content density / curriculum depth;
- telemetry / learning loop;
- monetization / premium value;
- retention / habit loop;
- proof packet / commercial evidence;
- product coherence / brand promise;
- technical delivery / CI.

Each block now includes:

- where Sharky is now;
- what `10 / 10` or top-1 looks like;
- remaining gap;
- next action;
- acceptance signal;
- not-now guardrail.

## 8. Acceptance Gates Added

Added `5B. 10/10 Acceptance Gates` for:

1. Visible Repair Reason Surface gate
2. Repair Result Receipt gate
3. Session Repair Summary gate
4. Compact First-Week Proof Packet gate
5. Premium/value packaging gate
6. Content-depth follow-up gate
7. Activation/Welcome/Placement follow-up gate

Each gate records:

- accepted when;
- must prove;
- must not do.

## 9. Source-Link Handling

The SSOT now includes a source-link rule:

- keep only repo-present references as active links;
- if `docs/competitive/runout/**` files are not present, treat them as local
  competitive reference evidence, not active source links;
- do not restore competitive research files in this PR.

The previously listed Runout files were checked and are not present in this
repo, so they were marked as local evidence rather than active repo links.

## 10. What Was Intentionally Not Changed

- No product code.
- No tests.
- No workflows.
- No generated outputs.
- No `external_competitors/`.
- No new competing SSOT.
- No `MASTER_PLAN_v3.0.md` rewrite.
- No route truth changes.
- No W4/W5 monetization debate reopening.
- No public paywall, trial, price, purchase, restore, or Premium Hub launch.
- No Modern Table visual work.
- No AI/ML/GTO/solver/guaranteed-result/win-rate claims.
- No broad content roadmap expansion.

## 11. Checks Run

- `git diff --name-only`
- `git diff --stat`
- `git diff --check`
- `./tools/fast_loop_world1_v1.sh`
  - passed, `FAST LOOP PASS`
  - selected no product tests because the diff is docs-only

Docs-only scope means no runtime tests are required.

## 12. PR Readiness Verdict

Ready after diff hygiene passes and the file scope remains limited to the two
approved docs.

## 13. Exact Next Wave

`Act0 Rule-Based Repair Visible Reason Surface v1`

Contract:

- consume the existing private repair decision / reason receipt only where a
  current surface already has a safe reason slot;
- show missed signal, selected repair hand, and repair reason;
- add no new telemetry owner;
- add no session summary yet;
- make no AI/ML claims;
- add no commerce;
- avoid broad UI expansion;
- avoid Modern Table visual work.
