# Repair Loop Coverage Matrix v1

Status: audit-only coverage matrix
Scope: active Act0 repair loop families
Date: 2026-06-18

## 1. Purpose

This artifact classifies the current deterministic repair loop coverage across active Act0 repair families.

The product target is:

`real mistake -> missed signal -> exact repair target -> same-signal rep -> Repaired proof`

This is not an implementation packet. It must not be used as approval to add a generic repair resolver, new dashboard, broad content rewrite, or fake adaptive/AI claims.

## 2. Current Repair Loop Summary

Current Review/Home repair flow:

1. Wrong/suboptimal answer creates a mistake record.
2. Review/Home shows a repair item.
3. Fix calls the repair resolver.
4. Resolver chooses either:
   - exact source replay;
   - an allowlisted mapped repair target;
   - retention replay for aged/owned rechecks.
5. Correct repair marks the source mistake fixed.
6. Review shows compact `Repaired` proof.

Current first-value same-signal flow:

1. Feedback produces a skill receipt with `skillAtomId`, `sourceSignalId`, and `nextRepId`.
2. Home/daily launch maps approved same-signal reps.
3. The mapping avoids relaunching the same target as mapped; it preserves replay fallback when source already is the target.

Current telemetry/proof seams:

- `repair_item_shown` includes `sourceTaskId`, `skillAtomId`, `missedSignal`, `tableSignal`, and open status.
- `repair_item_started` includes `sourceTaskId`, `targetTaskId`, `mappingType`, and in-progress status.
- `repair_item_completed` includes `sourceTaskId`, `targetTaskId`, `outcome`, `correct`, and repaired/open status.
- The `Repaired` proof is shared across exact replay and mapped repair when the correct repair answer completes.

## 3. Current Exact Mapped Families

First-value same-signal receipt mappings:

- `action_read / no_bet_yet` -> `world_1 / fold_check_call_raise / actions_check_drill`
- `board_read / board_cards` from first flop -> `world_1 / your_first_hand / your_first_hand_turn`
- `board_read / board_cards` from non-target source -> `world_1 / cards_ranks_suits / cards_ranks_suits_board_count`
- `price_read / pot_to_call` -> `world_1 / fold_check_call_raise / actions_call_drill`
- `starting_hand_read / hero_cards` -> `world_1 / your_first_hand / your_first_hand_private_cards_recheck`
- `table_read / hero_cards_board_pot` -> `world_1 / what_poker_is / what_poker_is_table_read_recheck`
- `table_position_read / hero_button` -> `world_3 / position_checkpoint / position_checkpoint_position_checkpoint_table_notice`

Review/Home repair resolver mappings:

- W3 CO players-behind / not-last-to-act position repair -> `position_checkpoint_position_checkpoint_table_notice`
- W3 BTN seat-ID repair -> `position_six_seats_position_repair_seat_id_btn`
- W3 UTG seat-ID repair -> `position_six_seats_position_repair_seat_id_utg`
- W3 BTN-last postflop repair -> `button_advantage_position_repair_btn_last_postflop`
- W5 flush draw find -> `flush_draws_w5_flush_draw_recheck_transfer`
- W5 gutshot draw -> `straight_draws_w5_gutshot_contrast_transfer`
- W5/W6 turn and river change mistakes -> `turn_river_changes_w5_turn_texture_shift_transfer` or `turn_river_changes_w5_river_draw_story_transfer`
- W6 value/range and pressure mistakes -> `w6_table_value_line_transfer` or `w6_turn_pressure_shift_transfer`

## 4. Coverage Matrix

| family_id | world/lesson area | example sourceTaskId(s) | missed signal | current behavior | current targetTaskId if mapped | repaired proof | telemetry coverage | learner EV if improved | implementation risk | recommended action | rationale |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `action_read_no_bet` | W1 / fold_check_call_raise | `actions_legal_context` via receipt | No bet faces Hero; check is free | mapped_repair / mapped_reinforcement | `actions_check_drill` | yes | yes | low | low | keep | Early high-value signal already has deterministic same-signal target and replay guard. |
| `action_raise_pressure` | W1 / fold_check_call_raise | `actions_raise_drill` | Raise adds pressure | exact_replay | none | yes | yes | low | low | keep | Source replay is acceptable because the source itself is already the exact action-word repair frame. |
| `price_read_pot_to_call` | W1/W4 price surfaces | `w4_price_table_transfer` via receipt | Pot-to-call / small price | mapped_repair / mapped_reinforcement | `actions_call_drill` | yes | yes | medium | low | keep | Basic price signal has a safe simple target. Future richer price repairs can wait until repeated misses prove need. |
| `board_read_shared_cards` | W1 board basics | `your_first_hand_flop`, `cards_ranks_suits_private_board` via receipt | Board cards are shared | mapped_repair / mapped_reinforcement | `your_first_hand_turn` or `cards_ranks_suits_board_count` | yes | yes | low | low | keep | Deterministic target exists and avoids same-target loops. |
| `starting_hand_read_private_cards` | W1 / your_first_hand | `your_first_hand_preflop` via receipt | Hero's two private cards | mapped_repair / mapped_reinforcement | `your_first_hand_private_cards_recheck` | yes | yes | low | low | keep | First-session starting-hand signal now has a compact recheck. |
| `table_read_hero_board_pot` | W1 / what_poker_is | `what_poker_is_table_read_transfer` via receipt | Hero cards + board + pot | mapped_repair / mapped_reinforcement | `what_poker_is_table_read_recheck` | yes | yes | medium | low | keep | Strong first-value proof target; no broader table-read resolver needed. |
| `matched_chips_side_pot` | W1/W8 pot fundamentals | `what_poker_is_matched_chips_transfer`, `what_poker_is_side_pot_intro` | Only matched chips / side pot eligibility | exact_replay | none | yes | yes | medium | medium | defer | Exact replay has theory recall and is acceptable for now; a side-pot micro-rep could help later but is not top EV for early repair breadth. |
| `table_position_co_players_behind` | W3 / position_checkpoint and apply | `position_apply_early_fold`, `position_checkpoint_btn_call`, `button_advantage_button_vs_cutoff` | CO/late seat still has players behind; not last to act | mapped_repair | `position_checkpoint_position_checkpoint_table_notice` | yes | yes | medium | low | keep_with_watch | This target is exact for players-behind/not-last mistakes, but not for all position mistakes. Keep allowlist narrow. |
| `seat_id_btn` | W3 / position_six_seats, button_advantage | `position_six_seats_positions_button`, `button_advantage_find_button` | Button seat identity | mapped_repair | `position_six_seats_position_repair_seat_id_btn` | yes | yes | low | low | keep | Exact table-tap repair exists. |
| `seat_id_utg` | W3 / position_six_seats | `position_six_seats_positions_utg` | UTG seat identity | mapped_repair | `position_six_seats_position_repair_seat_id_utg` | yes | yes | low | low | keep | Exact table-tap repair exists. |
| `seat_id_other_seats` | W3 / position_six_seats | `position_six_seats_positions_cutoff` and possible HJ/SB/BB seat tasks | Exact named seat identity | exact_replay / unknown | none | yes if replayed | partial | medium | low | add_micro_rep | BTN/UTG are covered; remaining named-seat confusion should not map to BTN/UTG. Add only when source evidence shows repeated seat-ID misses. |
| `btn_last_postflop` | W3 / button_advantage | `button_advantage_button_last` | Button acts last postflop | mapped_repair | `button_advantage_position_repair_btn_last_postflop` | yes | yes | low | low | keep | Exact repair micro-rep now exists and protects this source from generic position repair. |
| `early_late_order` | W3 / position_six_seats | `position_six_seats_positions_late_seat`, `position_six_seats_positions_early_late`, `position_six_seats_seat_order_decision` | Early seats act sooner; late seats see more | exact_replay / unknown | none | yes if replayed | partial | high | low-medium | add_micro_rep | Likely early/frequent table-literacy miss; source replay may explain the same concept but lacks a dedicated contrast repair target. |
| `utg_players_behind_pressure` | W3 / early_vs_late, position_checkpoint, position_apply | `early_vs_late_early_pressure_choice`, `position_checkpoint_position_checkpoint_early_fold`, `position_apply_early_fold` | UTG/early seat has many players behind and less information | mapped_repair currently may fall to CO players-behind target for some sources | `position_checkpoint_position_checkpoint_table_notice` for broad position allowlist | yes | yes | high | medium | add_micro_rep | Highest next EV. Existing CO target is related but not exact for UTG pressure. Add a dedicated UTG players-behind repair before mapping more early-pressure sources. |
| `hand_strength_plus_position` | W3 / same_hand_different_seat, position_apply | `same_hand_different_seat_same_hand_early_fold`, `same_hand_different_seat_same_hand_late_open`, `position_apply_late_open`, `position_apply_hj_fold`, `position_apply_btn_open` | Same hand changes comfort by seat | mapped_repair risk / exact_replay depending source | broad position target for some allowlisted sources | yes | yes | high | medium-high | defer | High product value, but target must avoid charts/solver framing and likely needs a two-frame micro-rep. Do not map to CO players-behind. |
| `w5_flush_draw_recheck` | W5/W6 draw texture | `flush_draws_w5_flush_draw_find` | Flush draw recognition | mapped_repair | `flush_draws_w5_flush_draw_recheck_transfer` | yes | yes | medium | low | keep | Existing mapped transfer is same-family and tested. |
| `w5_gutshot_contrast` | W5/W6 straight draws | `straight_draws_w5_gutshot_draw` | Gutshot vs open-ended draw | mapped_repair | `straight_draws_w5_gutshot_contrast_transfer` | yes | yes | medium | low | keep | Existing mapped transfer is exact enough and tested. |
| `w5_turn_river_story` | W5/W6 street changes | `turn_river_changes_w5_turn_hits`, `turn_river_changes_w5_street_repair`, `turn_river_changes_w5_river_misses` | Turn/river card changes draw story | mapped_repair | `turn_river_changes_w5_turn_texture_shift_transfer` or `turn_river_changes_w5_river_draw_story_transfer` | yes | yes | medium | low | keep | Mapped target is same concept with new frame; current tests cover launch and fixed proof. |
| `w6_value_line_pressure` | W6/W7 pressure lines | `w6_value_range_action`, `w6_bluff_candidate`, `w6_wet_board_repair` | Bucket first; pressure/value line transfer | mapped_repair | `w6_table_value_line_transfer` or `w6_turn_pressure_shift_transfer` | yes | yes | medium | medium | keep_with_watch | Existing nearby transfer mapping works, but these are more advanced. Avoid broad expansion without source-specific evidence. |
| `spr_commitment_side_pot` | W7/W8 stack/pot mechanics | `what_poker_is_side_pot_intro`, possible SPR tasks | Main pot/side pot or SPR commitment frame | exact_replay | none | yes | yes | medium | medium | audit_deeper | Existing replay has theory recall. Dedicated targets may help later, but not enough evidence for immediate repair-pack priority. |
| `late_tournament_icm_m_ratio` | W9+ tournament pressure | `w9_m_ratio_table_window_transfer`, `w9_bubble_table_risk_transfer` | Stack pressure / risk premium | exact_replay / unknown | none | yes if replayed | partial | low for current route | high | defer | Late advanced content is outside current first repair breadth. Avoid prioritizing before W3/W1 repair coverage is complete. |

## 5. Top Gap Ranking

1. `utg_players_behind_pressure`
   - Highest EV because it repairs a core early-position misconception.
   - One exact target can cover `early_vs_late_early_pressure_choice`, `position_checkpoint_position_checkpoint_early_fold`, and selected `position_apply_*` sources when their missed signal is explicitly UTG/early pressure.
   - Current generic CO players-behind target is related but not exact.

2. `early_late_order`
   - High EV because it is foundational table literacy before position-based hand decisions.
   - Implementation can stay small: one contrast rep comparing an early and late seat.
   - Should precede any broad hand-strength-plus-position repair.

3. `seat_id_other_seats`
   - Medium EV because BTN and UTG are now covered, but CO/HJ/SB/BB confusion may still replay source tasks.
   - Add only if active source evidence shows repeated wrong-seat confusion.

4. `hand_strength_plus_position`
   - High learning value, but risk is higher.
   - Needs a precise two-frame repair target; do not map to existing CO players-behind target.

5. `matched_chips_side_pot`
   - Medium value, but current replay with theory recall is acceptable.
   - Can wait until earlier table-reading and position repair breadth is stronger.

## 6. Recommended Next 1-3 Implementation Arcs

### 1. UTG Players-Behind Repair Micro-Rep v1

Goal:

`UTG/early-position mistake -> UTG players behind signal -> exact repair rep -> Repaired proof`

Candidate source tasks:

- `early_vs_late_early_pressure_choice`
- `position_checkpoint_position_checkpoint_early_fold`
- `position_apply_early_fold`

Required target:

- `position_repair_utg_players_behind`

Guard:

- Map only when source copy/metadata says early seat, UTG, exposed, or players behind.
- Do not teach charts, ranges, solver logic, or broad open strategy.

### 2. Early/Late Order Repair Micro-Rep v1

Goal:

`early-vs-late confusion -> visible seat-order contrast -> exact repair rep -> Repaired proof`

Candidate source tasks:

- `position_six_seats_positions_late_seat`
- `position_six_seats_positions_early_late`
- `position_six_seats_seat_order_decision`

Required target:

- `position_repair_early_late_order`

Guard:

- Target must compare seats/order only, not ask for a hand action.

### 3. Same Hand, Different Seat Repair Audit v1

Goal:

Decide whether the same-hand/seat-shift family can be repaired with one exact target or needs two narrower targets.

Candidate source tasks:

- `same_hand_different_seat_same_hand_early_fold`
- `same_hand_different_seat_same_hand_late_open`
- `position_apply_late_open`
- `position_apply_hj_fold`
- `position_apply_btn_open`

Guard:

- Audit first. Do not implement until target wording can remain beginner-safe and non-chart-like.

## 7. Deferred List

- Broad generic position resolver.
- All-seat seat-ID expansion unless wrong-seat evidence supports it.
- Dashboard / Skill Map / Leak Profile.
- Late W9+ tournament repair mappings.
- Side-pot / matched-chip micro-reps until earlier repair coverage is broader.
- W6+ pressure-line expansion beyond existing allowlisted mappings.
- Any repair target that is merely related, not exact.

## 8. Stop Rules For Future Mappings

Stop a future mapping wave if any condition is true:

1. The target does not already exist or is not created as a tiny exact micro-rep in the same bounded wave.
2. The source and target do not share the same missed visible table signal.
3. The mapping would send multiple distinct missed signals to one catch-all target.
4. The repair target is the same source task but is being labeled as mapped.
5. The proposed target requires table geometry, answer dock geometry, Review/Home redesign, dashboard work, or new dependencies.
6. The copy needs solver, GTO, optimal-frequency, chart memorization, or fake AI/adaptive framing.
7. Focused tests cannot assert Fix launch, `targetTaskId`, `mappingType`, `Repaired` proof, and completion telemetry.

## 9. Direction Score

Current repair-loop direction score: 8.5 / 10.

What is strong:

- The loop now has visible proof: mistake -> Fix -> repair runner -> correct -> `Repaired`.
- Core first-value signals have deterministic same-signal targets.
- W3 now has exact targets for BTN seat-ID, UTG seat-ID, BTN-last postflop, and CO players-behind.
- W5/W6 mapped variants show that same-family transfer repair works beyond the first session.

What is still weak:

- Some W3 position sources still risk being over-mapped to the CO players-behind target.
- UTG pressure and early/late order are not yet exact.
- Advanced exact replay is acceptable but less compelling than same-signal repair proof.

## 10. Runout Comparison Based Only On Proven Current Results

Runout remains a packaging benchmark from prior accepted audits: polished trainer framing, strong onboarding, and perceived leak-finding. This matrix does not use new Runout evidence.

Based on current Sharky behavior, Sharky is stronger where it can prove deterministic specificity:

`source mistake -> exact missed signal -> exact targetTaskId -> Repaired proof`

The competitive gap is breadth, not concept. Sharky should expand exact repair coverage one missed signal at a time instead of copying broad adaptive claims or creating a catch-all leak engine.
