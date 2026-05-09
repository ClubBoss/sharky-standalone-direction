# Canonical Staged Implementation Plan v1
Status: SSOT-lite
Purpose: Record the agreed implementation order before unified registry/system-map work begins.
Last updated: 2026-03-09

## Use

This document is the in-repo reference for the next implementation phase.
It is not a product SSOT replacing `docs/plan/MASTER_PLAN_v2.2.md`.
It is the execution-order reference for the staged buildout that starts from audited reality and ends with scalable fill/maintenance.

Execution order is fixed:

1. Phase A: Audit reality
2. Phase B: Canonical truth map
3. Phase C: Layered guards
4. Phase D: Full app skeleton
5. Phase E: Systematic fill
6. Phase F: Scale and maintain

## Phase A: Audit Reality

Purpose:
- Establish what actually exists in the repo and product today.
- Separate production-live surfaces from pilots, placeholders, and legacy seams.

Key artifacts / truth layers:
- Campaign topology/order truth
- Reachable user-facing surfaces
- Session-drill surfaces
- Dev-only surfaces
- Mode-family inventory
- Legacy/drift path inventory

Done means:
- Current-state audit exists in repo or closeout history.
- Real vs reachable vs pilot vs placeholder vs legacy is explicitly classified.
- Next implementation work is grounded in repo evidence, not assumptions.

## Phase B: Canonical Truth Map

Purpose:
- Build one implementation-facing registry/map of current product reality.
- Make machine-visible what exists, what is missing, and what is authoritative.

Key artifacts / truth layers:
- Canonical world list
- Canonical node/pack list per world
- Surface ownership per node
- Mode-family ownership per surface
- Reachability classification
- Status classification:
  - production-live
  - pilot-live
  - partial/dormant
  - placeholder/scaffold
  - legacy/misaligned

Role of the unified truth map / registry:
- One place to answer:
  - what exists
  - where it launches
  - which truth source owns it
  - what status it has
  - what gaps remain
- No fake duplicate topology.
- No speculative future nodes marked as real.

Done means:
- Registry/map can describe current app reality without relying on chat memory.
- Each major surface/mode family has a canonical owner and status.
- Missing nodes/surfaces are visible as gaps, not hidden in ad hoc notes.

## Phase C: Layered Guards

Purpose:
- Lock the registry/map to runtime truth.
- Detect drift between canonical docs, launch seams, and reachable UI.

Guard categories:
- Topology/order guards
- Reachability guards
- Surface-routing guards
- Mode-family guards
- Placeholder-gap guards
- Legacy-path guards
- Registry completeness guards

Done means:
- Important registry claims are testable.
- A path cannot silently drift from canonical truth without a failing guard.
- Placeholder or missing surfaces are intentionally marked, not accidentally omitted.

## Phase D: Full App Skeleton

Purpose:
- Create the complete machine-visible product skeleton before broad content fill.
- Make every planned major world/mode/surface visible as real, pilot, or missing.

Key artifacts / truth layers:
- Full world ladder / app skeleton
- Explicit node shells for not-yet-filled areas
- Visible status markers for gaps
- Registry-backed launch ownership

Rules:
- Skeleton first, content second.
- Missing areas should appear as explicit placeholders/scaffolds, not invisible absences.
- No broad styling rewrite is required in this phase unless needed for truthful visibility.

Done means:
- The app surface shows the intended full structure.
- Unfilled sections are visible and machine-classified.
- Future content work becomes bounded slice fill, not architecture guessing.

## Phase E: Systematic Fill

Purpose:
- Fill the skeleton by bounded slices using the registry/map as the source of truth.
- Avoid random expansion and hidden divergence.

Role of bounded slice filling:
- Add or upgrade one slice at a time.
- Each slice updates:
  - registry/map status
  - routing truth
  - guards
  - content/runtime proof

Typical slice unit:
- one host
- one mode cluster
- one world segment
- one reachable legacy cleanup

Done means:
- New work lands against an explicit known gap.
- Progress is cumulative and visible in the registry/map.
- Pilot surfaces can graduate to production-live with explicit status changes.

## Phase F: Scale And Maintain

Purpose:
- Use the registry/map plus guards as the maintenance layer for future expansion.
- Keep future rollout from reintroducing hidden drift.

Key responsibilities:
- Promote slices from pilot to production-live
- Retire or suppress legacy seams
- Keep placeholders/scaffolds explicit until replaced
- Maintain test coverage aligned to registry truth

Done means:
- New prompts can start from in-repo truth instead of reconstructing state manually.
- Expansion decisions are based on current classified reality.
- Drift detection and rollout discipline are part of normal execution.

## Operating Rules

- Evidence first.
- Audit before redesign.
- Registry before broad implementation.
- Guards before large-scale fill.
- Skeleton before systematic expansion.
- Bounded slices only after the skeleton exists.
- No speculation presented as current product reality.

## Practical Next-Step Guidance

If work resumes after this plan:

1. Start from Phase B, not broad implementation.
2. Build the canonical truth map/registry from current audited reality.
3. Add layered guards immediately after the map exists.
4. Do not begin broad fill until the full skeleton is explicit.
