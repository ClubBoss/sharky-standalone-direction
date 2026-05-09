# Decision Record Template

Use this template for Phase 8 and later decisions once the gate in `phase_8_decision_gate.md` is satisfied.

1. **Decision ID / Date / Owner**
   - ID: PHASE8-INIT
   - Date: 2026-02-15
   - Owner: Learning Signals Guild

2. **Context**
   - Reference SSOTs: `phase_8_framing.md`, `phase_8_evidence_readiness.md`, `phase_8_direction_stress_test.md`, `phase_8_decision_gate.md`.
   - Background: Phase 7 locked the intro path and delivered a stable First 5 Minutes baseline; we now need a single evidence-supported direction to unblock Phase 8.

3. **Evidence Summary**
   - Session signals used: `session_start`, `session_end`, adaptive accuracy/time metrics from `training_session_screen.dart`.
   - What each signal tells us: entry volume, completion rate, and decision speed/accuracy trends for new packs, which can reveal personalization friction.

4. **Options Considered**
   - Option 1: Personalization tuning using existing session signals (evidence-supported).
   - Option 2: Economy/progression balance (partially supported, lacks economy telemetry).

5. **Decision Taken**
   - Scope boundary: Personalization tuning within the Golden Hour packs (no new UI screens, no Modern Table changes, no telemetry changes).
   - Dependencies: Maintain Phase 7 guardrails (`content_design_spec.md`, `first_5_minutes_flow.md`, `ux_polish_audit.md`).

6. **Constraints & Non-goals**
   - Constraints: No new telemetry, no new schemas, no UX redesign outside existing Visual Lift scope.
   - Non-goals: Economy tweaks, new gamification, or new content formats.

7. **Risks & Mitigations**
   - Risk 1 / Mitigation: Personalization hypotheses misinterpret aborts → Mitigate by correlating `session_abort` spikes with phase 6 guard tests before rolling out.
   - Risk 2 / Mitigation: Lack of entry-surface segmentation → Mitigate by pairing signal analysis with qualitative notes before widening the tuning scope.

8. **Exit Criteria / Review Trigger**
   - Exit when personalization changes show stable or improved accuracy/time metrics without raising abort rates; review triggered if either metric regresses.

9. **Status**
   - Approved
