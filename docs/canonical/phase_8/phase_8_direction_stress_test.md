# Phase 8 Direction Stress Test - SSOT

## 1) Purpose
Ensure that any Phase 8 direction is vetted against the evidence gathered in Phase 8 readiness audits before committing to implementation.

## 2) Inputs
- `docs/canonical/phase_8/phase_8_framing.md` (candidate direction categories).  
- `docs/canonical/phase_8/phase_8_evidence_readiness.md` (available signals and blind spots).

## 3) Candidate directions
### Personalization tuning
- Restatement: Refine recommendations, pacing, or tone without altering session mechanics.  
- Signals that support it: `session_start`, `session_end`, adaptive accuracy/time stats capture how individual sessions perform, so we can spot pacing or accuracy slippage per module.  
- Signals missing: No current signal isolates which entry surface (pack list vs module catalog) triggered the session or which user cohort is being personalized, so precise fine-tuning lacks segmentation.
- Feasibility classification: Partially supported.

### Economy/progression balance
- Restatement: Revisit reward/coin progression tied to the Golden Hour.  
- Signals that support it: Completion/abort rates and adaptive performance (accuracy/time) can expose where progression markers fail or cause exit.  
- Signals missing: There is no direct telemetry of earned/chip flows within the first session, so rebalancing economy lacks outcome linkage.  
- Feasibility classification: Partially supported.

### Visual & UX polish
- Restatement: Deepen Visual Lift into fuller polish consistent with Phase 6 guardrails.  
- Signals that support it: Completion/abort rates and adaptive friction counts indirectly signal visual/UX tension, but not concretely tied to visual states.  
- Signals missing: No hook describes specific visual elements or affordance failures; existing telemetry cannot isolate visual variations.  
- Feasibility classification: Not evidence-supported (yet).

### Meta-loop resilience
- Restatement: Explore retention loops or repeat play that honor the Golden Hour.  
- Signals that support it: Completion/abort and adaptive accuracy/time provide a snapshot of first-session success, giving baseline for retention hypotheses.  
- Signals missing: No follow-up retention signals (repeat sessions) exist, so long-term meta-loop hypotheses cannot be validated.  
- Feasibility classification: Not evidence-supported (yet).

## 4) Exclusion rule
Any direction classified as “Not evidence-supported (yet)” (Visual & UX polish, Meta-loop resilience) must not be started in Phase 8 until additional signals or guardrails are documented.

## 5) Non-actions
This document does not add telemetry, does not design solutions, and does not commit to any path; it only filters candidate directions through the existing evidence base.
