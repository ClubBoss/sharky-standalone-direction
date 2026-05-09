# R83 Gold Learning Authoring Contract v1

## Purpose
- Lock a compact production authoring standard for early World1 gold learning steps after R81/R82.
- Standardize `Explain -> Do -> Confirm` without broad runtime or schema expansion.

## Canonical step shape
1. `Explain` (pre-click, short):
   - one short setup/context line.
2. `Focus` (pre-click, explicit):
   - one clear notice cue for what to observe before acting.
3. `Do`:
   - one action/task with deterministic legal affordances.
4. `Confirm` (incorrect path):
   - one factual `Why:` line aligned with expected action family.
5. `Confirm` (correct path, selective):
   - one compact `Reinforce:` line only where EV is positive; not always-on.

## Field contract (reuse existing fields)
- Required for covered gold-learning early steps:
  - `contextText`: short setup/context source.
  - `requiredFocusLabelV1` (scenario-truth derived): explicit focus label rendered as `Notice: ...`.
  - action/task prompt + legal action set (existing step + runtime action bar path).
  - `whyV1` (scenario-truth derived): factual incorrect rationale.
- Optional:
  - `insightText`: source for compact reinforcement.

## Pedagogical meaning by field
- `contextText`:
  - frames the spot in 1-2 short lines before click.
- `requiredFocusLabelV1`:
  - declares the specific cue learner must notice before action.
- action/task prompt:
  - asks for one decision, not a multi-branch lecture.
- `whyV1`:
  - causal and factual; explains mismatch reason.
- `insightText`:
  - short reinforcement of the repeatable rule/pattern.

## Copy constraints (production)
- Keep copy short, factual, product-clean.
- No solver jargon (`GTO`, equilibrium, exploitative tree talk).
- No vague praise (`Great job!`, `Nice!`) without factual anchor.
- No wall-of-text, no encyclopedia tone.
- No duplicated focus statements across multiple lines.

## Correct reinforcement policy
- Selective only, not always-on.
- One compact line max (`Reinforce: ...`) when it strengthens transfer.
- Prefer no reinforcement line when the correct line already carries enough signal.
- Reinforcement must not conflict with expected-action/why truth.

## Incorrect why policy
- Must remain factual and coherent with scenario-truth expected family.
- Must not reveal irrelevant extra strategy branches.
- Must not drift into contradictory or motivational fluff.

## Anti-patterns (reject)
- Blind-tap flows (no pre-click setup/focus on covered gold steps).
- Text spam (multiple teaching paragraphs before action).
- Duplicate focus (same cue repeated in setup + notice + prompt).
- Vague non-causal correction.
- Always-on reinforcement regardless of EV.

## Determinism and anti-drift
- Gold-learning surfaces must read one authoritative truth path (scenario-truth + existing runtime composition).
- Runtime safety normalization may stay only as migration-era protection.
- Future rollout should map new covered steps to this contract before widening runtime behavior.

## Adoption rule for future milestones
- Expand coverage in bounded clusters on the same seam first.
- Add validator/tooling enforcement only when invariant boundaries are stable and high-EV to enforce without widening scope.
