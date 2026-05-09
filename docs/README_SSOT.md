# SHARKY POKER SSOT (Source of Truth)

This directory defines the current SSOT document hierarchy for product/learning/content planning.

For the full documentation topology, start with [docs/README.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/README.md).
Historical phase/protocol material now lives under [docs/reference/history/README.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/reference/history/README.md).
For doc placement and authority rules, see [docs/governance/DOCS_PLACEMENT_CONTRACT_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/governance/DOCS_PLACEMENT_CONTRACT_v1.md).

## SSOT Hierarchy

1. `docs/plan/MASTER_PLAN_v2.2.md`
   - Execution plan and production sequencing.
1a. `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
   - Canonical readiness scoring, true-100 meaning, block/epic registry, dependency graph, and current bottleneck reporting.
1b. `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md`
   - Current execution mode, A->B gap map, locked Route to B, and active block order for the publish-ready push.
1c. `docs/plan/ROUTE_TO_B_ACTION_LADDER_v1.md`
   - Live operational ladder, current active block pointer, first unfinished action, and next reassess point for the publish-ready push.
2. `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md`
   - Frozen learning architecture / world ladder / progression model.
3. `docs/content/CONTENT_SYSTEM_v2.1.md`
   - Content production and retention system (companion to ULA).
4. `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`
   - World-by-world content plan aligned to ULA + content system.

## Frozen vs Living Rules

- **Frozen**: Versioned SSOT docs above. Do not edit in place unless creating a new versioned SSOT document.
- **Execution override rule**: newer versioned execution documents may narrow or override older execution-mode guidance while leaving product invariants and project-readiness scoring intact.
- **Living**: Drafts, review notes, and exploratory docs belong in non-SSOT locations (for example `docs/_inbox/` before promotion, or other working folders).
- **Living execution rules**: publish-critical execution rules live in `docs/EXECUTION_RULES.md`; historical execution protocol material stays under `docs/reference/history/`.
- **Audit material**: Seam audits and closeout records belong in `docs/audit/` unless explicitly promoted into the SSOT chain.
- **Promotion rule**: New SSOT candidates are reviewed, versioned, then moved into the paths above.
- **Deprecation rule**: Superseded conflicting docs are moved into `docs/_archive/` with a `DEPRECATED` header and retained for history.

Historical readiness note:

- `docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md` is retained for traceability as the frozen historical beta-path model only.

## Links

- [Master Plan v2.2](plan/MASTER_PLAN_v2.2.md)
- [Project Readiness Epics SSOT v1](plan/PROJECT_READINESS_EPICS_SSOT_v1.md)
- [Route To B Execution Reset v1](plan/ROUTE_TO_B_EXECUTION_RESET_v1.md)
- [Route To B Action Ladder v1](plan/ROUTE_TO_B_ACTION_LADDER_v1.md)
- [True Release Readiness SSOT v1 (Historical)](plan/TRUE_RELEASE_READINESS_SSOT_v1.md)
- [Execution Rules](EXECUTION_RULES.md)
- [Unified Learning Architecture v4.3.1](learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md)
- [Content System v2.1](content/CONTENT_SYSTEM_v2.1.md)
- [Content Plan per World v2.1](content/CONTENT_PLAN_PER_WORLD_v2.1.md)
- [Archive Policy v1](governance/ARCHIVE_POLICY_v1.md)
