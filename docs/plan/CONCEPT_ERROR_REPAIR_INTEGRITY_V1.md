# Concept Error & Repair Integrity v1

Status: PUBLISHED CONTRACT; terminal verdict is
`CONCEPT_ERROR_REPAIR_BLOCKED_BY_PRODUCT_DEBT` because one source-authored
assessment remains contradictory inside the forbidden copy-repair boundary.

Starting baseline: `e5a83a78864741f1671c05b15ef86bd9824768ef`.
Product contract commit: `d7a8f8d870b5859f07cabacec914f51b711bf0da`.
Publication parity is recorded by the final push verification; a tracked file
cannot contain the object id of the commit that contains that file.

## Owner and compatibility contract

The canonical route remains `AppRoot -> _EntryGate ->
Act0ShellPreviewScreenV1`. `Act0ShellStateV1` owns authored concepts and task
families. `act0_concept_error_contract_v1.dart` owns current misconception
identity. `act0_repair_gap_adjudication_v1.dart` owns the complete prior-gap
inventory. `buildAct0RepairIntentV1` projects an incorrect option into the
concept identity and repair intent. `act0FirstValueSameSignalRepMappingV1`
selects the deterministic target. The preview shell owns presentation,
original-source recheck, Review recovery, and persistence. The lesson runner
owns `user_choice`, `decision_made`, and `task_result` emission.

Error ids are internal, persisted string values and telemetry values; they are
not learner-visible. Schema versions and event names do not change. Legacy
`missed_*`, `thin_*`, and `unknown` values remain readable. Existing specialized
action/price/position compatibility projections may retain their legacy value
while active route decision evidence emits the concept-specific id.

## Concept-error inventory

| Stable id | Learner misconception | Source owner | Eligible repair family |
| --- | --- | --- | --- |
| `confused_table_identity` | learner seat, private cards, board, pot, or table role | first-table identity | table identity |
| `misread_poker_win_condition` | folds, showdown, or pot-award condition | what-poker-is content | poker win condition |
| `confused_chip_commitment_eligibility` | pot/stack, all-in, matched chips, or side-pot eligibility | commitment content | chip commitment eligibility |
| `confused_card_rank_suit` | rank, suit, or rank order | cards/ranks/suits | card rank/suit identity |
| `confused_private_board_cards` | private versus shared board cards | private-board progression | private-board distinction |
| `misread_showdown_hand_strength` | made hand, best five, or showdown winner | rankings/showdown | showdown hand strength |
| `misread_action_legality` | legal action with or without a facing bet | fold/check/call/raise | action legality |
| `misread_table_position` | seat label or table location | position identity | table position identity |
| `misread_position_action_order` | posting, action order, or position information | action-order content | position action order |
| `misread_starting_hand_discipline` | hand bucket, domination risk, or disciplined action | W2 discipline | starting-hand discipline |
| `misread_bet_price` | call price, pot relation, or bounded sizing | W4 price | bet price |
| `misread_bet_purpose` | value, bluff, protection, or denial | W4 purpose | bet purpose |
| `misread_board_texture` | texture, connectivity, or street-change clue | W5 texture | board texture awareness |
| `misread_draw_outs` | draw family, improvement card, or outs count | W5 draws | draw/outs awareness |
| `misread_range_card_removal` | range width, fit, combinations, or visible-card removal | W6/W7 range content | range/card-removal reasoning |
| `misread_stack_depth_risk` | effective stack, SPR, commitment, or depth risk | W8 stack depth | stack-depth risk |
| `misread_tournament_pressure` | survival, risk premium, M-zone, or ladder pressure | W9 pressure | tournament-pressure reasoning |
| `misread_player_adjustment` | tendency, permitted adjustment, or guardrail | W10 adjustment | player-adjustment reasoning |
| `misread_real_play_process` | session focus, trigger, review, or transfer process | W11 transfer | real-play process transfer |
| `misread_mindset_discipline` | outcome bias, reset, or discipline process | W12 mindset | mindset/process discipline |

## Complete 34-row adjudication

Every row below retains original-source recheck. All alternate targets use
introduced knowledge from the same or an earlier world, have a different
authored prompt, and retain `leaksOriginalAnswer=false` and
`requiresFutureKnowledge=false`. Full misconception, candidate, difficulty,
recheck, and compatibility fields are machine-owned in
`act0_repair_gap_adjudication_v1.dart` and guarded exactly.

| # | Source world/lesson/task | Outcome | Target or reason |
| ---: | --- | --- | --- |
| 1 | W1/what_poker_is/`what_poker_is_table_read_recheck` | ALTERNATE_SAME_SIGNAL_TARGET | `what_poker_is_table_read_transfer` |
| 2 | W1/what_poker_is_content/`what_poker_is_pot_stack` | INTENTIONAL_EXACT_REPLAY | pot/stack identity-specific |
| 3 | W1/what_poker_is_content/`what_poker_is_win_ways` | ALTERNATE_SAME_SIGNAL_TARGET | `what_poker_is_live_win_transfer` |
| 4 | W1/what_poker_is_content/`what_poker_is_all_in_meaning` | INTENTIONAL_EXACT_REPLAY | all-in definition-specific |
| 5 | W1/what_poker_is_content/`what_poker_is_matched_chips_transfer` | INTENTIONAL_EXACT_REPLAY | matched eligibility identity-specific |
| 6 | W1/what_poker_is_content/`what_poker_is_live_win_transfer` | ALTERNATE_SAME_SIGNAL_TARGET | `what_poker_is_win_ways` |
| 7 | W1/what_poker_is_content/`what_poker_is_review` | ALTERNATE_SAME_SIGNAL_TARGET | `what_poker_is_live_win_transfer` |
| 8 | W1/cards_ranks_suits/`cards_ranks_suits_theory` | INTENTIONAL_EXACT_REPLAY | deck structure identity-specific |
| 9 | W1/cards_ranks_suits/`cards_ranks_suits_rank_drill` | INTENTIONAL_EXACT_REPLAY | rank identity-specific |
| 10 | W1/cards_ranks_suits/`cards_ranks_suits_suit_drill` | INTENTIONAL_EXACT_REPLAY | suit identity-specific |
| 11 | W1/your_first_hand/`your_first_hand_private_cards_recheck` | ALTERNATE_SAME_SIGNAL_TARGET | W1/cards_ranks_suits/`cards_ranks_suits_private_board` |
| 12 | W1/fold_check_call_raise/`actions_check_drill` | ALTERNATE_SAME_SIGNAL_TARGET | `actions_legal_context` |
| 13 | W1/fold_check_call_raise/`actions_call_drill` | INTENTIONAL_EXACT_REPLAY | call-with-price identity-specific |
| 14 | W1/blinds_action_order/`blinds_posts_drill` | INTENTIONAL_EXACT_REPLAY | forced-post identity-specific |
| 15 | W1/blinds_action_order/`blinds_first_actor` | INTENTIONAL_EXACT_REPLAY | first-actor identity-specific |
| 16 | W1/blinds_action_order/`blinds_last_actor` | INTENTIONAL_EXACT_REPLAY | last-actor identity-specific |
| 17 | W1/blinds_action_order/`blinds_review` | UNRESOLVED_PRODUCT_GAP | prompt/feedback say first actor; authored correct option remains BB |
| 18 | W1/positions/`positions_utg` | INTENTIONAL_EXACT_REPLAY | UTG identity-specific |
| 19 | W1/positions/`positions_cutoff` | INTENTIONAL_EXACT_REPLAY | cutoff identity-specific |
| 20 | W1/positions/`positions_early_late` | ALTERNATE_SAME_SIGNAL_TARGET | `positions_late_seat` |
| 21 | W2/hand_discipline_apply/`apply_hj_decision` | ALTERNATE_SAME_SIGNAL_TARGET | W2/continue_or_let_go/`continue_or_let_go_medium_call_or_fold` |
| 22 | W3/position_six_seats/`position_six_seats_positions_utg` | ALTERNATE_SAME_SIGNAL_TARGET | `position_six_seats_position_repair_seat_id_utg` |
| 23 | W3/position_six_seats/`position_six_seats_hj_co_contrast` | ALTERNATE_SAME_SIGNAL_TARGET | `position_six_seats_positions_cutoff` |
| 24 | W3/position_six_seats/`position_six_seats_positions_cutoff` | ALTERNATE_SAME_SIGNAL_TARGET | `position_six_seats_hj_co_contrast` |
| 25 | W3/position_six_seats/`position_six_seats_sb_recognition` | ALTERNATE_SAME_SIGNAL_TARGET | `position_six_seats_bb_recognition` |
| 26 | W3/position_six_seats/`position_six_seats_bb_recognition` | ALTERNATE_SAME_SIGNAL_TARGET | `position_six_seats_sb_recognition` |
| 27 | W3/position_six_seats/`position_six_seats_position_repair_seat_id_utg` | ALTERNATE_SAME_SIGNAL_TARGET | `position_six_seats_positions_utg` |
| 28 | W3/position_six_seats/`position_six_seats_positions_review` | INTENTIONAL_EXACT_REPLAY | six-seat recap identity-specific |
| 29 | W3/early_vs_late/`early_vs_late_w2_early_position` | ALTERNATE_SAME_SIGNAL_TARGET | `early_vs_late_early_pressure_choice` |
| 30 | W3/early_vs_late/`early_vs_late_early_pressure_choice` | ALTERNATE_SAME_SIGNAL_TARGET | `early_vs_late_position_repair_utg_players_behind` |
| 31 | W3/early_vs_late/`early_vs_late_position_repair_utg_players_behind` | ALTERNATE_SAME_SIGNAL_TARGET | `early_vs_late_early_pressure_choice` |
| 32 | W3/early_vs_late/`early_vs_late_late_info_choice` | ALTERNATE_SAME_SIGNAL_TARGET | `early_vs_late_w2_late_position` |
| 33 | W3/same_hand_different_seat/`same_hand_different_seat_position_repair_same_hand_different_seat` | ALTERNATE_SAME_SIGNAL_TARGET | `same_hand_different_seat_same_hand_early_fold` |
| 34 | W8/spr_and_commitment/`what_poker_is_side_pot_intro` | ALTERNATE_SAME_SIGNAL_TARGET | W1/what_poker_is_content/`what_poker_is_matched_chips_transfer` |

Disposition totals: 20 alternate targets, 13 intentional exact replays, zero
new bounded repair items, and one unresolved product gap. Intentional exact
replay is an explicit allowlist and may launch an assessed theory/review source;
ordinary alternate repairs remain drill-only. The unresolved row is stored for
evidence/Review identity but is deliberately not launched as misleading repair.

## Before/after deterministic census

| Measure | Before | After |
| --- | ---: | ---: |
| assessed tasks | 291 | 291 |
| incorrect options | 466 | 466 |
| distinct active decision error ids | 12 generic values plus unclassified | 20 concept ids |
| incorrect options without repair intent | 22 | 0 |
| different same-signal targets | 257 (88.3%) | 277 (95.2%) |
| unrecorded exact fallback | 34 | 0 |
| intentional exact replay | 0 recorded | 13 |
| new bounded repair items | 0 | 0 |
| unresolved product gaps | 0 recorded | 1 explicit |

Post-change mapping coverage is W1 57/70, W2 29/29, W3 41/42, W4 20/20,
W5 23/23, W6 26/26, W7 5/5, W8 18/18, W9 16/16, W10 15/15,
W11 14/14, and W12 13/13. W1-W6 aggregate is 196/210; W7-W12 is
81/81. Checkpoints are 49/49 and authored repair-target tasks are 24/24.
The 14 non-alternate rows are the 13 explicit intentional replays and the one
unresolved source contradiction; no aggregate claim hides them.

## Compatibility and fingerprint adjudication

The persisted progress schema remains 16; repair intent, learning evidence,
Review mistake history, and resolution receipt schemas remain unchanged.
Round-trip tests accept both the new concept ids and old generic string values.
Review dedup retains source task, repair focus, skill atom, and exact error id;
recheck still returns to the original source task.

Decision telemetry retains event names and payload shape. One wrong decision
emits exactly one `user_choice`, one `decision_made`, and one `task_result`;
each existing applicable `error_type` field receives the same concept id.
No historical trace or local evidence is rewritten.

The assessment fingerprint is not affected. Its sole declared authored input
is `act0_shell_state_v1.dart`, which is unchanged. The serialized payload does
not include the new taxonomy/adjudication registries or runtime target
selection. Row count remains 291, option distribution remains 121/165/5,
correct positions remain 111/116/62/2, and the current fingerprint remains
`433136896f6d9841e74f123a55ca2e4c8ea388412c824e7f661e1e7afe7a9803`.

## Finding dispositions and remaining boundary

## Validation record

- Consolidated focused suite: PASS (110 tests), including exact
  taxonomy/34-row/census guards.
- Repair start/completion, original-source recheck, Review/recovery, repair
  queue, and intentional-exact decision semantics: PASS.
- Persistence current-state round trip and legacy generic repair-intent parse:
  PASS; schema versions unchanged.
- Telemetry value and cardinality guard: PASS; one each of `user_choice`,
  `decision_made`, and `task_result` for the exercised wrong decision.
- W1-W12 assessment fingerprint freshness: PASS.
- Selected canonical route gate: PASS (49 tests in the current manifest run).
- `fast_loop_world1_v1.sh`: PASS.
- `release_gate_world1.sh`: PASS (11 selected files, 49 tests).
- `flutter analyze`: PASS, no issues.
- `graphify hook-check`: PASS.
- `git diff --check`: PASS.
- Generated/plugin drift: PASS; no generated or plugin owner changed.

- CL-LRN-F03: `CLOSED_FIXED`. Every incorrect option on the canonical 291-task
  route now resolves to one of 20 stable misconception ids; legacy values load.
- CL-LRN-F05: `PRODUCT_DEBT_CONFIRMED`. Its inventory and 33 safe dispositions
  are closed, but `blinds_review` cannot be claimed repaired while the authored
  correct option contradicts its question and feedback. This mission did not
  alter already-closed W1 copy.
- CL-LRN-F01/F02/F06/F08/F11 remain open and unchanged.

## Next selection

1. Decision Discrimination (CL-LRN-F06) — selected next Top-1: 121 binary
   assessments, high affected-task count, high deterministic testability, no
   persistence migration, and direct learning/AI-personalization prerequisite
   value.
2. Durable Retention & Transfer (CL-LRN-F01/F08/F11) — waits because time,
   selection policy, persistence, and claim semantics create higher migration
   risk.
3. W7 Depth Authority (CL-LRN-F02) — waits for an outcome-based product/content
   authority; this wave cannot invent it or infer a lesson count.

## Terminal ledger

| Item | Disposition |
| --- | --- |
| CERI-01 Repository preservation | CLOSED_VERIFIED_PASS |
| CERI-02 Runtime owner map | CLOSED_VERIFIED_PASS |
| CERI-03 Current taxonomy census | CLOSED_VERIFIED_PASS |
| CERI-04 Concept-error contract | CLOSED_FIXED |
| CERI-05 Stable error identities | CLOSED_FIXED |
| CERI-06 Legacy compatibility | CLOSED_VERIFIED_PASS |
| CERI-07 Telemetry compatibility | CLOSED_VERIFIED_PASS |
| CERI-08 Persistence compatibility | CLOSED_VERIFIED_PASS |
| CERI-09 34-row inventory | CLOSED_VERIFIED_PASS |
| CERI-10 Alternate-target adjudication | CLOSED_FIXED |
| CERI-11 Intentional-replay adjudication | CLOSED_INTENTIONAL |
| CERI-12 New repair-item adjudication | CLOSED_NOT_APPLICABLE |
| CERI-13 No future-concept mapping | CLOSED_VERIFIED_PASS |
| CERI-14 No answer leakage | CLOSED_VERIFIED_PASS |
| CERI-15 Repair/recheck preservation | CLOSED_VERIFIED_PASS |
| CERI-16 Review/recovery preservation | CLOSED_VERIFIED_PASS |
| CERI-17 Post-repair census | CLOSED_VERIFIED_PASS |
| CERI-18 Fingerprint adjudication | CLOSED_VERIFIED_PASS |
| CERI-19 Focused validation | CLOSED_VERIFIED_PASS |
| CERI-20 Fast/release gates | CLOSED_VERIFIED_PASS |
| CERI-21 Documentation consistency | CLOSED_VERIFIED_PASS |
| CERI-22 Commit and push | CLOSED_VERIFIED_PASS |

The ledger records completed mission work, not closure of the unresolved
`blinds_review` product contradiction. Final Deep Independent Audit, Human
Novice Proof, AI Personalization, and candidate freeze remain blocked.
