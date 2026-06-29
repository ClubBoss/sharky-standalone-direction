# Durable Repair Capsule v1

Status: ACTIVE durable repair capsule. The first concept-family repair memory
slice exists with active/clear candidate resolution and bounded Session Summary
exposure. A pure partial Practice-target mapper exists; durable persistence
expansion and Practice UI admission remain future bounded waves.

## Objective

Maintain deterministic rule-based repair memory that can aggregate
concept-family errors over time and choose the next bounded repair candidate
without ML, AI chat, or solver claims.

## Why This Is Next

- W1-W6 are frozen as source/fixture/validator-backed technical candidates.
- Human QA is the next evidence gate when participants exist.
- If Human QA is unavailable, the next useful product layer is durable repair memory: preserve what the learner missed, why it mattered, and what repair candidate follows.
- Existing first-session repair proof exists.
- First-slice concept-family repair memory now derives summaries, active/clear
  resolution state, and a deterministic next repair candidate from
  `Act0LearningEvidenceHistoryV1`.
- Session Summary can expose a safe `Recommended repair` line from that
  candidate.
- A pure mapper can return an existing Practice launch request for allowlisted
  concept-family candidates or an explicit no-target reason.
- Durable persistence expansion and broader learner-facing exposure remain
  future work.

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

## Implemented First Slice

Concept Family Repair Memory v1.

Purpose:

- Aggregate concept-family error signal deterministically from existing learning
  evidence.
- Group repeated misses by `repair_focus_id` / concept family, with stable
  fallbacks.
- Select one bounded next repair candidate.
- Clear that candidate when the latest evidence for the same concept family is
  correct.
- Expose only a bounded Session Summary `Recommended repair` line.
- Map only explicitly allowlisted concept candidates to existing Practice launch
  requests; unknown, route-locked, bridge-limited, or unsafe targets return
  no-target reasons.

## First Slice DoD

- Stores or derives concept-family error signal deterministically.
- Uses `user_choice`, `correct` / `error_type`, and `time_to_decision` where available.
- Selects a bounded next repair candidate without AI/adaptive claims.
- Keeps candidates active only while the latest same-family evidence is
  incorrect.
- Keeps selection explainable from stored local fields.
- Keeps Practice target mapping deterministic, allowlisted, and route-neutral.
- Keeps queue state reversible and auditable.
- Preserves W1-W6 freeze and does not author new content.
- Exposes proof only through the admitted Session Summary evidence card unless
  a future wave admits another safe owner.
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
