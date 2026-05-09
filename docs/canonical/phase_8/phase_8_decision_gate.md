# Phase 8 Decision Gate - SSOT

## 1) Purpose
Define the governance condition that must be satisfied before Phase 8 may move from framing and analysis into choosing any concrete direction.

## 2) Required inputs
- `docs/canonical/phase_8/phase_8_framing.md` (candidate directions).  
- `docs/canonical/phase_8/phase_8_evidence_readiness.md` (current signal inventory).  
- `docs/canonical/phase_8/phase_8_direction_stress_test.md` (feasibility classification per direction).

## 3) Minimum readiness conditions
- At least one candidate direction is classified as “Evidence-supported” or “Partially supported” in `phase_8_direction_stress_test.md`.  
- Phase 7 artifacts remain locked (`phase_7_completion_and_transition.md`, `content_expansion_execution_plan.md`, First 5 Minutes SSOTs).  
- No drift guards are violated (no incomplete sessions, no open content expansion batch).  
- The blind spots identified in `phase_8_evidence_readiness.md` have either data plans or have been acknowledged as acceptable risks for the chosen direction.

## 4) Forbidden states
- Any direction flagged “Not evidence-supported” still has outstanding blind spots.  
- The First 5 Minutes flow or telemetry invariants have been modified since Phase 7 lock.  
- Expansion plan validations are failing.

## 5) Decision output
- The gate must record a selected direction (category name) plus a defined scope boundary (which modules/UX areas it touches) before any implementation begins, and reference the evidence that satisfied the gate.

## 6) Post-decision rule
Once a direction passes this gate, Phase 8 work proceeds exclusively under that scope and must not branch into other candidate directions until its exit criteria are met and a new SSOT unlocks further choices.
