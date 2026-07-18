# Causal Feedback & Durable Learning Receipt v1

Status: PUBLISHED FOR ADMISSION

## Baseline and scope

- Baseline: `c00df374b84b63d757fe716f7c0e6fbead01d72c` (`origin/main`).
- Branch: `codex/causal-feedback-learning-receipt-v1`.
- Scope is canonical Act0 only. No curriculum expansion, persistence schema
  migration, Modern Table change, remote telemetry, ML, or Human QA.

## Ownership and data flow

| Concern | Canonical owner | Disposition |
| --- | --- | --- |
| Decision feedback | `act0_lesson_runner_shell_v1.dart` | Projects the causal contract in the existing feedback surface. |
| Source explanation | `Act0RunnerOptionV1.feedbackReason` | Authored option feedback remains the causal source. |
| Structured clue | `Act0FeedbackSignalProofV1` | Existing table/repair signal projection supplies a learner-safe cue. |
| Repair result | `Act0RepairOutcomeProjectionV1` | Existing persisted source evidence; no duplicate record. |
| Recheck/transfer | `Act0LearningEvidenceHistoryV1` | Existing normalized evidence and review kinds supply proof. |
| Receipt | `Act0LearningReceiptV1` | Pure recomputation; rendered copy is never persisted. |
| Session payoff | `Act0LearningRunPayoffPolicyV1` | Existing run-level payoff remains the sole payoff owner. |
| Next action | `Act0PersonalizedReturnReasonV1` | Existing priority order remains sole Home/Review authority. |
| Telemetry | `Act0TelemetrySinkV1` | Existing exactly-once feedback event gains bounded classification flags. |

## Prior experience and causal contract

Previously, feedback showed authored reason/action contrast and a signal proof,
but lacked one normalized projection for claim-safe next-hand wording. The new
contract uses only selected result, authored option explanation, supplied action
labels and structured clue. It states neither inferred learner reasoning nor
new poker logic.

- Correct: explains the authored observable reason and points to the clue.
- Wrong/suboptimal: retains action contrast, names the supported better action
  only when present, and gives one next-hand instruction.
- Counterfactual: absent unless a caller supplies an existing structured value;
  no prose parsing is used to fabricate one.
- Missing evidence: safe visible-spot fallback.

## Receipt ladder and payoff

`Act0LearningReceiptV1` recomputes the highest proved level in deterministic
order: `attempted`, `same_clue_repaired`, `later_recheck_held`, then
`different_spot_improved`. A correct same-clue repair cannot become transfer by
event order; level 3 requires a correct `unseenTransfer` evidence record on a
different task. Malformed persistence is already skipped by existing parsers
and thus degrades to the last fully proved level.

The existing learning-run payoff remains claim-safe: unresolved evidence wins
over recovered evidence, while Home/Review continue to use the sole
personalized-next-step authority (active repair, retry, due review, real
transfer reinforcement, recent focus, fallback).

## Telemetry and persistence

`feedback_viewed` retains its existing once-per-presentation guard and gains
only `causal_feedback_shown`, `feedback_classification`, and
`counterfactual_available`. It emits no copy, option text, raw evidence IDs,
or learner-reasoning inference. Sink failure remains non-fatal. Receipt data
is recomputed from existing repair outcomes and learning evidence; no schema
or reset behavior changed.

## Validation

- Focused causal/receipt, learning-run payoff and telemetry cone: 35 passing.
- `fast_loop_world1_v1.sh`: passing.
- `release_gate_world1.sh` (Bash 5 because macOS Bash 3 lacks `mapfile`):
  passing.
- Test Authority Tier A: passing.
- Full `flutter analyze`, `graphify hook-check`, and both diff checks: passing.

## Changed-file matrix

| File | Change |
| --- | --- |
| `act0_causal_feedback_contract_v1.dart` | Pure claim-safe causal feedback projection. |
| `act0_learning_receipt_v1.dart` | Pure conservative receipt-ladder projection. |
| `act0_lesson_runner_shell_v1.dart` | Existing feedback UI and event project the contract. |
| `act0_shell_preview_screen_v1.dart` | Existing repair feedback moment projects recomputed receipt copy. |
| `act0_causal_feedback_learning_receipt_v1_test.dart` | Causal feedback and receipt-ladder coverage. |

## Explicit non-claims

This does not claim Human learning effectiveness, durable mastery, broad poker
transfer, completion of the Learning & Personalization macro-wave, or a Human
QA result.
