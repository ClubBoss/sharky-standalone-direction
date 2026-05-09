# Learning Philosophy - SSOT

## 1) Purpose
Drive a measurable change in how the user makes decisions during training sessions: faster recognition of correct actions and more consistent accuracy across spots, with reduced hesitation and fewer repeat errors in the same session.

## 2) Core principles
- Training is decision-first: every unit of learning is a user action on a spot.
- Determinism only: identical input produces identical outcomes and feedback.
- Small loops: short cycles of attempt, outcome, and retry beat long explanations.
- Visible progress is tied to session results, not narration.
- Friction is minimized only when it improves decision throughput or accuracy.
- Feedback is restrained and factual; no coaching copy or motivational language.
- Outcomes are explicit and binary where possible (correct/incorrect).
- Sessions are bounded; completion is a concrete milestone.

## 3) Learning loop mechanics
Stimulus (spot is shown) -> Decision (user selects an action) -> Outcome (correct/incorrect resolved by rules) -> Retry or advance (next spot or session end) -> Result summary on completion.

## 4) Feedback rules
- Allowed feedback: correctness signals, session summary, and existing outcome indicators.
- Feedback must be immediate and tied to the just-completed decision.
- No explanatory text, theory content, or multi-step coaching inside the loop.
- No additional guidance beyond what already exists in the session flow.

## 5) Personalization stance
- Rule-based and deterministic only.
- No ML, no probabilistic personalization, no new systems.
- Uses existing session outcomes and deterministic thresholds if applicable.

## 6) Anti-goals / drift guards
- Do not add new learning modes, screens, or content types in 6.x.
- Do not introduce narrative lessons, scripts, or story progression.
- Do not expand telemetry beyond existing event names.
- Do not add gamified incentives that change decision behavior.
- Do not rely on external coaching or human feedback loops.

## 7) Acceptance checks
- The proposal preserves the decision-first loop without adding new steps.
- Feedback remains minimal and tied to immediate outcomes.
- No new screens or features are required to implement the proposal.
- Deterministic behavior is preserved for identical inputs.
- The change supports session completion as the primary success signal.
