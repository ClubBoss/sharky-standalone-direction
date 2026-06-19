# Act0 Preview Remaining Blockers Product Decision Lock v1

## 1. Current gate status

Mode: docs-only product decision audit.

No product code, tests, content, localization, geometry thresholds, route logic, repair-intent behavior, commerce, premium/trial/paywall, screenshots, Playwright tooling, visual styling, or test deletion was performed in this wave.

Current evidence reviewed:

- `docs/_reviews/act0_shell_preview_gate_closure_controlled_finish_v1.md`
- `docs/_reviews/act0_shell_preview_contract_split_compact_runner_geometry_navigation_v1h.md`
- `docs/_reviews/act0_preview_remaining_failure_truth_audit_v2.md`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- Current broad preview failure log at `/tmp/act0_shell_preview_finish_broad_2.log`
- Active product authority in `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` and `docs/plan/MASTER_PLAN_v3.0.md`

Known current broad status from the controlled finish:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Result: failed, `+643 -13`
- `./tools/fast_loop_world1_v1.sh`: red on the same preview blockers
- Incoming controlled-finish state records repair-intent focused tests, `flutter analyze`, and `git diff --check` as passing.

This wave inspected the known current failure log instead of rerunning the broad suite. Rerun is optional for this decision-lock wave and would not change the docs-only outcome unless the failure set drifted.

## 2. Remaining 13 failure inventory

1. `First table guide compact table-read transfer keeps the support body within a native-safe compact budget`
2. `First table guide keeps the fourth beat as a bridge from table scan into one preflop setup read`
3. `Compact theory rail teaching bodies stay inside one-bite segment budget`
4. `First Table Guide stays compact at five steps or fewer`
5. `Opening a lower lesson auto-scrolls its inline hub into view`
6. `Returning to the current lesson from a completed lesson reopens only the target after scroll`
7. `Second wrong answer becomes a deeper Review leak`
8. `First related seat-tap drill restores the same table targets after recall close`
9. `Trail history drill embeds temporal context into the prompt owner`
10. `Action trail reveals appended step after state change`
11. `First table guide copy avoids internal route and surface phrasing in the first-run family`
12. `Your first hand teaches street board growth in order`
13. `World completion seeds compact recheck targets and Home surfaces the return reason`

## 3. Product truth classification table

| failing test name | surface | observed mismatch | primary classification | confidence | product EV | recommended next action | do-not-fix-blindly note |
|---|---|---|---|---|---|---|---|
| `First table guide compact table-read transfer keeps the support body within a native-safe compact budget` | First Table Guide content/order/count | Test reads `act0_shell_action_context_line`; finder has no element, causing `Bad state: No element`. | product_decision_blocker | medium | high | Decide whether the current support-body owner/key/copy is still the right first-table guide contract before restoring a key or rewriting the assertion. | Do not add a placeholder context line just to satisfy an old compact-support assertion. |
| `First table guide keeps the fourth beat as a bridge from table scan into one preflop setup read` | First Table Guide content/order/count | Expected five-task sequence; actual sequence includes inserted `what_poker_is_table_read_recheck` before `first_table_guide_one_clear_choice`. | product_decision_blocker | high | high | Make a product/content decision on whether the inserted recheck belongs in First Table Guide. | Do not assume either old five-step order or current six-step order is authoritative without deciding first-value pacing. |
| `Compact theory rail teaching bodies stay inside one-bite segment budget` | Theory micro-bite budget | Expected no offenders; actual offender is `cards_ranks_suits_rank_drill teachingSteps[1] segment 1: 29 words, 2 sentences`. | product_fix_candidate | high | medium | Split or tighten the offending teaching bite if the current one-bite budget remains authoritative. | Do not weaken the budget only because one current segment exceeds it. |
| `First Table Guide stays compact at five steps or fewer` | First Table Guide content/order/count | Expected five visible First Table Guide steps; actual six steps include `what_poker_is_table_read_recheck`. | product_decision_blocker | high | high | Decide five-step compact limit versus six-step learning bridge, then update either content or test contract. | Do not hide a real first-value pacing regression by changing the count assertion first. |
| `Opening a lower lesson auto-scrolls its inline hub into view` | Learn selected-panel harness | Expected `act0_shell_selected_lesson_panel`; actual none mounted after lower lesson open flow. | harness_drift | medium | medium | Refresh Learn harness around current mission-first behavior and valid selected-panel opening states. | Do not change Learn navigation until a real user-visible open failure is reproduced outside stale harness setup. |
| `Returning to the current lesson from a completed lesson reopens only the target after scroll` | Learn selected-panel harness | Expected no selected panel during transition; actual one `act0_shell_selected_lesson_panel` remains mounted. | harness_drift | medium | medium | Split transition-state assertions from final selected-panel assertions and confirm current return behavior. | Do not force panel unmount/remount timing only to match an old transitional expectation. |
| `Second wrong answer becomes a deeper Review leak` | Review/Practice repair-state semantics | Expected `act0_shell_runner_screen` after Practice/Review path; actual no runner screen, with prior evidence showing a clean/empty repair state. | repair_state_semantics_blocker | medium | high | Run a focused repair-state semantics wave to decide whether second wrong should seed a deeper leak, a practice repair, or no open repair. | Do not patch Practice entry, mistake records, or repair-intent lifecycle before deciding the product semantics. |
| `First related seat-tap drill restores the same table targets after recall close` | Theory recall | Helper expected `act0_shell_hint_body`; actual none mounted in the full-theory recall idea flow. | harness_drift | medium | medium | Refresh the recall helper against the current quick-hint/full-idea ownership after runner state is confirmed. | Do not change recall copy or table target state in this wave. |
| `Trail history drill embeds temporal context into the prompt owner` | Action-trail ownership | Expected text `Read what happened`; actual no matching prompt text. | product_decision_blocker | low | medium | Decide whether action-trail drills still own that explicit temporal prompt phrase or whether current prompt ownership moved. | Do not restore the phrase unless action-trail prompt ownership is product-authoritative. |
| `Action trail reveals appended step after state change` | Action-trail ownership | Expected key `act0_shell_action_trail_step_2`; actual none after state change. | product_decision_blocker | low | medium | Decide whether appended action-trail steps should still be visible in this state and which owner renders them. | Do not invent an appended-step renderer without a clear action-history contract. |
| `First table guide copy avoids internal route and surface phrasing in the first-run family` | First Table Guide content/order/count | Expected copy to contain `later lessons move faster`; actual current family copy starts with `One loop first...` and repeats tab/route job phrasing. | product_decision_blocker | medium | high | Decide First Table Guide first-run copy truth, especially whether route/tab language belongs in this family. | Do not blindly restore old phrase or bless current route-heavy copy without first-value copy review. |
| `Your first hand teaches street board growth in order` | Street-board chronology | Expected first board-count sequence `[0, 3, 4, 5]`; actual `[0, 0, 3, 4]`. | content_chronology_blocker | high | high | Decide whether the inserted preflop/setup repeat is product-authoritative; otherwise repair street progression chronology. | Do not update the test to `[0, 0, 3, 4]` unless the chronology decision is locked. |
| `World completion seeds compact recheck targets and Home surfaces the return reason` | World-completion retention return copy | Expected two instances of `Still yours? Run this spot once more.`; actual zero. Current source has shifted retention return copy in at least one owner. | retention_contract_blocker | medium | high | Lock the world-completion retention return-copy contract, then update copy or assertion consistently. | Do not blindly restore this exact string if current retention copy is intentionally product-authoritative. |

## 4. Test-update candidates

No failure should be treated as a plain `test_update_candidate` yet.

Likely future test/harness updates after product decisions:

- Learn selected-panel tests can likely be refreshed as harness drift once the current mission-first opening contract is confirmed.
- Theory recall helper can likely be refreshed if the current quick-hint/full-idea flow is confirmed.
- First Table Guide assertions may become test updates only if six-step guide, current copy, and current support owner are explicitly locked.
- World-completion retention assertion may become a test update only if current retention copy is explicitly locked.

## 5. Product-fix candidates

Primary product-fix candidate:

- `Compact theory rail teaching bodies stay inside one-bite segment budget`

Reason: the current evidence is narrow and objective: one known teaching segment exceeds the one-bite segment budget. If that budget remains product truth, this is a small content/product fix, not a test relaxation.

Conditional product-fix candidates pending decisions:

- First Table Guide step count/order/copy if the added recheck or route-heavy copy harms first-value pacing.
- Street-board chronology if `[0, 0, 3, 4]` is not intentional.
- Review/Practice state if second wrong should deterministically create a deeper repair/leak.
- World-completion retention if the return reason should still surface with the prior compact recheck copy.

## 6. Product-decision blockers

First Table Guide is the largest decision blocker:

- Whether `what_poker_is_table_read_recheck` belongs inside First Table Guide.
- Whether First Table Guide must stay at five visible compact steps.
- Whether the fourth beat must bridge from table scan directly into one preflop setup read.
- Whether the first-run family should contain route/tab phrasing, and whether the old `later lessons move faster` concept remains required.
- Whether the support-body owner/key changed intentionally or drifted accidentally.

Action-trail ownership is also decision-blocked:

- Whether `Read what happened` remains the prompt-owner truth.
- Whether appended action steps should be visible after the tested state change.

Low-confidence action-trail failures are classified as `product_decision_blocker` by rule, not as repair recommendations.

## 7. Content chronology blockers

Street-board chronology is a clear blocker:

- Expected: preflop into flop into turn into river, `[0, 3, 4, 5]`.
- Actual: preflop/setup repeat into flop into turn, `[0, 0, 3, 4]`.

This may be an intentional inserted setup beat, but it affects learning chronology. Do not bless the new order through a test update until content truth says the duplicate preflop count is intentional and beginner-safe.

## 8. Repair-state / retention blockers

Repair-state blocker:

- `Second wrong answer becomes a deeper Review leak`
- The current mismatch is not just a missing key. It may mean the test no longer seeds the repair state correctly, or it may mean the product no longer creates the deeper Review leak expected by the old contract.
- This aligns with the AI Personalization / Rule-Based Repair Layer v1 arc, but the next step should be semantic audit and focused reproduction, not a blind lifecycle patch.

Retention blocker:

- `World completion seeds compact recheck targets and Home surfaces the return reason`
- The expected return reason string is absent. Current code appears to contain at least one newer retention phrase and one older phrase in separate owners.
- This needs a retention-copy contract decision before tests or copy are changed.

## 9. Deferred / obsolete low-EV tests

No remaining failure should be deleted or marked obsolete now.

Deferred lower-EV work:

- Action-trail ownership should wait until First Table Guide and repair-state semantics are not blocking the higher-value first-run and repair loops.
- Theory recall helper should wait for a focused harness refresh unless it shares a runner-state cause with repair-state work.
- Learn selected-panel harness can be repaired safely later, but it is lower product EV than First Table Guide and repair-state semantics.

## 10. Highest-EV next repair wave

Recommended next wave:

`First Table Guide Content Decision + Repair v1`

Ranking against alternatives:

| candidate wave | product EV | risk | expected failure reduction | safe test-only likelihood | real product improvement likelihood | alignment with repair/personalization arc | top-1 alignment | rank |
|---|---|---|---|---|---|---|---|---|
| First Table Guide Content Decision + Repair v1 | high | medium | 4 direct failures | medium after decision | high | medium | high | 1 |
| Review/Practice Repair-State Semantics v1 | high | medium-high | 1 direct failure | low-medium | high | high | high | 2 |
| Learn Selected-Panel Harness Refresh | medium | low-medium | 2 direct failures | high | low-medium | low | medium | 3 |
| Theory Micro-Bite Budget Decision | medium | low | 1 direct failure | low | medium | low | medium | 4 |
| World-Completion Retention Contract v1 | high | medium | 1 direct failure | medium | medium-high | medium | high | 5 |
| Action-Trail Ownership Truth v1 | medium | medium | 2 direct failures | low-medium | medium | medium | medium | 6 |

Why First Table Guide wins:

- It covers the largest single product-truth blocker group, with four direct failures.
- It protects first value: beginner pacing, first table scan, first visible clue, and first-run route language.
- It is high-EV for the top-1 promise because a learner's first table guide must not feel bloated, internal, or chronologically confusing.
- It is safer to decide before repair-state expansion because First Table Guide is upstream of how the learner first understands table clues.

## 11. Acceptance criteria for the next repair wave

For `First Table Guide Content Decision + Repair v1`:

1. Product decision locked: five-step guide, six-step guide, or another explicit count.
2. Decision locked for whether `what_poker_is_table_read_recheck` remains in First Table Guide.
3. Decision locked for fourth-beat order and whether preflop setup read follows table scan directly.
4. Decision locked for first-run route/tab language and whether current copy is too internal.
5. Decision locked for support-body owner/key on compact table-read transfer.
6. If current product truth is correct, update only stale tests with documented rationale.
7. If tests reveal real product drift, make the smallest content/product repair.
8. Run targeted First Table Guide tests and then broad `act0_shell_preview_screen_v1_test.dart`.
9. Do not touch repair-intent behavior, monetization, commerce, premium/trial/paywall, localization, screenshots, Playwright, table geometry, or unrelated content.

## 12. Explicit do not fix blindly list

Do not fix blindly:

- Do not add `act0_shell_action_context_line` only to satisfy a missing-key assertion.
- Do not remove `what_poker_is_table_read_recheck` just to return to five steps.
- Do not bless six First Table Guide steps without deciding first-value pacing.
- Do not weaken the theory micro-bite budget because one segment exceeds it.
- Do not force Learn selected-panel mount/unmount timing without confirming user-visible navigation truth.
- Do not patch Practice or Review runner entry before deciding second-wrong repair-state semantics.
- Do not change theory recall copy or behavior to satisfy a stale helper.
- Do not restore `Read what happened` unless action-trail prompt ownership is locked.
- Do not add `act0_shell_action_trail_step_2` without action-history ownership truth.
- Do not restore `later lessons move faster` or accept current route-heavy copy without First Table Guide copy review.
- Do not update street-board chronology expectations unless `[0, 0, 3, 4]` is product-authoritative.
- Do not restore `Still yours? Run this spot once more.` unless the retention return-copy contract is locked.
- Do not chase broad green by weakening tests that still protect first value, chronology, repair state, or retention.

## Verification

Docs-only verification for this wave:

- Product code changes: none.
- Test changes: none.
- Content/localization changes: none.
- Broad preview suite: not rerun in this wave; current failure set was inspected from the controlled-finish log and review artifacts.
- Required follow-up verification after this file is added: `git diff --check`.
