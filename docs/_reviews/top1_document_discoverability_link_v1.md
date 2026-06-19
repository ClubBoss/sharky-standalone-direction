# Top-1 Document Discoverability Link v1

Date: 2026-06-19
Branch: `codex/top1-document-discoverability-link-v1`
Mode: docs-only connective patch

## 1. Base Commit

Started from synced `main` at `972c14a` after PR #11 merge.

## 2. Docs Inspected

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`

## 3. Files Changed

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/_reviews/top1_document_discoverability_link_v1.md`

## 4. Exact Discoverability Links Added

`AGENTS.md` now tells future agents to read
`docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` for top-1 / 10/10 / Runout /
competitive-product attack planning.

`docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` now links TOP1 in:

- the read-order section;
- fast next-frontier selection;
- source-of-truth hierarchy as a companion layer under Master Plan.

## 5. Hierarchy Impact

No new authority was created.

`docs/plan/MASTER_PLAN_v3.0.md` remains day-to-day product priority authority.
TOP1 is discoverable as the companion strategy SSOT for top-1 / 10/10 product
attack planning.

TOP1 does not override:

- Master Plan;
- Monetization SSOT;
- readiness SSOT;
- active route truth.

Review artifacts under `docs/_reviews/top1_*.md` remain evidence logs, not
roadmap authority.

## 6. What Was Intentionally Not Changed

- No product code.
- No tests.
- No workflows.
- No generated outputs.
- No `external_competitors/`.
- No new competing SSOT.
- No `TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` rewrite.
- No `MASTER_PLAN_v3.0.md` rewrite.
- No monetization route change.
- No active product sequence change.
- No Modern Table work.
- No new Runout analysis.

## 7. Checks Run

- `git diff --name-only`: confirmed only orientation docs were modified before
  staging; the new review artifact was untracked at that point.
- `git diff --stat`: confirmed the runtime-free orientation diff.
- `git diff --check`: passed.
- `./tools/fast_loop_world1_v1.sh`: passed, FAST LOOP PASS; selected product
  tests were skipped by policy because the diff is docs-only.

Docs-only scope means no heavier runtime tests are required.

## 8. Verdict

TOP1 is now discoverable from the core orientation chain.

Next product wave remains:

`Act0 Rule-Based Repair Visible Reason Surface v1`
