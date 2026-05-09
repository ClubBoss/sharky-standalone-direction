# Execution Governance History

This document clarifies the evolution of execution governance.

## Historical Phases

- Master Plan 3.0 - Table Engine execution phase.
- Master Plan 5.0 - Block discipline and execution immutability phase.
- Master Plan 6.x - Canonical UX / Design governance phase.

These were authoritative during their respective phases.

## Current Execution SSOT

The current authoritative execution chain is:

- `docs/plan/MASTER_PLAN_v2.2.md`
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
- `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md`

Execution decisions should defer in this order:

1. Product invariants and frozen production plan:
   - `docs/plan/MASTER_PLAN_v2.2.md`
2. Project-readiness scoring, true-100 meaning, and bottleneck reporting:
   - `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
3. Current execution mode, Route to B ordering, and active block sizing:
   - `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md`

When older roadmap/review artifacts conflict on block sizing or near-term route order,
`docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md` wins.

Historical documents remain preserved for reference but are not active SSOT.
