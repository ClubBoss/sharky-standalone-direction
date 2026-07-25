# F-16 Canonical Contract Adjudication v1

Status: **CLOSED — 12 of 12 adjudicated and closed.**

Baseline: `1e99912e0a730e0089e20539fdc38d6ddc94bb83` (`origin/main` after PR #51 merge)
Branch: `codex/f16-canonical-contract-closure-v2`

## Verdict vocabulary

`PRODUCTION_REGRESSION` · `STALE_TEST` · `STALE_CLOSURE_CLAIM` ·
`OWNER_DECISION_REQUIRED`

## Adjudication matrix

| # | Test / assertion | Diagnosis at head | Verdict | State |
| ---: | --- | --- | --- | --- |
| 1 | `act0_instruction_content_policy_v1_test` — EN compact contract | The compact instruction segmenter now honors the two-sentence cap. Repair/return supporting copy retains its own uncapped grouping path. | **PRODUCTION_REGRESSION** | **CLOSED** |
| 2 | `act0_instruction_content_policy_v1_test` — RU compact contract | Same scoped instruction-owner repair; no authored RU copy changed. | **PRODUCTION_REGRESSION** | **CLOSED** |
| 2b | `en hand_rankings_flush_drill` — 4 segments > 3 | Genuinely over-long authored body (4 long sentences). Not explained by the grouping bug. | **PRODUCTION_REGRESSION** (authored content) | **CLOSED** |
| 12 | `act0_visual_ux_known_p1_copy_contract_test` — P1 copy | 14 of 15 assertions hold, including **every** forbidden-vague-copy check. Only the literal `Start Volume I` string fails; `5c356710 fix: remove bounded Volume I copy overclaims` deliberately retired it, and Wave 3.9 moved Learn copy behind the `_learnCopyV1(en:, ru:)` seam. | **STALE_TEST** | **CLOSED** |
| 4 | `act0_w4_w5_band_transition_milestone_v1_test` — no-proof safe fallback | Production had already retired the expected string in favor of `Repair result saves the next time you fix one.`; the focused assertion now verifies the current safe fallback. | **STALE_TEST** | **CLOSED** |
| 5 | same — `reinforced proof maps to reinforced` | The receipt/icon owner was correct; the fixture omitted qualifying timed, cross-session transfer evidence. It now supplies that evidence and proves the reinforced role. | **STALE_TEST** | **CLOSED** |
| 6 | `act0_repair_outcome_consumer_v1_test` — banked receipt enrichment | The fixture used retired `improved_v1` instead of the canonical transfer verdict. The visible scenario-specific acknowledgement is now asserted after a valid observation. | **STALE_TEST** | **CLOSED** |
| 10 | `act0_sharky_improvement_observation_v1_test` — idempotency | A single qualifying later correct transfer was incorrectly withheld unless two trailing successes existed. The transfer owner now emits one improvement observation while preserving source identity and de-duplication. | **PRODUCTION_REGRESSION** | **CLOSED** |
| 7–9 | `act0_w9_w10_internal_world_source_template_batch_v1_test` | Master Plan and W9→W10 seam authority confirm the admitted Player Adjustment arc. Assertions now use its semantic four-task order and identity; the runtime owner resolves every admitted task by its source ID. | **STALE_TEST** | **CLOSED** |
| 3 | `act0_wave1_canonical_correctness_trust_v1_test` | Seven W6 runners repeated the W7 title as their subtitle. They now retain `Range Thinking`; the W7 title remains owned by W7. | **PRODUCTION_REGRESSION** | **CLOSED** |
| 11 | `session_result_world1_onboarding_payoff_test` | The retired value key was replaced by the current `session_result_up_next_headline_v1` semantic next-capability assertion. | **STALE_TEST** | **CLOSED** |

## Counts

| Verdict | Count |
| --- | ---: |
| PRODUCTION_REGRESSION | 5 closed |
| STALE_TEST | 7 closed |
| STALE_CLOSURE_CLAIM | 0 |
| OWNER_DECISION_REQUIRED | **0** |
| Diagnosed, verdict pending repair | 0 |

No item required an owner-level product decision.

## Instruction/receipt boundary

`act0BuildInstructionBlocksV1(compact: true)` is **shared**: teaching/instruction
beats *and* repair-receipt / focused-return-reason copy all segment through it.
Adding the sentence cap to `_groupCompactLearningRailSentencesV1` therefore changed
repair-receipt segmentation and broke 6 assertions in the **Tier A blocking** test
`act0_repair_intent_resolver_v1_test` (`main` 21/21 pass → 15 pass / 6 fail),
including *"repair result receipt copy excludes forbidden terms"* and *"exact replay
fixed receipt avoids same-signal claims"*.

Isolation evidence: reverting only the segmenter restores 21/21; the authored-content
edit alone is innocent.

The final repair scopes the cap to instruction/learning-rail rendering and sends
non-instruction supporting copy through `act0BuildSupportingCopyBlocksV1`. Tier A
receipt and return-reason segmentation is therefore preserved.

## Learner-visible production repairs shipped

1. **`hand_rankings_flush_drill` teaching body** — condensed 4 long sentences to 4
   short ones within the 3-segment budget. All teaching points preserved: flush =
   five hearts, CO's straight, ace-high vs royal (hearts do not run T-J-Q-K-A), and
   the rarity reason **including** the ~5,100 vs ~10,200 combination counts. This is
   the one authored row not explained by the grouping bug.

## Test-only contract corrections

1. `act0_visual_ux_known_p1_copy_contract_test` — asserts the current localization
   seam (`en: 'Volume I'`, `en: 'Foundations'`) and now *also* asserts the retired
   overclaim stays absent. Not weakened to generic existence; the forbidden-copy
   half of the contract is unchanged and strengthened by one assertion.

## Assessment fingerprint adjudication

Editing `act0_shell_state_v1.dart` changed its input SHA, and the freshness guard
correctly reported `STALE_FINGERPRINT`. Re-adjudicated in
`tools/contracts/w1_w12_assessment_fingerprint_v1.json`:

- row count **291 — unchanged**;
- assessed-row fingerprint `1318f99a…` — **unchanged** (the second assertion never
  failed, proving the edit touched no assessed row or option);
- input SHA `2502f955…` → `a54c7b10…`, previous baseline retained.

This is source drift in teaching copy only, provably not an assessment change.

## Validation on this branch

| Check | Result |
| --- | --- |
| `flutter analyze` | PASS — no issues |
| F-16 focused suite | PASS — 81 tests across instruction, Tier A, receipts/enrichment, W9/W10, subtitle, and next-value owners |
| `act0_repair_intent_resolver_v1_test` (Tier A) | PASS 21/21 |
| `graphify hook-check` | PASS (graph query unavailable because this clean worktree has no `graphify-out/graph.json`) |
| `git diff --check` | PASS |

## Scope confirmation

No archived runtime was reactivated, Modern Table was untouched, no dependency was
added, and no Human Novice or native proof was performed. PR B owns the separate
test-authority corpus and CI-lane work.
