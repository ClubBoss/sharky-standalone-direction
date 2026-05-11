# SHARKY POKER SSOT (Source of Truth)

Status: ARCHIVED / REFERENCE ONLY

This directory defines the current SSOT document hierarchy for product/learning/content planning.

Canonical workspace root: `/Users/elmarsalimzade/Sharky_1.0`

For the full documentation topology, start with `docs/README.md`.
Older neighboring repositories and roots are archive/donor references only and must not replace this root as the active SSOT context.
For doc placement and authority rules, see `docs/governance/DOCS_PLACEMENT_CONTRACT_v1.md`.
Archive and donor material is opt-in only: do not read `docs/archive/`,
`docs/_archive/`, archive buckets, or neighboring donor roots unless the task
explicitly asks for historical/reference retrieval.

## SSOT Hierarchy

1. `docs/plan/MASTER_PLAN_v3.0.md`
   - Execution plan and production sequencing.
1a. `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
   - Canonical readiness scoring, true-100 meaning, block/epic registry, dependency graph, and current bottleneck reporting.
1b. `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md`
   - Current execution mode, A->B gap map, locked Route to B, and active block order for the publish-ready push.
2. `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md`
   - Frozen learning architecture / world ladder / progression model.
3. `docs/content/CONTENT_SYSTEM_v2.1.md`
   - Content production and retention system (companion to ULA).
4. `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`
   - World-by-world content plan aligned to ULA + content system.
5. `docs/l10n/RU_POKER_TERMS_CANON_v1.md`
   - Active Russian terminology and tone canon for launch-facing surfaces.

## Frozen vs Living Rules

- **Frozen**: Versioned SSOT docs above. Do not edit in place unless creating a new versioned SSOT document.
- **Execution override rule**: newer versioned execution documents may narrow or override older execution-mode guidance while leaving product invariants and project-readiness scoring intact.
- **Living**: Drafts, review notes, and exploratory docs belong in non-SSOT locations (for example `docs/_inbox/` before promotion, or other working folders).
- **Living execution rules**: publish-critical execution rules live in `docs/EXECUTION_RULES.md`.
- **Audit material**: Seam audits and closeout records belong in `docs/audit/` unless explicitly promoted into the SSOT chain.
- **Promotion rule**: New SSOT candidates are reviewed, versioned, then moved into the paths above.
- **Deprecation rule**: Superseded conflicting docs should stay outside the active root when possible; if they remain here, they must be clearly marked as historical-only.
- **Compatibility rule**: older intro/core/table-first runtime owners may still
  exist in code; treat them as compatibility seams, not as active content truth.

Historical readiness note:

- `docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md` is retained for traceability as the frozen historical beta-path model only.

## Links

- [Master Plan v3.0](plan/MASTER_PLAN_v3.0.md)
- [Project Readiness Epics SSOT v1](plan/PROJECT_READINESS_EPICS_SSOT_v1.md)
- [Route To B Execution Reset v1](plan/ROUTE_TO_B_EXECUTION_RESET_v1.md)
- [True Release Readiness SSOT v1 (Historical)](plan/TRUE_RELEASE_READINESS_SSOT_v1.md)
- [Execution Rules](EXECUTION_RULES.md)
- [Unified Learning Architecture v4.3.1](learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md)
- [Content System v2.1](content/CONTENT_SYSTEM_v2.1.md)
- [Content Plan per World v2.1](content/CONTENT_PLAN_PER_WORLD_v2.1.md)
- [RU Poker Terms Canon v1](l10n/RU_POKER_TERMS_CANON_v1.md)
- [Archive Policy v1](governance/ARCHIVE_POLICY_v1.md)
