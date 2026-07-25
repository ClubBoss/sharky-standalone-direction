# F-16 Canonical Contract Adjudication v1

Status: **PARTIAL — 2 of 12 closed; 3 more root-caused with a confirmed diagnosis;
7 diagnosed only.** Node 5 halted on the 18% quota ceiling, not on a blocker.

Baseline: `ff5914fd02eeb13acd19bdb85c7e9bfe8f97e5ce` (`main` after PR #50 merge)
Branch: `claude/canonical-contract-truth-restoration-v1`

## Verdict vocabulary

`PRODUCTION_REGRESSION` · `STALE_TEST` · `STALE_CLOSURE_CLAIM` ·
`OWNER_DECISION_REQUIRED`

## Adjudication matrix

| # | Test / assertion | Diagnosis at head | Verdict | State |
| ---: | --- | --- | --- | --- |
| 1 | `act0_instruction_content_policy_v1_test` — EN compact contract | Root cause identified: `_groupCompactLearningRailSentencesV1` groups sentences by **character budget only** and never enforces the declared `Act0InstructionContentPolicyV1.maxSentencesPerSegment = 2`. Short sentences pile into one segment, so the audit reports authored-content defects that the *grouping owner* produces. **A trial fix adding the cap cleared 8 of 9 rows but broke 6 Tier A `act0_repair_intent_resolver_v1_test` assertions** (repair-receipt and return-reason copy share the same builder). Reverted; see Blast-radius note below. | **PRODUCTION_REGRESSION** (generic owner) — root cause confirmed | **OPEN — needs narrower fix** |
| 2 | `act0_instruction_content_policy_v1_test` — RU compact contract | Same generic owner; the same trial fix cleared all 4 RU rows with no RU copy edited. Reverted with item 1. | **PRODUCTION_REGRESSION** (generic owner) | **OPEN — needs narrower fix** |
| 2b | `en hand_rankings_flush_drill` — 4 segments > 3 | Genuinely over-long authored body (4 long sentences). Not explained by the grouping bug. | **PRODUCTION_REGRESSION** (authored content) | **CLOSED** |
| 12 | `act0_visual_ux_known_p1_copy_contract_test` — P1 copy | 14 of 15 assertions hold, including **every** forbidden-vague-copy check. Only the literal `Start Volume I` string fails; `5c356710 fix: remove bounded Volume I copy overclaims` deliberately retired it, and Wave 3.9 moved Learn copy behind the `_learnCopyV1(en:, ru:)` seam. | **STALE_TEST** | **CLOSED** |
| 4 | `act0_w4_w5_band_transition_milestone_v1_test` — no-proof safe fallback | Expected copy `Repair proof banks the next time you…` exists **nowhere** in `lib/`. The payoff container renders (`keyPrefix` + `_payoff`); the fallback string is absent. | diagnosed; regression vs retired-copy not yet separated | OPEN |
| 5 | same — `reinforced proof maps to reinforced` | `Act0ProofIconRoleV1.reinforced` and key `act0_proof_icon_v1_reinforced` **do** exist and the card computes `proofIconRole` correctly. Icon is inside the `details` block; the test does `pumpAndSettle()`, so **motion staging is ruled out**. Cause is `_hasEarnedProof == false`, i.e. the receipt reaching the card lacks `isBankedFixProof`/`hasReinforcedEvidence`. | diagnosed; same receipt-enrichment family as #6/#10 | OPEN |
| 6 | `act0_repair_outcome_consumer_v1_test` — banked receipt enrichment | Expected `You missed this clue before. On a later hand, you caught it.`; actual `['1 repair completed', '1 completed repair now has later supporting evidence']`. Sibling assertion *"structured fix proof receipt flags itself as banked fix proof"* **passes**, so banking works and only the Sharky enrichment does not attach. | diagnosed; receipt-enrichment family | OPEN |
| 10 | `act0_sharky_improvement_observation_v1_test` — idempotency | **Under**-emission, not duplication: expected 1 observation, got 0, for `laterOrder: 8 / task_even_later`. Neighbouring cases pass — *"duplicate later evidence does not duplicate observation"* and *"a second distinct repair may yield a second observation"* — so the cardinality guard is intact and a recency/window condition suppresses this case. **The title is misleading: no idempotency violation exists.** | diagnosed; receipt-enrichment family | OPEN |
| 7–9 | `act0_w9_w10_internal_world_source_template_batch_v1_test` | W10 template order changed: index 0 is `w10_player_tendency_tag_hidden`, test expects `clear_value_bet_recognition_intro`. Content reordering, not a runtime fault. | likely `STALE_TEST`; needs authoring-authority confirmation | OPEN |
| 3 | `act0_wave1_canonical_correctness_trust_v1_test` | Subtitle `Visible Cards Change Ranges` is present but the contract forbids it as an adjacent stale subtitle. | likely `PRODUCTION_REGRESSION` (stale subtitle) | OPEN |
| 11 | `session_result_world1_onboarding_payoff_test` | Key `session_result_whats_next_value` renders 0 widgets. | diagnosed; owner not yet traced | OPEN |

## Counts

| Verdict | Count |
| --- | ---: |
| PRODUCTION_REGRESSION | 3 identified (1 closed, 2 open pending narrower fix) |
| STALE_TEST | 1 (closed) |
| STALE_CLOSURE_CLAIM | 0 |
| OWNER_DECISION_REQUIRED | **0** |
| Diagnosed, verdict pending repair | 7 |

No item required an owner-level product decision.

## Blast-radius note — why the item 1/2 owner fix was reverted

`act0BuildInstructionBlocksV1(compact: true)` is **shared**: teaching/instruction
beats *and* repair-receipt / focused-return-reason copy all segment through it.
Adding the sentence cap to `_groupCompactLearningRailSentencesV1` therefore changed
repair-receipt segmentation and broke 6 assertions in the **Tier A blocking** test
`act0_repair_intent_resolver_v1_test` (`main` 21/21 pass → 15 pass / 6 fail),
including *"repair result receipt copy excludes forbidden terms"* and *"exact replay
fixed receipt avoids same-signal claims"*.

Isolation evidence: reverting only the segmenter restores 21/21; the authored-content
edit alone is innocent.

The correct fix must decide, as a contract question, whether repair-receipt copy is
also bound by `maxSentencesPerSegment`, and either scope the cap to the instruction
path or update the repair-receipt contracts deliberately. That decision needs more
investigation than the remaining budget allowed, so the cap was **not** shipped.
Shipping it would have traded a non-blocking audit failure for a Tier A blocking
failure.

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
| `act0_instruction_content_policy_v1_test` | 1 PASS / 2 FAIL — items 1+2 remain open by design (cap not shipped) |
| `act0_repair_intent_resolver_v1_test` (Tier A) | PASS 21/21 — protected by reverting the cap |
| `act0_visual_ux_known_p1_copy_contract_test` | PASS |
| census + concept-error + fingerprint guards | PASS 10/10 |
| `./tools/fast_loop_world1_v1.sh` | PASS |
| `git diff --check` | PASS |

## Not performed

Parts 2–5 of Node 5 were not started: the four-class test-authority classification,
the classification gate, the CI lane change, the F-15 corpus disposition, and the
Premium Motion (F-01/F-02) repair. No archived runtime was reactivated, Modern Table
was untouched, and no dependency was added.
