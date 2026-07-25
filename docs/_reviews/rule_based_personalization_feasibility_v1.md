---
status: "Gate B admitted"
status_source: "derived"
generated_by: "docs_frontmatter_v1"
---

# Rule-Based AI Personalization v1 — Feasibility

Status: Gate B admitted.

## Gate A

Option B is bounded: extend the active `Act0ShellPreviewScreenV1` owner with
a session-scoped, typed evaluator. Option A is insufficient because the
sequence stage is owned by that shell; Option C is not required.

## Exact owner map

- Progress, sequence stage, repair/recheck, completion, next-step selection,
  and persisted Act0 snapshot: `Act0ShellPreviewScreenV1`.
- Raw decision outcome, `user_choice`, correctness, error type, and decision
  time bucket: `Act0LessonRunnerShellV1` through `Act0CompletedDecisionV1`.
- Telemetry sink: `Act0TelemetrySinkV1`; the shell adds session context and
  remains non-blocking.
- Learner-facing recommendation surface: the canonical runner feedback panel
  owned by `Act0LessonRunnerShellV1`.

## Minimal contract

`Act0ActionSequenceLearnerStateV1` contains only the admitted sequence id,
concept id, and ordered source-derived action outcomes. The evaluator returns
one typed recommendation with a reason, canonical target kind, explanation,
source-evidence summary, and progression-block flag.

It is session-scoped. Existing persistence can truthfully store durable Act0
progress, repair, and evidence contracts, but this pilot does not persist a
parallel learner profile or an unproven recommendation history.

## Boundaries and risks

- No progression or completion owner changes.
- No dormant persona, AI coach, or personalization route is activated.
- No W1-W12 migration is required: the policy admits only
  `w1_action_words_check_v1`.
- The current decision handoff exposes a named time bucket rather than a
  precise duration; slow-correct remains non-failure and does not create an
  unsupported mastery claim.
- Recommendation telemetry is traceable to `source_attempt_key`.

## Gate B admission

Admitted: source outcomes are real runner contracts, state is typed and
testable, the target is deterministic, and the canonical feedback route can
render the explanation without a hub redesign.
