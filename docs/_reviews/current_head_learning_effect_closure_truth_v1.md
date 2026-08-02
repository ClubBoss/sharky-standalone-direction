---
status: "p2_learning_effect_packet_admitted"
status_source: "post-p1 current-source audit"
doc_date: "2026-08-02"
---

# Current-Head Learning Effect Closure Truth v1

## Baseline and P1 disposition

- Baseline: `58375ada439907bcea4caa91a4d344b334110122`, the normal merge of PR #131; accepted candidate `513134d6f97622f9dd3c3485ffb5dfbb8b66d9e6` is an ancestor.
- `PERSONALIZATION_CONSUMPTION_AND_NEXT_REP_V1` is **CLOSED_CURRENT**. The shared Learning Run policy now consumes specific descriptors for action, position, price, starting-hand, and board-texture outcomes.
- This audit is deterministic source/test tracing. Graphify is stale (`built_at_commit` `31ac1add…`, not this baseline), so it was not used as ownership authority. Native and Human proof remain unperformed.

## Five-family P2 truth matrix

| Family | Source / error / feedback and repair | Recheck and payoff | Actual P2 disposition |
| --- | --- | --- | --- |
| `action_read` | W1 `actions_check_drill`; `misread_action_legality`; Action sequence owns specific no-bet feedback and same-task repair. | Original-source recheck; clean, recovered, and still-needs-practice Learning Run outcomes; action descriptor. | `COMPLETE_CORRECT_FIRST`, `COMPLETE_WRONG_REPAIR_RECHECK`; final selected focus is only static payoff copy. |
| `table_position_read` | W3 typed position source; exact `missedSignalId` / error / feedback / repair adapter. | Same-Button recheck and typed clean/recovered/unresolved outcomes; position descriptor. | `PARTIAL_PAYOFF`: static next practice and duplicate recovered rendering are possible. |
| `price_read` | W4 typed price source; pot-to-call error, feedback, and repair adapter. | Same-price recheck and typed clean/recovered/unresolved outcomes; price descriptor. | `PARTIAL_PAYOFF`: static next practice and duplicate recovered rendering are possible. |
| `starting_hand_read` | W2 `apply_hj_decision`; typed starting-hand error, source-specific feedback, and repair adapter. | Same-signal recheck and typed clean/recovered/unresolved outcomes; PR #131 descriptor. | `PARTIAL_PAYOFF`: static next practice and duplicate recovered rendering are possible. |
| `board_read` | W5 `board_texture_basics_w5_dry_board`; `misread_board_texture`; typed board-texture feedback and repair adapter. | Same-signal recheck and typed clean/recovered/unresolved outcomes; PR #131 descriptor. | `PARTIAL_PAYOFF`: static next practice and duplicate recovered rendering are possible. |

## Reproduced residuals and admission

1. **R1 duplicate recovered payoff:** `strength = clean ?? recovered` makes a recovered-only run render the same result under both Strength and Recovered. This is production-achievable because the policy has no clean result requirement before a payoff is eligible.
2. **R2 static next-practice recommendation:** `next_practice_recommended` emits telemetry and the sheet displays `nextPractice`, but payoff dismissal clears the run and returns to Home without a source-owned next-focus route or state consumer.

`LEARNING_REPAIR_RECHECK_PAYOFF_CLOSURE_V1` is admitted to make payoff evidence mutually exclusive and carry the selected existing source task into one immediate learner-visible continuation. It must preserve current telemetry names/cardinality, the generic unknown-family fallback, Modern Table Maintenance Mode, visual-tooling freeze, and Human QA/HNP prohibition. P3 fresh-entry E2E remains downstream.
