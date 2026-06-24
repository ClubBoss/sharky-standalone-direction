# Foundation Campaign Rep Contract v1

## Purpose

This contract is the shared authored shape for any foundation rep that may later
become route-backed. It prevents campaign payloads from depending on hidden
assumptions or registry-local curriculum text.

## Universal fields

Every rep must author the following fields:

| Field | Contract |
| --- | --- |
| `world_id` | Stable world owner. |
| `session_id` | Stable source session owner. |
| `rep_id` | Stable ordered rep identity within the session. |
| `source_ref` | Exact authored source reference for review and drift checks. |
| `visible_state` | Complete observable table, action, price, player, and card facts used by the decision. |
| `learner_prompt` | One learner-facing decision prompt. |
| `legal_choices` | Bounded choice IDs and visible labels. |
| `expected_answer` | One expected choice justified by `visible_state`. |
| `target_skill_id` | One observable behavior this rep trains. |
| `error_type` | Stable error classification for an incorrect choice. |
| `correct_feedback` | Factual explanation of the visible signals supporting the answer. |
| `incorrect_feedback` | Factual correction naming the missed visible signal. |
| `repair_cue` | One concrete item to re-check in a similar spot. |
| `telemetry_inputs` | Existing concepts only: user choice, correct/incorrect, error type, time-to-decision, and source/rep identity. |

## Principles

1. Every route-backed rep has visible decision evidence; no expected answer may
   rely on omitted opponent, price, board, or action facts.
2. The expected answer must be justified by the authored visible signals, not
   by private solver logic or reader inference.
3. A repair cue tells the learner exactly what to re-check before the next
   similar decision.
4. Foundation reps do not make solver/GTO, commerce, paywall, AI, mastery, or
   leak claims.
5. Future worlds use this contract directly or supply an explicit adapter that
   proves equivalent fields and preserves their authored targets and feedback.

## Legacy compatibility

W7-W10 deterministic campaign packs are legacy-compatible implementations of
this same product concept: they already contain deterministic learner prompts,
targets, outcomes, and campaign identity, though their facts currently live in
the registry-first `MicroTaskStep` shape. A later adapter/test may demonstrate
field equivalence without rewriting their existing route owners.

W11 is the first source-owned implementation. Its authored packet owns the
same decision facts before any runtime projection or campaign registration is
considered. This is one contract, not a W11-only mechanism.

## Route admission boundary

This contract is authored content only. A rep becomes route-backed only after
its source packet has a reviewed deterministic projection, registry and
canonical admission, a learner-entry owner, and focused route proof. The
contract itself creates no campaign ID, route, progression, entitlement, or UI
state.
