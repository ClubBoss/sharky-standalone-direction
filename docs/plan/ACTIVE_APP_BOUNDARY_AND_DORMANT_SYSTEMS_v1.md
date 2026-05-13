# ACTIVE_APP_BOUNDARY_AND_DORMANT_SYSTEMS_v1
Status: ACTIVE
Purpose: prevent active product work from drifting into dormant, legacy, or
non-route systems that are still present in the repository.

## Why this file exists

The repository still contains large older families that are real code, but are
not part of the current learner-facing app route.

Without an explicit boundary, agents and humans can waste time reading,
editing, or scoring dormant systems as if they were active product truth.

This file defines the current active app boundary and names the main dormant
families that should not receive new product work by default.

## Active app truth

The current learner-facing app is the Act0 shell route.

Use these first for active product work:

1. `lib/ui_v2/act0_shell/*`
2. `lib/ui_v2/app_root.dart`
3. `lib/ui_v2/ui_v2_beta_shell.dart`
4. `docs/plan/MASTER_PLAN_v3.0.md`
5. `docs/plan/LAUNCH_SURFACE_MECHANISM_v1.md`
6. `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`

Canonical launch product path:

`Placement -> Home -> Learn -> Table -> Result -> Home`

Secondary branches:

- `Review`
- `Play`
- `You`

## Dormant / non-route families

These families are present in the repo but are not part of the current active
app route unless a task explicitly reopens them or a proven dependency seam
requires them:

- `lib/ui_v2/persona/*`
- `lib/ui_v2/ai_coach/*`
- `lib/personalization/*`
- `lib/ui_v3/*`
- legacy learner-facing surfaces under `lib/ui_v2/screens/*` that are not the
  current Act0 entry path
- release/readiness helper families that exist for broader launch governance
  but are not part of the current learner-facing product route

## Default handling rule

If a task asks to improve the current product experience:

- start inside the active Act0 route
- do not reopen dormant families by curiosity
- do not score dormant systems as if they were active app blockers
- do not move code into the active route from dormant families without a
  concrete owner-seam reason

## Archive vs dormant

`Dormant` does not automatically mean `safe to delete`.

Some dormant families may still have:

- compile-time imports
- release/readiness references
- old tests
- compatibility bridges

Before archiving or deleting a dormant family, run a separate dependency audit
wave and classify it as:

1. safe to archive now
2. dormant but still linked
3. still active through a proven dependency seam

## What this file is not

This file does not:

- replace `MASTER_PLAN_v3.0.md`
- replace launch/readiness SSOTs
- authorize broad deletion by itself
- claim dormant systems are worthless

It exists only to keep the active product route clean and prevent confused
priority drift.
