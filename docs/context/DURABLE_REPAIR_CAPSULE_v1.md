# Durable Repair Capsule v1

Status: ACTIVE planning capsule. This does not implement durable repair.

## Objective

Prepare a deterministic rule-based repair memory / personalized repair queue that can remember concept-family errors over time and choose the next bounded repair candidate without ML, AI chat, or solver claims.

## Why This Is Next

- W1-W6 are frozen as source/fixture/validator-backed technical candidates.
- Human QA is the next evidence gate when participants exist.
- If Human QA is unavailable, the next useful product layer is durable repair memory: preserve what the learner missed, why it mattered, and what repair candidate follows.
- Existing first-session repair proof exists, but durable all-time repair history and long-lived concept-family memory are not implemented.

## Required Signal Fields

- `user_choice`
- `correct`
- `error_type`
- `time_to_decision`

## Constraints

- No ML.
- No AI chat/persona.
- No solver/GTO claims.
- No W1-W6 rework unless there is regression failure or concrete new evidence.
- No W7-W12 opening.
- No UI redesign.
- No public launch, Human QA, 9.0, or mastery claims.
- No monetization activation.

## Search Entry Points

Search before reading. Start with:

- `repair_focus_id`
- `user_choice`
- `error_type`
- `time_to_decision`
- `session summary`
- `review profile`
- `mistake tracking`
- `repair outcome`
- `Practice this`
- `active repair`

Likely areas to inspect only after search:

- Act0 repair and feedback seams.
- Session summary receipt seams.
- Review / Profile proof surfaces.
- Existing repair queue projection and source handoff tests.

## Recommended First Slice

Concept Family Repair Memory v1.

Purpose:

- Store concept-family error signal deterministically.
- Group repeated misses by `repair_focus_id` / concept family.
- Select one bounded next repair candidate.
- Expose proof through existing feedback/review surfaces if they already exist.

## First Slice DoD

- Stores concept-family error signal deterministically.
- Uses `user_choice`, `correct` / `error_type`, and `time_to_decision` where available.
- Selects a bounded next repair candidate without AI/adaptive claims.
- Keeps selection explainable from stored local fields.
- Keeps queue state reversible and auditable.
- Preserves W1-W6 freeze and does not author new content.
- Exposes proof only through existing feedback/review/session surfaces if already available.
- Includes focused validator/test coverage.
- Does not claim launch readiness, Human QA, monetization, 9.0, or durable mastery.

## Review Questions For A Future Slice

- Which concept family was missed?
- What exact signal proves the miss?
- Is the next repair candidate already source-owned?
- Can the user-facing reason be stated without new UI?
- Does the test prove storage, selection, and claim safety?

## Claim Language

Allowed:

- deterministic repair memory
- rule-based next repair candidate
- concept-family error signal
- local proof
- bounded repair recommendation

Forbidden:

- AI coach
- adaptive solver
- GTO recommendation
- leak solved
- mastered
- fixed forever
- Human-QA-proven
- launch-ready
