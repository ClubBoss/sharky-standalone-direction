# AI Personalization / Rule-Based Repair Layer v1

## 1. Verdict

`current_focus_recommendation_ready`

The active Act0 W1-W10 route already has the minimum deterministic
repair-recommendation contract required for this layer. No duplicate DTO,
telemetry schema, or learner-facing personalization surface is needed in this
wave.

## 2. Owner map

| Need | Active owner | Truth |
| --- | --- | --- |
| User choice | `Act0LessonRunnerShellV1` | Emits `user_choice` with world, lesson, task, choice, and a decision-time bucket. |
| Correctness | `Act0RunnerOptionV1.isCorrect` | Drives `task_result` and feedback quality. |
| Repair error identity | `buildAct0RepairIntentV1` | Derives `result`, `errorType`, missed signal, skill atom, and source identity for a non-correct answer. |
| Repair target / reason | `Act0RepairIntentV1` plus `act0FirstValueSameSignalRepMappingV1` | Resolves same-signal target when launchable; otherwise retains exact replay. |
| Deterministic recommendation | `buildAct0RuleBasedRepairDecisionV1` | Produces action type, target identity, reason code, and rule-based priority. |
| Safe current-focus consumption | `_Act0NextUsefulHandReasonReceiptV1` / copy bridge | Feeds the existing Home, Practice, Review, feedback, repair-result, and session-repair seams. |

## 3. Existing signal inventory

`Act0RepairIntentV1` already owns the safe internal signal requested by this
wave: source world/lesson/task, learner choice, result, error type, missed
signal id/label, skill atom/label, target identity, mapping type, and reason
code.

`Act0RuleBasedRepairDecisionV1` turns an open intent into a deterministic
same-signal repair or exact-replay decision. Its current priority is derived
only from mapping type and supplied repeat count; it does not claim history,
mastery, leaks, AI, or analytics.

Active Act0 telemetry is compatible but intentionally coarser than the
internal repair contract: `user_choice` has `decisionTimeBucket`; `task_result`
has correctness and an `unknown` error type for a miss; `feedback_viewed`
records the safe table-signal and skill-receipt fields. Raw millisecond timing
exists in legacy/non-Act0 paths, not in the active Act0 contract. No timing
schema expansion is required for current-focus repair.

## 4. Minimal contract proposal

Reuse, do not replace:

- `Act0RepairIntentV1` as the active-route repair signal.
- `Act0RuleBasedRepairDecisionV1` as the deterministic recommendation.
- `_Act0NextUsefulHandReasonReceiptV1` and its copy bridge as the approved
  presentation adapter.

Any later public recommendation surface must consume this evidence-backed
chain and must expose only current-spot/current-session truth unless durable
history is separately proven.

## 5. Implemented tiny slice

No production change. The requested tiny slice is already implemented and
covered by existing contract and resolver tests. This wave adds only this
owner-contract audit, avoiding a parallel repair model.

## 6. Why W11/W12 are not required

The signal is created and resolved inside active W1-W10 Act0 tasks. It uses
the active task's source identity and only selects a target that is launchable
on the current route, with exact replay as the deterministic fallback.

## 7. Why W1-W10 migration is not required now

The repair contract receives world, lesson, task, option, signal, and target
identity from the current legacy-compatible route. No consumer failure proves
that a content migration or adapter is necessary.

## 8. User-facing claim safety

Existing rendered copy is concrete and learner-safe: it names a table clue and
the next useful hand. It does not say AI coach, leak detector, mastery,
advanced analytics, GTO, or solver. No new user-facing copy was added.

## 9. Telemetry compatibility

The internal contract is compatible with existing `user_choice`, correctness,
error-type, and decision-time-bucket telemetry without changing its schema.
Internal repair error identity is more specific than the public-safe
`task_result.errorType`; that difference is intentional and does not justify
a telemetry rewrite in this wave.

## 10. Boundary proof

- No ML, LLM, chat, new dashboard, Profile evidence, Review history, session
  summary, repair variant, W11/W12 activation, or W13+ work.
- No route, progression, telemetry schema, content, glossary, premium, or
  Modern Table change.
- No fake evidence counts or durable personalized-history claim.

## 11. Tests / validation

- `test/ui_v2/act0_repair_intent_contract_v1_test.dart`
- `test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart`
- `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `graphify hook-check`, `flutter analyze`, `git diff --check`, and status
  review.

## 12. Next recommended wave

`Rule-Based Repair Recommendation Consumption Audit v1`.

First prove whether the existing internal decision should gain one additional
stable, non-duplicative active-route consumer. Do not add a new UI surface or
claim historical personalization until that consumer has a concrete owner and
evidence boundary.
