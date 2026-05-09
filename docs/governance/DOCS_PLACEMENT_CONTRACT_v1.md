# Docs Placement Contract v1

Purpose: keep the docs system stable, low-ambiguity, and easy to navigate.

This contract defines where new docs go, when to update an existing canonical doc instead of creating a new one, and how historical material must be marked.

## 1) Root Rules

Only the following classes may live directly under `docs/`:
- repo-wide navigation entrypoints
- repo-wide governing chain entrypoints
- repo-wide active backlog / parking-lot docs explicitly intended to stay visible

Default root keep list:
- `docs/README.md`
- `docs/README_SSOT.md`
- `docs/ROADMAP_FINAL_100_SSOT.md`
- `docs/deferred_backlog.md`

If a new doc is not clearly in one of those classes, it must not be placed at `docs/` root.

## 2) Active SSOT

A doc qualifies as ACTIVE SSOT only if it defines current governing product, learning, content, or execution truth.

ACTIVE SSOT docs must:
- be part of the chain referenced from `docs/README_SSOT.md`
- use stable versioned naming when appropriate
- avoid competing duplicates covering the same authority scope

If the truth already belongs to an existing SSOT doc, update that doc instead of creating a parallel SSOT.

## 3) Active Plan

Use `docs/plan/` for current execution truth that is not the top SSOT chain itself:
- active policies
- active contracts
- execution maps
- planning indexes
- pacing/readiness rules
- bounded current-state SSOTs tied to ongoing execution

Do not place these in `docs/plan/`:
- closed seam audits
- historical closeouts
- old phase/protocol snapshots
- broad historical reference material

## 4) Reference

Use `docs/reference/` for material that is useful but not current authority.

Use `docs/reference/history/` for:
- old phase specs
- old execution protocols
- freeze points
- historical implementation context

Reference docs must not present themselves as the current source of truth.

## 5) Audit Buckets

Use `docs/audit/investigations/` for:
- bounded active investigations
- reconciliation passes
- seam audits
- policy investigations that are still being worked

Use `docs/audit/closeouts/` for:
- completed bounded audit packets
- closeout records
- “what was proven / deferred / next” checkpoint docs

Use `docs/audit/history/` for:
- older standalone audit reports retained for traceability

Audit docs are evidence, not default authority, unless explicitly promoted.

## 6) Archive / Deprecated

Use `docs/archive/` for immutable snapshots and stop points.

Use `docs/_archive/` for superseded docs retained for traceability.

Move docs to archive/deprecated when they are no longer current guidance and should not visually compete with active execution truth.

## 7) Historical / Deprecated Marking

When a doc is historical or deprecated, mark it by at least one of:
- placement in `docs/reference/history/`, `docs/archive/`, or `docs/_archive/`
- a short header banner such as `HISTORICAL REFERENCE ONLY` or `DEPRECATED / HISTORICAL`

If a deprecated doc had prior authority, it should include or inherit a replacement pointer.

## 8) Create New vs Update Existing

Update an existing canonical doc when:
- the authority scope is unchanged
- the new content refines or extends the same governing truth
- creating a second doc would make readers choose between two “current” sources

Create a new doc when:
- the scope is genuinely different
- a version boundary is required
- the old doc must stay frozen for traceability
- the output is evidence/history rather than governing truth

Default bias:
- update existing SSOT or plan docs before creating new ones
- create new audit/history docs only when the record itself is useful

## 9) Naming / Placement Rules

- Prefer descriptive names over generic ones like `notes`, `thoughts`, or `misc`.
- Use suffixes like `_audit`, `_closeout`, `_contract`, `_policy`, `_registry`, `_index`, or `_ssot` to signal authority and role.
- Do not use `SSOT` in a filename unless the doc truly carries governing truth.
- Do not use `README` for a file that is not acting as a folder entrypoint.
- Avoid putting phase-, roadmap-, or protocol-sounding names at root unless they are truly core.

## 10) Minimal Placement Check

Before adding or moving any doc, answer:
1. Is this governing truth, active plan, reference, audit, or archive?
2. Does an existing canonical doc already own this scope?
3. Will the filename or folder placement overstate authority?
4. If historical, where is the replacement pointer?

If those answers are not clear, do not add the doc until placement is clarified.
