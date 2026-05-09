# Phase 8 Sanity Calibration Scope

This addendum repurposes the existing Phase 8 governance (see `DECISION_RECORD_PHASE_8_INIT.md`, `PHASE_8_DECISION_GATE_CHECKLIST.md`, and the observation inputs captured in `OBSERVATION_WINDOW_8_1.md`) by naming the current activity “Sanity Calibration”. The goal is to keep Phase 8 narrowly focused before passing the baton to post-launch fine tuning.

## Scope definition
- **Allowed work:** Coarse configuration tuning only—adjusting thresholds, weights, or constants (scalar parameters) that consume the Phase 8 signals listed in `phase_8_evidence_readiness.md`. Every change must cite a signal, trigger, and entry/exit observation from `OBSERVATION_WINDOW_8_1.md`.
- **Forbidden work:** No new logic, UX pages, telemetry events, or content/material drops. No wandering into Phase 9 topics or lesson design. The Sanity Calibration window is intentionally short and tactical.

## Window & throughput
- Duration: one short micro-cycle (suggested 2 weeks max) starting with the first calibration commit and ending when the continue/exit condition in `PHASE_8_DECISION_GATE_CHECKLIST.md` passes (PASS outcome leads to post-launch fine tuning).
- Changes per cycle: no more than 3 micro-tuning commits to keep the phase lightweight and reversible.

## Hand-off to fine tuning
Once the Sanity Calibration window closes with a PASS on the Decision Gate Checklist, the next phase inherits a stable baseline for finer-grain work (behavioral UX tweaks, telemetry expansion, or content evolution). Until then, maintainers must reference this doc when reviewing PRs, ensuring each parameter tweak remains within the stated scope.
