# Repair Transfer Quality Audit v1

Status: audit-only transfer-quality review
Scope: active Act0 deterministic repair reps across mapped W1/W3/W5/W6 families
Date: 2026-06-18

## 1. Purpose

This artifact evaluates whether current deterministic repair reps feel like meaningful teaching transfer, not merely correct routing.

The product question is:

`After a mistake and repair, would a beginner feel: "I understand this table signal better now"?`

This is not an implementation packet. It must not be used as approval for runtime logic, new mappings, new content, UI redesign, telemetry expansion, dashboards, Skill Map, Leak Profile, paywall work, table geometry changes, or fake AI/adaptive claims.

## 2. Current Repair Loop Summary

The active Act0 repair loop is:

`mistake -> repair item -> Repair CTA -> repair runner -> correct repair -> Repaired proof`

What is already strong:

- Home/Review can surface an open repair as a daily action.
- Repair launch can resolve to an exact replay, allowlisted mapped repair target, or same-signal daily rep.
- The runner shows the table, prompt, answer list, feedback, and then returns to Review/Home proof.
- Repair lifecycle telemetry exists for shown, started, and completed states.
- Mapped repairs already avoid broad AI/GTO/solver framing.

Transfer-quality question for this wave:

- Does the target teach the same missed visible table signal in a second usable frame?
- Or does it simply ask the same question again with a new "Repair" label?

## 3. Transfer Quality Rubric

| rating | meaning |
| --- | --- |
| strong | Same missed signal, visible on table, with enough changed context to teach transfer. |
| acceptable | Same signal and beginner-safe, but the target is close to the source or mainly replays recognition. |
| repeat-like | Exact but too similar to the source to feel like a new learned application. |
| weak | Related signal, but not clearly the same missed signal. |
| unknown | Evidence is insufficient from current active seams. |

Additional criteria:

- Beginner clarity: terms are introduced safely and do not depend on solver/chart knowledge.
- Table-first quality: the table exposes the clue rather than relying only on abstract copy.
- Proof continuity: the existing repaired proof appears after a correct repair.
- Competitive value: the repair feels like personal coaching, not generic replay.

## 4. Repair Family Audit Table

| family_id | sourceTaskId example(s) | targetTaskId | missed signal | signal exactness | transfer quality | beginner clarity | table-first quality | copy risk | proof continuity | product EV if improved | recommendation | rationale |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `action_read_no_bet` | `actions_legal_context`, first-value receipt | `actions_check_drill` | No bet faces Hero; check is free. | strong | acceptable | strong | strong | low | yes | medium | keep | The target cleanly binds "no bet yet" to check. It is early and useful, though close to the source action concept. |
| `action_raise_pressure` | `actions_raise_drill` | exact replay | Raise adds chips/pressure; call only matches. | acceptable | repeat-like | strong | acceptable | low | yes | medium | copy_tune_later | Exact replay repairs the action word, but it does not create much second-frame transfer. Good enough for W1, not a top content target. |
| `price_read_pot_to_call` | `w4_price_table_transfer`, first-value receipt | `actions_call_drill` | To-call amount is the price to continue. | acceptable | acceptable | strong | strong | low | yes | medium | copy_tune_later | The signal is visible and beginner-safe. The target is simpler than the source, so it may feel like backing up to basics rather than transferring price judgment. |
| `board_read_shared_cards` | `your_first_hand_flop`, `cards_ranks_suits_private_board` | `your_first_hand_turn` or `cards_ranks_suits_board_count` | Board cards are shared and counted by street. | strong | acceptable | strong | strong | low | yes | low | keep | This is a clean early table-read repair. It teaches visible board count rather than abstract board theory. |
| `starting_hand_read_private_cards` | `your_first_hand_preflop`, first-value receipt | `your_first_hand_private_cards_recheck` | Hero's two private cards. | strong | acceptable | strong | strong | low | yes | medium | keep | The target is exact and beginner-safe. It is close to the original read, but that is acceptable for first-session safety. |
| `table_read_hero_board_pot` | `what_poker_is_table_read_transfer`, first-value receipt | `what_poker_is_table_read_recheck` | Hero cards + board cards + pot. | strong | strong | strong | strong | low | yes | high | keep | This is the strongest W1 transfer: same scan, new spot, new counts, visible table proof, and compact copy. |
| `matched_chips_side_pot` | `what_poker_is_matched_chips_transfer`, `what_poker_is_side_pot_intro` | exact replay | Matched chips / main pot vs side pot eligibility. | acceptable | repeat-like | acceptable | acceptable | medium | yes | medium | audit_deeper | The proof loop works and theory recall helps, but replaying the same side-pot frame is less likely to feel like transfer. A later tiny second-frame pot-eligibility rep may be worthwhile. |
| `table_position_co_players_behind` | `button_advantage_button_vs_cutoff`, `position_checkpoint_table_notice` | `position_checkpoint_position_checkpoint_table_notice` | CO/late seat still has players behind; not last to act. | strong | strong | strong | strong | low | yes | medium | keep | This is a high-quality position transfer because the target asks the user to count visible seats behind before acting. |
| `seat_id_btn` | `position_six_seats_positions_button`, `button_advantage_find_button` | `position_six_seats_position_repair_seat_id_btn` | BTN seat identity / dealer button anchor. | strong | repeat-like | acceptable | strong | low | yes | medium | copy_tune_later | Exact and table-first, but "Tap BTN again" feels like recognition replay more than transfer. Improve later with a second table state where BTN is still identified before action order. |
| `seat_id_utg` | `position_six_seats_positions_utg` | `position_six_seats_position_repair_seat_id_utg` | UTG seat identity / first preflop seat. | strong | repeat-like | acceptable | strong | low | yes | medium | copy_tune_later | Exact and safe, but still a same-object tap. It repairs recognition, not yet transfer into why UTG matters. |
| `btn_last_postflop` | `button_advantage_button_last` | `button_advantage_position_repair_btn_last_postflop` | BTN acts last after the flop in this hand. | strong | acceptable | acceptable | strong | low | yes | medium | keep | The target keeps the same postflop order signal and uses table seats. It is close to source but more applied than pure seat-ID. |
| `utg_players_behind_pressure` | `early_vs_late_early_pressure_choice`, `position_checkpoint_position_checkpoint_early_fold`, `position_apply_early_fold` | `early_vs_late_position_repair_utg_players_behind` | UTG has five players behind and less information. | strong | acceptable | acceptable | strong | low | yes | high | copy_tune_later | The new target is exact and table-first. It still largely repeats the source concept; future copy can make the transfer feel more like "count behind before action" than "remember UTG pressure." |
| `early_late_order` | `position_six_seats_positions_late_seat`, `position_six_seats_positions_early_late`, `position_six_seats_seat_order_decision` | `position_six_seats_position_repair_early_late_order` | UTG acts earlier; BTN sees more first on this six-seat table. | strong | acceptable | strong | strong | low | yes | high | keep | Strong foundational repair. It avoids all-format claims and asks a concrete table-order question. Transfer distance is moderate, not broad. |
| `hand_strength_plus_position` | `same_hand_different_seat_same_hand_early_fold`, `same_hand_different_seat_same_hand_late_open`, `position_apply_late_open`, `position_apply_hj_fold`, `position_apply_btn_open` | none / exact replay depending source | Same hand changes comfort by seat and frame. | unknown | weak | unknown | unknown | medium | partial | high | add_better_transfer_rep | This remains the biggest transfer-quality gap. It is strategically valuable, but should not be mapped to generic position reads. Needs a tiny two-frame same-hand seat-shift repair. |
| `w5_flush_draw_recheck` | `flush_draws_w5_flush_draw_find` | `flush_draws_w5_flush_draw_recheck_transfer` | Four hearts means flush draw, not made flush yet. | strong | strong | strong | strong | low | yes | low | keep | Strong transfer: same signal, different board details, clear "one card short" language, no solver framing. |
| `w5_gutshot_contrast` | `straight_draws_w5_gutshot_draw` | `straight_draws_w5_gutshot_contrast_transfer` | Gutshot has one missing middle rank; not open-ended and not made. | strong | strong | acceptable | acceptable | low | yes | medium | keep | The copy teaches the exact missing-rank read and changes the board enough to feel like transfer. Slight jargon load is acceptable because it is explained. |
| `w5_turn_river_story` | `turn_river_changes_w5_turn_hits`, `turn_river_changes_w5_street_repair`, `turn_river_changes_w5_river_misses` | `turn_river_changes_w5_turn_texture_shift_transfer` or `turn_river_changes_w5_river_draw_story_transfer` | New street card changes, completes, or misses the draw story. | strong | strong | acceptable | strong | medium | yes | medium | keep | Strong table-first transfer. Copy is compact, but words like wetter/texture are slightly more advanced; keep watch for beginner friction. |
| `w6_value_line_pressure` | `w6_value_range_action`, `w6_bluff_candidate`, `w6_wet_board_repair` | `w6_table_value_line_transfer` or `w6_turn_pressure_shift_transfer` | Bucket first; value line or pressure line changes with board/action. | acceptable | acceptable | acceptable | strong | medium | yes | medium | audit_deeper | The targets are real table transfer frames, but W6 concepts are more abstract. Current behavior is acceptable; future work should validate novice copy, not expand mappings broadly. |

## 5. Strongest Repair Examples

1. `table_read_hero_board_pot -> what_poker_is_table_read_recheck`
   - Same signal, new spot, visible Hero cards/board/pot, and a direct "same scan" message.
   - Best current example of Sharky's learning wedge: table signal first, then proof.

2. `table_position_co_players_behind -> position_checkpoint_position_checkpoint_table_notice`
   - A real table-reading repair, not a memorized seat label.
   - The target makes the learner count BTN, SB, and BB behind CO before treating the seat as comfortable.

3. `w5_turn_river_story -> turn_river_changes_w5_*_transfer`
   - Teaches transfer across street changes instead of replaying the source.
   - The board/street state visibly changes and the copy asks for the changed story.

4. `w5_flush_draw_recheck -> flush_draws_w5_flush_draw_recheck_transfer`
   - Beginner-safe: four hearts are pressure, but not a made flush.
   - Low copy risk and high table-signal clarity.

## 6. Weakest / Highest-Risk Repair Examples

1. `hand_strength_plus_position`
   - Highest strategic gap because the learner needs to feel the same hand changes by seat/frame.
   - Current safe behavior is defer/exact replay; a broad mapping would be dangerous.
   - Needs one tiny two-frame target before entering the deterministic repair queue.

2. `seat_id_btn` and `seat_id_utg`
   - Exact and useful, but transfer quality is repeat-like.
   - "Tap BTN again" / "Tap UTG again" fixes recognition but does not yet teach application.
   - This is acceptable for beginner seat-ID, but not enough to be a long-term differentiator.

3. `matched_chips_side_pot`
   - Proof and theory recall exist, but replaying the same side-pot frame is less transfer-rich.
   - Pot eligibility is beginner-sensitive and probably needs a separate second-frame repair later.

4. `w6_value_line_pressure`
   - The targets are legitimate, but concepts are abstract relative to W1/W3/W5.
   - Good enough as a tested transfer, but copy should be manually checked before more W6 expansion.

## 7. Top 1-3 Improvement Arcs

### 1. Same Hand, Different Seat Repair Micro-Rep v1

Goal:

`same-hand position mistake -> same hand, different seat signal -> two-frame repair rep -> Repaired proof`

Why:

- Highest product EV because it converts position from a label into practical table judgment.
- It would make W3 repair feel like personal coaching instead of a seat quiz.

Guard:

- No charts, solver, GTO, or universal hand rules.
- Target must show the same or near-same hand in two seats and ask for the seat/frame read before action.
- Do not map pure seat-ID mistakes to this target.

### 2. Seat-ID Transfer Tune v1

Goal:

Turn `BTN` and `UTG` recognition repairs from pure "tap again" into one extra applied table signal while keeping them beginner-safe.

Possible direction:

- BTN: identify BTN, then name why the dealer button matters in this hand.
- UTG: identify UTG, then name "early / many behind" without action strategy.

Guard:

- Keep current exact table-tap behavior if adding transfer distance would make the rep longer or confusing.

### 3. Pot Eligibility Second-Frame Audit v1

Goal:

Decide whether matched-chip / side-pot replay needs one tiny second-frame repair target.

Why:

- Pot eligibility is conceptually hard for beginners.
- Current replay is safe, but transfer value is limited.

Guard:

- Audit first. Do not implement if it requires broad pot/side-pot content architecture.

## 8. Deferred List

- Broad repair resolver expansion.
- Generic position catch-all repairs.
- All-seat repair pack unless user errors prove need.
- Dashboard, Skill Map, Leak Profile, or analytics surfaces.
- W9+ tournament repair expansion.
- Solver/GTO/chart language.
- All-format claims for seat order or position value.
- Any mapping where the target is only related, not the same visible missed signal.

## 9. Stop Rules For Future Repair Quality Work

Stop a future repair-quality wave if any condition is true:

1. The proposed target does not teach the same visible missed table signal.
2. The target is just the same source task renamed as "transfer."
3. The repair requires table geometry, answer dock geometry, Home/Review redesign, dashboard work, or new dependencies.
4. The copy needs solver, GTO, charts, fake AI, or broad "adaptive trainer" claims.
5. The rep teaches a universal rule where the current table context is narrower.
6. The change cannot preserve current repaired proof and repair lifecycle telemetry.
7. The wave expands beyond one repair family.

## 10. Direction Score

Current repair transfer direction score: 8.4 / 10.

Why this is strong:

- The deterministic repair loop is real and product-visible.
- Many mappings now teach the same missed signal with repaired proof.
- W5 board/draw transfers and W1 table-read recheck are genuinely transfer-rich.
- W3 position coverage is now exact enough to avoid fake catch-all repairs.

Why it is not higher:

- Several W3 repairs are exact but repeat-like.
- Same-hand/different-seat transfer remains the highest-value missing repair target.
- Some advanced W6 transfer copy may be clear to intermediate learners but less beginner-safe than W1/W3/W5.
- Matched-chip / side-pot repair still relies on replay plus recall rather than second-frame transfer.

## 11. Runout / Benchmark-Stack Comparison

This audit uses no new Runout evidence.

Based only on proven current Sharky behavior, Sharky is stronger where the product can honestly show:

`real mistake -> missed table signal -> exact repair target -> same-signal or same-concept rep -> Repaired proof`

Runout remains a benchmark for perceived trainer packaging and adaptive polish from prior accepted work. Sharky's wedge should remain narrower and more honest:

- do not claim AI/adaptive breadth;
- do not copy GTO/trainer packaging;
- keep improving exact repair transfer one visible table signal at a time.

The current competitive gap is not whether Sharky can route repairs. It can. The gap is whether every routed repair feels like a second learned application rather than a correctly mapped replay.
