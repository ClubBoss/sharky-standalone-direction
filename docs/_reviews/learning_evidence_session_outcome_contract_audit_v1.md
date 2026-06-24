# Learning Evidence / Session Outcome Data Contract Audit v1

## 1. Verdict

`current_session_evidence_contract_ready`

Active Act0 already owns enough evidence for truthful current-lesson-run
outcomes and current open-repair continuity. It does not own a durable ordered
decision history, so cross-session accuracy, trends, and last-N claims remain
deferred.

## 2. Evidence owner map

| Evidence | Active owner | Persistence | Safe scope |
| --- | --- | --- | --- |
| Current choice / correctness | `Act0LessonRunnerShellV1` and selected `Act0RunnerOptionV1` | Telemetry only; not ordered local history | Current spot. |
| Decision-time bucket | `Act0LessonRunnerShellV1` stopwatch | Telemetry only | Current spot; no raw milliseconds in Act0. |
| Missed signal / skill atom / error identity | `Act0RepairIntentV1` | Open intents are persisted in Act0 progress snapshot | Current open repair. |
| Current lesson-run misses, retries, repair status, XP, skill gains | Act0 preview state lesson-run collections | In memory | Current lesson run. |
| Current lesson-run summary | `Act0BlockCompletionSummaryV1` | In memory / completion display | Current completed lesson run. |
| Progress, XP, task completion, skill values, recent gains, retention, open repairs | `_Act0PersistedProgressV1` via `SharedPreferences` | Durable local snapshot | Progress and open-repair continuity only. |

## 3. Current-session vs durable-history decision

The route supports current-session evidence and selected durable state, not a
durable event ledger.

- Current lesson-run evidence is available: task count, distinct mistake count,
  derived correct count, XP, repair status, and skill-gain deltas.
- Durable local state is available: completed tasks, XP, profile skill values,
  recent gains, retention entries, and open repair intents.
- Durable ordered decision history is not available: there is no persisted
  `Act0LearningEvidenceEventV1` list with per-attempt correctness, decision
  time, expected choice, or timestamp.

## 4. Minimal evidence contract proposal

Do not add a second outcome model now. Reuse the existing two-layer contract:

- Current lesson-run: `Act0BlockCompletionSummaryV1` plus lesson-run mistake,
  retry, XP, and skill-gain state.
- Durable continuity: `_Act0PersistedProgressV1` with open repair intents and
  retention memory.

If a future product need requires cross-session analytics, introduce a bounded
persisted event ledger before claiming accuracy rates, trends, or last-N
evidence. It must define retention, ordering, migration, and privacy policy
as its own wave.

## 5. Implemented tiny slice

No production change. The evidence owners already exist. This audit prevents
a parallel DTO that would diverge from the active session and repair state.

## 6. What Profile can / cannot claim

Profile can truthfully reflect persisted progress, local skill values, recent
gains, current focus, and open-repair continuity when supplied by existing
owners. It cannot claim strength ranking, accuracy trend, repeated error rate,
or "based on your last N decisions."

## 7. What Review can / cannot claim

Review can truthfully show the current open repair and persisted retention
continuity. It cannot claim a durable complete mistake-history backlog or
multi-session error counts.

## 8. What Session Summary can / cannot claim

A lesson-run summary can state actual current-run task count, distinct misses,
derived correct count, XP, and skill-gain deltas. It cannot call itself a
cross-session history, report trend accuracy, or use last-N language.

## 9. Telemetry compatibility

Existing `user_choice`, `task_result`, and `feedback_viewed` events provide
safe event-like evidence, including a decision-time bucket. They are not a
local durable history API. No telemetry schema change is needed for the
current-session contract.

## 10. Boundary proof

- No Profile, Review-history, or Session Summary UI was added.
- No persistence model, route, progression, telemetry schema, content,
  glossary, W11/W12, W13+, Modern Table, premium, ML, or AI change.
- No inaccurate strength, weakness, trend, mastery, leak, or last-N claim.

## 11. Tests / validation

- Existing block-completion summary contracts.
- Repair intent, rule-based decision, resolver, and feedback-rhythm tests.
- `graphify hook-check`, `flutter analyze`, `git diff --check`, and status
  review.

## 12. Next recommended wave

No visible evidence surface is admitted until a product requirement proves
that current-session evidence is insufficient. If that occurs, scope a
separate durable Act0 learning-evidence persistence contract before Profile or
Review history work.
