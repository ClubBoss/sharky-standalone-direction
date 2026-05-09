# Documentation Topology

This is the canonical navigation entrypoint for the repository docs.

The goal of this layout is to keep governing truth easy to find while separating active planning, supporting reference material, and historical audits.

## Topology

### `CORE`
- [ROADMAP_FINAL_100_SSOT.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/ROADMAP_FINAL_100_SSOT.md)
- [README_SSOT.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/README_SSOT.md)
- [plan/PROJECT_READINESS_EPICS_SSOT_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md)
- [plan/MASTER_PLAN_v2.2.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/plan/MASTER_PLAN_v2.2.md)
- [governance/ARCHIVE_POLICY_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/governance/ARCHIVE_POLICY_v1.md)
- [governance/DOCS_PLACEMENT_CONTRACT_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/governance/DOCS_PLACEMENT_CONTRACT_v1.md)

### `SSOT`
- `docs/learning/` for learning architecture truth
- `docs/content/` for content-system truth
- `docs/plan/` for active planning SSOTs, policy docs, contracts, and execution maps

### `REFERENCE`
- `docs/reference/` for historical execution/protocol/phase material
- `docs/canonical/` for promoted but non-active historical governance/reference material
- `docs/dev/`, `docs/plugins/`, `docs/release/`, `docs/ops/`, `docs/worlds/`, `docs/product/`, `docs/ux/` for implementation/supporting references

### `AUDIT/CLOSEOUT`
- `docs/audit/` for active investigations, bounded audits, and closeout records
- `docs/audit/history/` for older standalone audit reports
- `docs/_reviews/` for the older historical review stream retained for traceability

### `ARCHIVE`
- `docs/archive/` for frozen snapshots and stop points
- `docs/_archive/` for deprecated or superseded documents

### `TEMPORARY`
- `docs/_inbox/` for temporary intake only; nothing there is authoritative until promoted

## Folder Intent

### `docs/plan/`
Use for documents that are still part of active execution truth:
- master plans
- pacing and policy SSOTs
- contracts
- planning indexes
- execution maps

Do not use `docs/plan/` for seam-by-seam audits or closure notes when those files are no longer governing execution truth.

### `docs/audit/`
Use for bounded investigation and closeout material:
- `docs/audit/investigations/`
- `docs/audit/closeouts/`

These docs are valuable evidence, but they are not the current SSOT chain unless explicitly promoted elsewhere.

## What Stays Core

The docs that should remain top-level or otherwise clearly core:
- [ROADMAP_FINAL_100_SSOT.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/ROADMAP_FINAL_100_SSOT.md)
- [README_SSOT.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/README_SSOT.md)
- [README.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/README.md)
- [deferred_backlog.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/deferred_backlog.md)

The docs that should remain canonical SSOT anchors:
- [PROJECT_READINESS_EPICS_SSOT_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md)
- [MASTER_PLAN_v2.2.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/plan/MASTER_PLAN_v2.2.md)
- [UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md)
- [CONTENT_SYSTEM_v2.1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/content/CONTENT_SYSTEM_v2.1.md)
- [CONTENT_PLAN_PER_WORLD_v2.1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md)

## What Moved Out Of Active Plan

The following docs were moved from `docs/plan/` because they are better classified as audit evidence or closure records:
- auxiliary entry seam audits and closeouts
- map-shell, non-map-shell, topology, route-surface, and pack-target seam audits/closeouts
- progression-system and campaign-home policy audits
- old visual/table transplant audits
- World 2 dense-shape, hand-chain, governance-pilot, and truth-validation audits/closeouts

See [docs/audit/README.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/audit/README.md) for the live audit buckets.

For historical phase/protocol material, use [docs/reference/history/README.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/reference/history/README.md).

For future doc placement and naming decisions, use [docs/governance/DOCS_PLACEMENT_CONTRACT_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/governance/DOCS_PLACEMENT_CONTRACT_v1.md).
