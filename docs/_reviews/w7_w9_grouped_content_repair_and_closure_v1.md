---
status: "undeclared"
status_source: "absent"
baseline: "299ea751800d"
generated_by: "docs_frontmatter_v1"
---

# W7-W9 Grouped Content Repair and Closure v1

## Objective

Integrate the accepted W7-W9 verification artifact, repair one grouped content family across W7-W9, and close the batch with source evidence, focused regression proof, and explicit residual Human-QA limits.

## Integrated Verification Proof

- Starting `main` / `origin/main`: `299ea751800d9f54d3835e2a73168b677167d076`.
- Verification branch local / remote: `669f6181633fb7e5effa2ea967cc8c8a5a0511fd`.
- Verification artifact integrated by fast-forward merge into `main`.
- Integrated `main` / `origin/main`: `669f6181633fb7e5effa2ea967cc8c8a5a0511fd`.
- Repair branch: `codex/w7-w9-grouped-content-repair-v1`.
- Repair branch base: `669f6181633fb7e5effa2ea967cc8c8a5a0511fd`.

## Exact Findings Repaired

- DCA-001: repaired the repeated first-option bridge-checkpoint template across `range_checkpoint_review`, `w7_stack_checkpoint`, and `w9_checkpoint_review`.
- DCA-002: repaired W9 completion payoff copy so it no longer claims ladder-pressure learning.
- DCA-003: materially repaired the high-impact distractor family for W7-W9 bridge checkpoints and W7 visible-card source tasks.
- DCA-004: repaired W7 visible-card transfer by adding paired-board transfer coverage with `772`.
- DCA-005: repaired first-use blocker terminology by defining blocker before assessment.

## Exact Findings Deferred Or Rejected

- No DCA finding was rejected.
- DCA-003 is closed for the grouped high-impact family repaired here, but not treated as a full rewrite of all 37 source rows. Lower-impact remaining distractor extremes are deferred as nonblocking family debt because the mission called for one grouped content repair, not broad content expansion.
- Human-QA-only scoring remains capped until the repaired tasks are played in-app and reviewed for pacing, tone, and learner ambiguity.

## Task-By-Task Repair Matrix

| Task | Before | After | Correctness Guard |
| --- | --- | --- | --- |
| `range_checkpoint_review` | Correct answer at index 0; implausible `Guess the line` distractor | Correct answer moved to index 1; distractors now distinguish pot size and board texture from stack-depth bridge | Correct id remains `range_plus_stack_depth` |
| `w7_stack_checkpoint` | Correct answer at index 0; raw chip distractor too thin | Correct answer moved to index 1; raw chip count distractor now plausible but inferior to effective-stack / SPR risk | Correct id remains `range_plus_depth` |
| `w9_checkpoint_review` | Correct answer at index 0; hole-card-only distractor too silly | Correct answer moved to index 1; pressure-plus-overcopied-player-read distractor now plausible but wrong | Correct id remains `pressure_then_adjust` |
| `range_checkpoint_combos` | Uses blocker vocabulary before definition | Hint defines blocker as a visible or known card that removes possible private-card combinations | Correct id remains `sixteen` |
| `visible_card_combo_density_transfer_check` | Transfer only covered `A72` and `K84` | Transfer now covers `A72`, `K84`, and `772`; expected answer teaches matching-rank combo reduction without exact-hand certainty | Correct id remains `visible_rank_reduces_matching_rank_combos` |
| W9 completion payoff | Claimed ladder pressure | Claims survival pressure and risk premium only | No W9 ladder curriculum added |

## Poker-Correctness Proof

The repair preserves the intended poker answers and narrows only copy, ordering, and distractor quality:

- `range_plus_stack_depth` remains correct because the W6-to-W7 bridge is range plus stack-depth risk, not pot size or board texture alone.
- `range_plus_depth` remains correct because W7 stack reasoning needs range plus effective-stack / SPR risk, not raw chip count.
- `pressure_then_adjust` remains correct because W9 tournament decisions start with map pressure and then adjust by player type; copying every player read after pressure is too broad.
- `sixteen` remains correct because blocker language explains the removal concept without changing the AK-combo count.
- `visible_rank_reduces_matching_rank_combos` remains correct because visible cards reduce matching-rank combinations on A-high, K-high, and paired-board contexts without proving one exact hand.

## Checkpoint Template Proof

The repaired bridge checkpoints no longer share the accepted artifact's repeated leak pattern:

- Previous correct-index pattern: `[0, 0, 0]`.
- Repaired correct-index pattern: `[1, 1, 1]`.
- Each bridge checkpoint still has exactly one correct option.
- Removed or replaced the weakest labels: `Guess the line`, `Chip count only`, and `Use only hole cards and ignore pressure`.

## W9 Payoff Proof

W9 completion copy now says: `You learned how survival pressure and risk premium change decisions.`

This matches the current W9 source scope and does not claim ladder-pressure curriculum delivery.

## Distractor-Family Repair Proof

The grouped repair targets the most learner-visible and assessment-sensitive rows:

- W6-to-W7 bridge checkpoint distractors now separate stack depth from pot size and board texture.
- W7 stack checkpoint distractors now separate effective-stack risk from raw chips.
- W9 tournament checkpoint distractors now separate pressure-first adjustment from overcopied player reads.
- W7 visible-card intro and transfer distractors now avoid absolute claims such as "must have", "never", and "always".

## W7 Transfer Proof

The W7 visible-card transfer now explicitly compares `A72 rainbow`, `K84 rainbow`, and `772 rainbow`.

The expected answer remains source-owned and teaches that visible ranks reduce matching-rank combinations, including sevens on paired boards, without proving one exact hand.

## Blocker Terminology Proof

The first required blocker assessment now introduces the term before using it:

- "A blocker is a visible or known card that removes possible private-card combinations."

The assessment still asks for the same AK combo count and keeps the expected answer unchanged.

## Non-Regression Proof

The repair did not change route admission, progression contracts, callback contracts, telemetry schemas, or W10+ content. Existing route and callback regression files remain in the focused validation set.

## Focused Validation

- `flutter test test/guards/w7_w9_grouped_content_repair_contract_test.dart test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart`
  - Result: pass, `+97: All tests passed!`
- `flutter test test/ui_v2/act0_w7_w9_same_signal_repair_recheck_v1_test.dart test/guards/w8_w9_canonical_identity_ownership_reconciliation_contract_test.dart test/guards/w7_w10_route_status_alignment_contract_test.dart test/ui_v2/act0_completed_decision_callback_contract_v1_test.dart`
  - Result: pass, `+19: All tests passed!`

Additional final checks are recorded in the closing commit and final mission report.

## Provisional Source-Only Rescore

| Dimension | Before | After | Cap |
| --- | --- | --- | --- |
| Assessment validity | Repeated template leak and thin distractors lowered confidence | Bridge checkpoints now have unique plausible distractor families and exact-answer guards | Human-QA capped |
| Payoff honesty | W9 overclaimed ladder pressure | W9 claims only survival pressure and risk premium | Source-verified |
| Transfer coverage | W7 transfer omitted paired-board case | W7 transfer includes `772` paired-board logic | Human-QA capped |
| Terminology | Blocker term appeared before definition | First use defines blocker before assessment | Source-verified |

This source-only pass does not award a final 9/10 or 10/10 content rating without live Human QA.

## Remaining Human-QA-Only Questions

- Whether repaired distractors feel challenging but not ambiguous in live learner flow.
- Whether W7 visible-card transfer pacing remains clear when `772` is added.
- Whether W9 payoff language feels sufficiently motivating after removing the ladder-pressure overclaim.

## Final W7-W9 Batch Verdict

`w7_w9_batch_closed_with_nonblocking_deferred_debt`

The accepted W7-W9 verification artifact is integrated on `main`, the grouped high-impact content repair is source-complete, and remaining DCA-003 breadth is deferred as nonblocking family debt rather than blocking the batch.

## Token Efficiency Report

- Exact token usage: unavailable in local execution context.
- Model used: GPT-5 Codex.
- Scope control: read the accepted verification artifact, admitted W7-W9 source owners, and focused regression tests only.
- Broad repo reading: avoided.
- Full-suite run: avoided by mission scope; focused validation used instead.
- Escalation: not required.
