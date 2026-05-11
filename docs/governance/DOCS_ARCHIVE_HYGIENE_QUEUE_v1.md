# Docs Archive Hygiene Queue v1

Status: ACTIVE GOVERNANCE QUEUE
Last updated: 2026-05-11

## Purpose

Record which documentation moves are safe now, which are blocked by active
references, and which archive standard the repo should follow.

This avoids risky mass-moves while still giving the project a concrete cleanup
path.

## Archive Standard

Use:

1. `docs/_archive/` for broad repo-level deprecated or superseded docs retained
   for traceability
2. `docs/archive/` for immutable repo-level snapshots and stop points
3. `docs/plan/archive/` only for small plan-local historical clusters when
   keeping the archive physically close to the old path reduces churn and keeps
   stubs simple

Do not create multiple competing archive buckets for the same active owner
surface.

## Safe Now

These actions are safe immediately and do not require broad path churn:

1. keep outdated docs marked in-place as historical when they are still heavily
   referenced
2. update active indexes so they stop pointing new work at those docs
3. add explicit replacement pointers inside outdated docs

## Blocked For Now

These files are strong archive candidates, but should not be moved yet because
active docs still reference them directly:

1. `docs/plan/SKILL_COVERAGE_MATRIX_v1.md`
2. `docs/plan/WORLD_NODE_MODE_MATRIX_v1.md`
3. `docs/plan/PROGRESSION_PREREQUISITE_MATRIX_v1.md`

## Required Before Moving Any Blocked File

1. remove or downgrade all active-index references
2. keep replacement pointers from old path to new authority
3. update bucket indexes and placement docs
4. verify that `docs/README_SSOT.md` still presents a clean active chain

## Completed Pilot

1. Route-to-B execution docs now have:
   - archived source copies under `docs/plan/archive/execution_history/`
   - short root stubs at the old paths
   - updated active-index pointers away from the old active framing
2. Queue-history docs now have:
   - archived source copies under `docs/plan/archive/queue_history/`
   - short root stubs at the old paths
   - no remaining active-stack dependence on their old active framing
3. Legacy master plan path now has:
   - archived source at `docs/archive/obsolete_plans/MASTER_PLAN_v2.2.md`
   - short root stub at `docs/plan/MASTER_PLAN_v2.2.md`
   - active-chain replacement pointer to `docs/plan/MASTER_PLAN_v3.0.md`
4. M1 readiness audits v1-v3 now have:
   - archived source copies under `docs/audit/history/`
   - short root stubs at `docs/audit/M1_READINESS_AUDIT_v1.md`,
     `docs/audit/M1_READINESS_AUDIT_v2.md`, and
     `docs/audit/M1_READINESS_AUDIT_v3.md`
   - replacement pointer to `docs/audit/M1_READINESS_AUDIT_v4.md`

## Next Recommended Hygiene Packet

1. audit active references to the three blocked files above
2. classify each reference as:
   - must stay active
   - should point to a newer authority
   - historical trace only
3. only then move the files whose active references have been fully retired

## Goal

Reduce document competition without breaking traceability or making current
links lie.
