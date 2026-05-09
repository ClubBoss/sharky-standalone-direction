# Personalization Coverage Matrix (Phase 8 Signals)

Scope: Maps active personalization surfaces to evidence signals listed in
`docs/canonical/phase_8/phase_8_evidence_readiness.md`.
No new signals, systems, or designs are introduced here.

## Phase 8 evidence signals available
- session_start / session_start_timing_v1
- session_end (TrainingSessionEndReasonV1.completed)
- session_abort (TrainingSessionEndReasonV1.aborted)
- adaptive accuracy/time metrics (AdaptiveProgressionService: accuracy, elapsed time)

## Coverage matrix (active surfaces only)

### Home: Next Action Hint (personalized routing hint)
Signals available: session_start, session_start_timing_v1, session_end, session_abort
Evidence strength: Partial
Safe tuning today (factual): Only outcomes visible at session level (start/abort/completion) can be observed.
Blind spots: No Phase 8 signal for hint exposure, CTA clicks, or per-route success.

### Lesson Focus Bridge (leak detection and focus label)
Signals available: session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level accuracy and time-to-decision can be observed.
Blind spots: No Phase 8 signal for per-lesson leak keys, hint usage, or focus label handoff.

### Learning Path Tag Skill Map (learning signal persistence)
Signals available: session_end, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session completion and accuracy trends are observable.
Blind spots: No Phase 8 signal for per-tag skill deltas or tag-level outcomes.

### Smart Stage Unlocks (reinforcement unlocks)
Signals available: session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session completion/abort and accuracy/time can be observed.
Blind spots: No Phase 8 signal for unlock decisions or their downstream completion impact.

### XP Reward Personalization (tag-based XP multiplier)
Signals available: session_end, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level completion and accuracy/time are observable.
Blind spots: No Phase 8 signal for XP payout, XP effectiveness, or per-tag XP impact.

### Adaptive Training Recommendations (pack list and adaptive pack)
Signals available: session_start, session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level start/abort/completion and accuracy/time can be observed.
Blind spots: No Phase 8 signal for recommendation exposure, selection rate, or pack ranking quality.

### Weak Spot Recommendation (position/type focus)
Signals available: session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session completion and accuracy/time are observable.
Blind spots: No Phase 8 signal for EV/ICM deltas, position-specific outcomes, or weak-spot selection quality.

### Recommendation Feed Cards (dashboard recommendations)
Signals available: session_start, session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level outcomes can be observed after a recommendation is used.
Blind spots: No Phase 8 signal for feed impressions, clicks, or card-level performance.

### Adaptive Pack Recommendations (next pack card and inbox)
Signals available: session_start, session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level outcomes for launched packs are observable.
Blind spots: No Phase 8 signal for inbox exposure, threshold efficacy, or recommendation acceptance rate.

### Adaptive Learning Flow Plan and Session Recommendation Banner
Signals available: session_start, session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level completion and accuracy/time are observable for launched items.
Blind spots: No Phase 8 signal for banner exposure, selection rate, or track recommendation quality.

### Learning Track Recommendations (Next Up widget)
Signals available: session_start, session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session outcomes are observable for launched tracks.
Blind spots: No Phase 8 signal for track recommendation impressions or start deferrals.

### Learning Track Next Pack (track engine)
Signals available: session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session completion and accuracy/time are observable for the next pack.
Blind spots: No Phase 8 signal for pack ordering quality or track progression intent.

### Node Recommendations (training path detail)
Signals available: session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level outcomes for recommended nodes are observable if launched.
Blind spots: No Phase 8 signal for node recommendation exposure or prerequisite adherence.

### Theory Booster Recommendation
Signals available: session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level outcomes of booster sessions are observable.
Blind spots: No Phase 8 signal for booster recommendation exposure or theory-to-booster conversion.

### Personal Recommendation Tasks (tasks and pack list)
Signals available: session_end, session_abort, adaptive accuracy/time metrics
Evidence strength: Partial
Safe tuning today (factual): Session-level outcomes are observable for any launched packs.
Blind spots: No Phase 8 signal for task uptake, task completion, or achievement-driven effects.

### Adaptive Difficulty (AI opponent tuning)
Signals available: None of the Phase 8 signals map to AI difficulty recalibration inputs.
Evidence strength: None
Safe tuning today (factual): No Phase 8 evidence directly supports this surface.
Blind spots: No Phase 8 signal for AI difficulty calibration, unified telemetry summaries, or AI outcome balance.

### Adaptive Progression (difficulty delta recommendation)
Signals available: adaptive accuracy/time metrics, session_end
Evidence strength: Strong
Safe tuning today (factual): This surface is directly fed by the listed adaptive accuracy/time signals and session outcomes.
Blind spots: No Phase 8 signal for per-action correctness or per-spot decision latency.

### Adaptive Table Tuning (visual intensity)
Signals available: None of the Phase 8 signals map to adaptive table tuning inputs.
Evidence strength: None
Safe tuning today (factual): No Phase 8 evidence directly supports this surface.
Blind spots: No Phase 8 signal for adaptive_learning_summary inputs (difficultyMultiplier/topicRepetitionRate).

### Emotion Adaptive Tone
Signals available: None of the Phase 8 signals map to emotion tone inputs.
Evidence strength: None
Safe tuning today (factual): No Phase 8 evidence directly supports this surface.
Blind spots: No Phase 8 signal for ux_feedback_metrics or tone balance outcomes.

