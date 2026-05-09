# Phase 8 Decision Options Brief

This brief summarizes candidate directions still eligible for gating through `phase_8_decision_gate.md` by virtue of their evidence-supported or partially supported classification in `phase_8_direction_stress_test.md`.

## Personalization tuning
- Description: refine recommendation pacing, tone, or micro-adaptations while keeping the session flow unchanged, honoring the Learning Philosophy decision-first loop.
- Evidence: existing signals (`session_start`, `session_end`, adaptive accuracy/time stats logged in `training_session_screen.dart`) capture how new content performs within the first pack, so they can show whether personalization tweaks affect accuracy or pause times.
- Blind spots: current telemetry lacks entry-surface segmentation or user cohort labeling, so we cannot yet attribute changes to specific discovery paths.
- Non-goals & constraints: no new telemetry/events, no new schemas, and no Visual Lift changes (see `visual_lift_contract.md`).
- Readiness note: add qualitative context (e.g., survey or review) linking the signal changes to user cohorts before locking a decision.

## Economy / progression balance
- Description: rebalance rewards, chips, or milestone pacing tied to the Golden Hour without altering the core session or introducing gamified loops.
- Evidence: completion/abort rates plus adaptive accuracy/time stats give insight into whether existing progression markers help or hurt decision throughput and completion.
- Blind spots: there is no telemetry for first-session economy flows (earned chips, spend triggers), limiting precision on cause and effect.
- Non-goals & constraints: keep telemetry names fixed (`session_start`, `session_end`, `session_abort`); do not add new achievement gamification (see `learning_philosophy.md`).
- Readiness note: collect manual recall of chip/progression behavior or sample walkthroughs before selecting the direction to ensure the current signals match the new scope.
