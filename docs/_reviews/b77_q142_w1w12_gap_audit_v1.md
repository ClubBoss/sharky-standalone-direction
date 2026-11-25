# B77 · Q14.2 — W1–W12 teaching-gap audit (W5–W12 delta)

**Disposition: audit complete, seven bounded copy issues proposed; repairs not performed.** Q14.2 is the audit action, not closure of those repairs, the full Q14 gate, or a finding of Human Novice comprehension.

## Scope and method

- Branch `codex/b77-q142-gap-audit`, base `a6d7627366e76224d8b1814127fe7a331de44d9a`. Read-only catalog/app; the source is `test/fixtures/act0_catalog_snapshot_v1.txt` through (not including) the REPAIR-ONLY marker. This is the canonical non-repair authored course sequence used by C5, not an observed device traversal or a count of mandatory tasks. The snapshot actually has 506 catalog tasks, 498 before the repair marker, of which 283 are W5–W12; do not substitute the brief's 369-task estimate or count supplemental Day 7/Rules Check entries. W1–W4 are consulted only as preceding teaching surfaces; their 468 C5 entries belong to B76.
- Reuse the earlier [known-debt closure](w1_w12_known_deferred_debt_burn_and_closure_v1.md#5-already-closed-items) (do not re-open the already-closed W5 texture transfer or W7–W12 terminology/checkpoint work), [full-route quality gate](full_w1_w12_e2e_curriculum_product_quality_gate_v1.md#6-required-final-gate-checks) (prior no-red-gap result was not Human proof), and [feedback audit rubric](archive/2026-07/learning_truth_feedback_audit_packet_v1.md) (explain the selected mistake, not just failure). The historical audits describe earlier catalog shapes; current snapshot evidence takes precedence. B76's candidate report in its separate worktree records 48 W5–W12 removals by shared guard corrections only; no W5+ copy change. Do not multiply that guard work; rerun after B76 integration.
- C5 membership: join the baseline's `c5_concept_order_v1` keys to snapshot world, task and aliases from `act0_c5_concepts_v1.json` minus `act0_c5_exceptions_v1.json`. This deliberately does not regenerate or emulate the exact Dart guard (`act0_error_atlas_v1.dart`, `act0_catalog_concept_order_v1.dart`); export joins teaching title/body and feedback title/reason. All 238 W5–W12 keys have a matching surface. Classify by known teaching anchors, alias collisions, and whether the choice requires understanding the term. **FP-guard** = explanation precedes the choice, including same-task teaching, or lexical false match; **SELF-SUPPLIED** = local example/ordinary wording or nonessential contextual use; **REAL-EARLY** = label needed to understand a decision with no clear pre-choice gloss (and related earlier feedback use). These are audit judgments, not authorization to whitelist keys.
- Feedback: inspect every noncorrect (`-`, including suboptimal) option, flag empty rendered text, identical normalized full text or first-sentence-stripped text across options in a task, generic failure-only cues, and a conservative short-body probe (≤13 whitespace words after first sentence). Drop only the reviewed exact short text with an actual reason. The one retained generic case restates the expected property without naming the blocking mechanism. The joined title/reason export cannot independently prove an empty underlying reason, and the heuristic cannot certify that every longer sentence is useful.
- Missing prerequisite: walk W1–W12 in snapshot order; record concept mentions in TEACH, CAPTION, and only visible HINT (`always`, or `theoryOnly` in theory), including current-task pre-choice teaching. Probe Q and all options against the active C5 patterns when no such mention has occurred. Do not count a prior choice/feedback, task title, summary, repair-only row, or machine board facts as teaching. Check the raw hits for equivalent instruction and actual tested meaning; mere prior mention is not proof of explanation (C5 dispositions address that distinct risk). This is an atlas-vocabulary screen; not an inventory of unspecified/untagged poker concepts.

## Counts (literal script output)

| World | Rows | FP-guard | SELF-SUPPLIED | REAL-EARLY | REVIEW | Feedback tasks | Feedback dropped | Missing concepts | Alias hits dropped |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W5 | 42 | 45 | 4 | 0 | 0 | 0 | 8 | 0 | 3 |
| W6 | 43 | 23 | 1 | 0 | 0 | 0 | 7 | 0 | 1 |
| W7 | 15 | 2 | 0 | 0 | 0 | 1 | 3 | 0 | 0 |
| W8 | 41 | 35 | 13 | 4 | 0 | 0 | 1 | 0 | 1 |
| W9 | 32 | 36 | 13 | 2 | 0 | 0 | 1 | 0 | 4 |
| W10 | 33 | 16 | 4 | 0 | 0 | 0 | 3 | 0 | 0 |
| W11 | 39 | 16 | 5 | 0 | 0 | 0 | 2 | 0 | 1 |
| W12 | 38 | 8 | 11 | 0 | 0 | 0 | 1 | 0 | 0 |
| Total | 283 | 181 | 51 | 6 | 0 | 1 | 26 | 0 | 10 |
Course rows W1–W12: 498; C5 pairs W5–W12: 238.
Feedback candidates (options): 27; alias-absence candidates (task/concept): 10.
Noncorrect options inspected: 454; retained empty: 0; identical: 0; generic/short: 1.

Units: C5 = task × concept keys (numeric and descriptive IDs can describe the same term); feedback tasks = unique tasks with a retained candidate; feedback dropped = option hits; missing concepts = unique world × concept after semantic review; alias hits dropped = task × concept. 181 guard false hits and 51 self-supplied entries excluded from the repair queue, **not** removed from baseline. Of 27 feedback candidates, 26 false hits were dropped; of 10 literal missing-teaching candidates, 10 were dropped as missing *concepts*, including one real missing **label** already retained under C5. There are zero confirmed novel underlying tested concepts with no previous teaching surface under this scan, not a proof that every prior teaching surface is adequate.

## REAL gaps — smallest repairs (no grades, EV, answer IDs or route changes)

| World | Task ID | Term/issue | Smallest fix proposal |
| --- | --- | --- | --- |
| W7 | `paired_board_texture_lite_intro` | Incorrect “seven-containing combinations unchanged” gets general restatement, no why | Explain that the two visible sevens cannot belong to the opponent, so fewer seven-containing private-card combinations remain. Leave the separate “proves trips” feedback distinct. |
| W8 | `w7_low_spr_commit` | commitment in correct option; prior SPR teaching says less room but does not gloss “commit” | At `w7_spr_intro`, define in plain language: a large bet can use much of the remaining stack, leaving little for later bets; low SPR is not an automatic all-in. Or replace the option with that plain meaning. |
| W8 | `w7_high_spr_room` | “Immediate commitment” | Use “Putting most of the stack in now,” or reuse earlier gloss. |
| W8 | `w7_spr4_middle` | “Automatic commitment” / “some commitment” | Use “put the whole stack in now” / “some room, but larger bets use the stack quickly.” |
| W8 | `w7_top_pair_spr2_transfer` | “commitment pressure” in teaching and correct option | Say “the same bet uses more of the remaining stack; fewer chips stay for later decisions.” |
| W9 | `w9_survival_recap` | “skip sound steals” in suboptimal option before W10 explicitly teaches steals | “Skip good raises to win the blinds.” The earlier W9 example teaches the action, not the label. |
| W9 | `w9_checkpoint_table_notice` | “successful steals” in suboptimal feedback, before W10 gloss | “Times everyone folds to your raise.” Keep the existing equal-fold-rate comparison. |

The six C5 entries are two root vocabulary issues, not six independent missing poker concepts. W8 is a clarity gap even though an experienced reader can infer the meaning from the numeric examples; the independent choice should not depend on decoding jargon. W9's second occurrence is feedback-only, grouped with the earlier choice. The W7 feedback gap is a narrow explanation improvement, not a wrong answer, incorrect poker fact or newly missing concept. No confirmed empty/identical wrong feedback in the rendered snapshot.

## Spot checks (against complete task blocks, line numbers in frozen snapshot)

| Class | Samples (at least three where available) | Observed decision |
| --- | --- | --- |
| FP-guard | `flush_draws_w5_flush_intro` L3828; `w6_ak_combos` L4558 with `w6_combo_counts_intro` L4547; `w7_effective_stack_intro` L5188 | Four of a suit and nine possible cards explicitly taught; singular “A blocker is a known card…” precedes plural “blockers”; example explicitly gives 30 BB as smaller effective stack. No content gap. |
| SELF-SUPPLIED | `w7_fullring_tighter` L5710; `w9_survival_intro` L5808; `asm05_new_known_holes_turn_call_10` L7341 | UTG+1/LJ labels are not prerequisite: three additional seats and five-seat rule are given; ante first occurs in M formula but the question asks EV (ante defined before M-price task at L5894); no rake is an explicit model exclusion, not an assessed fee concept. |
| REAL-EARLY | `w7_low_spr_commit` L5455; `w7_high_spr_room` L5471; `w9_survival_recap` L5879 | Correct and wrong SPR options use unexplained commitment language; recap option uses “steals” before the first explicit glossary sentence in `w10_player_type_intro` L6220. Keep these; W8 first teaching L5306 and L5444 has shorter-stack/ratio mechanism but no plain commitment gloss. |
| Feedback | `paired_board_texture_lite_intro` L4980; `straight_draws_w5_gap_board` L3948; `outs_improvement_w5_flush_out` L4022; `w10_find_turn_raiser` L6531 | All 27 candidates reviewed from script. Keep W7 generic “change which combinations remain”; drop the latter three (rank gaps prevent a straight, wrong suit cannot make hearts, CO bet and BB raised). Only one actual defect, zero empty/duplicate hits, so cannot spot-check three positives per subtype. |
| No earlier teaching | `straight_draws_w5_straight_draw_find` after L3921; `w6_ak_combos` after L4547; `w11_multiway_dirty_outs` L7043 after L6564 | Open-ended draw can finish either end, singular blocker removes combinations, singular clean out makes you win; all three exact-alias hits are false missing-concept hits. No retained missing-concept positives to sample. |

Additional FP anchor groups used in classification: W1 `positions_theory` (HJ/BTN expanded), forced-post, action and hand-ranking lessons; W2 chart/hand discipline; W2–W3 acting after the opponent and seat order; W4 purpose/price; W5 texture, paired-board, flush, backdoor, straight-draw intros; W6 range/combination/continuation-bet and fold-equity intros; W8 smaller effective stack, depth, SPR and table-format examples; W9 ante, EV, risk-premium and bubble intros; W10 player types, isolation and bluff-catcher; W11 trigger routine; W10 clean-out example before W11. Broad collisions include “balances growth”/“new balance” (GTO), “frequency per combo” (mixed strategy), literal 200 BB (deep stack), and “pushes commitment”/“push out” (push/fold). These are not demands for advanced strategy lessons.

### All 10 raw missing-teaching candidates, reconciled

| World | Task/term | Why dropped |
| --- | --- | --- |
| W5 | `straight_draws_w5_straight_draw_find`, `straight_draws_w5_gutshot_draw`, `straight_draws_w5_gutshot_contrast_transfer` · 119 (3 keys) | L3921 says “open-ended draw” with both end ranks; owner alias is “open-ended straight draw”. |
| W6 | `w6_ak_combos` · 528 | L4547 teaches singular blocker before the question. |
| W8 | `w7_high_spr_room` · 312 | L5444 introduces stack-to-pot ratio, remaining room, and the high/low contrast; question's “high SPR” phrase is not a separate untaught concept. |
| W9 | `w9_survival_recap` · steal | L5854 teaches first-in all-in to win blinds. The English label is not taught until L6220; **retain C5 wording issue**, not a missing mechanism. |
| W9 | `w9_survival_recap` · gto | “Balances growth and survival” is ordinary prose, not balanced strategy/GTO. |
| W9 | `w9_m_ratio_recap` · mtt | L5808 explains elimination and chips vs prizes; subsequent payout example applies it. |
| W9 | `w9_bubble_recap` · 296 | Stack amounts and comparing the smaller stack taught at L5188, not a novel “stack size” skill. |
| W11 | `w11_multiway_dirty_outs` · 131 | L4071 teaches safer/riskier outs, L6564 says “A clean out makes you win.” |

## Ready-to-brief package split

One content writer at a time, after B76 merge and a rerun of this audit. Each row is at most one [C] PR; limits are budgets for changed test cases, not permission to weaken assertions. Re-use existing tests and change exact copy expectations only where the contract intentionally changes. Run the full required guards in CI; do not rebuild current audit or redo C5 Foundation.

| Package | Allowlisted lesson/task scope | Acceptance / test-change budget |
| --- | --- | --- |
| [C] B77-W7-FEEDBACK | `paired_board_texture_lite_intro` incorrect unchanged-combos feedback only | 1 option-specific feedback check; preserve paired-board task/grades; existing curriculum integrity, E09/21/49 and catalog truth/snapshot; ≤ 5 changed test cases. |
| [C] B77-W8-COMMITMENT | `w7_spr_intro` teaching (if gloss selected) and four W8 listed tasks; no stack/chart/size math changes | Up to 5 targeted pre-choice/copy checks, preserve assessment choice IDs/qualities and repair identity. Existing curriculum integrity, assessment identity, W4–W7 owner-contract, daily practice, C5 and truth guards; ≤ 12 changed test cases. |
| [C] B77-W9-STEAL | `w9_survival_recap`, `w9_checkpoint_table_notice` option/feedback words only | Up to 2 focused copy checks, retain all EV/payout/fold-model inputs and grades; source-scope/census and C5/truth guards; ≤ 6 changed test cases. |

For each: normal authoring source only, regenerate goal fingerprints (`tools/update_repair_goal_fingerprints_v1.py`) and reviewer snapshot per `act0_catalog_truth_guards_v1_test.dart`; review precise C5 delta rather than add exceptions, run targeted tests and Tier A/CI as appropriate. Keep app entry, routes, saved progress, Modern Table, telemetry and grades unchanged. Stop if the case cap would be exceeded and rebrief narrower work. Remaining FP-guard and SELF-SUPPLIED entries are audit dispositions only: after B76, lead can assess remaining guard precision separately, not remove baseline entries to make a green metric. Human clarity remains unverified.

## Reproduction and complete C5 key listing

Run `python3 -I tools/audit_w5w12_gaps_v1.py` for the table and `--details` for each C5 group, all raw feedback candidates (KEEP/DROP plus selected option and text), and alias-absence candidates with anchor. Semantic dispositions are explicit reviewed heuristics, not a general-purpose NLP classifier. Re-evaluate on a changed catalog/route; new candidates not recognized by the reviewed rules remain visible. No Flutter/native tests were run (spec-only audit); deterministic snapshot data only.

Each listing below uses the actual snapshot world, not the historical prefix in the task ID. Within each group, a task followed by its C5 concept IDs represents one original baseline key per concept. `Wn|task|concept` is recoverable exactly.

### W5 FP-guard

- `board_texture_basics_w5_dry_board` — `97`, `board_texture`
- `board_texture_basics_w5_texture_dry_value` — `check`
- `board_texture_basics_w5_texture_intro` — `97`, `98`, `board_texture`
- `board_texture_basics_w5_texture_recap` — `board_texture`
- `board_texture_basics_w5_texture_wet_showdown` — `43`, `check`, `two_pair`
- `board_texture_basics_w5_wet_board` — `board_texture`
- `connected_boards_w5_connected_board` — `93`, `paired_board`
- `connected_boards_w5_connected_intro` — `93`, `paired_board`
- `connected_boards_w5_connected_recap` — `connected_board`
- `flush_draws_w5_flush_draw_find` — `121`, `flush_draw`
- `flush_draws_w5_flush_draw_recheck_transfer` — `121`, `flush_draw`
- `flush_draws_w5_flush_intro` — `121`, `backdoor`, `flush_draw`
- `flush_draws_w5_flush_recap` — `flush_draw`
- `flush_draws_w5_made_hand_vs_flush_draw_transfer` — `121`, `flush_draw`
- `flush_draws_w5_no_flush_draw` — `121`, `backdoor`, `flush_draw`
- `straight_draws_w5_gutshot_contrast_transfer` — `118`, `119`, `gutshot`, `oesd`
- `straight_draws_w5_gutshot_draw` — `118`, `119`, `gutshot`, `oesd`
- `straight_draws_w5_straight_draw_find` — `119`, `121`, `flush_draw`, `gutshot`, `oesd`
- `straight_draws_w5_straight_intro` — `118`, `gutshot`, `oesd`

### W5 SELF-SUPPLIED

- `board_texture_basics_w5_texture_dry_value` — `570`
- `outs_improvement_w5_outs_intro` — `one_in_n`
- `straight_draws_w5_gutshot_contrast_transfer` — `outs`
- `straight_draws_w5_straight_intro` — `outs`

### W6 FP-guard

- `range_checkpoint_review` — `141`, `action_order`
- `w6_ak_combos` — `528`
- `w6_board_fit_intro` — `board_texture`
- `w6_board_fit_recap` — `141`, `169`
- `w6_board_pair_strength_compare` — `141`
- `w6_checkpoint_table_combo_weight` — `528`, `mixed_strategy`
- `w6_combo_weight_compare` — `169`, `528`
- `w6_continuation_bet_intro` — `427`, `cbet`
- `w6_kicker_showdown_compare` — `169`
- `w6_pair_vs_suited_weight_compare` — `528`
- `w6_pressure_lines_intro` — `359`, `fold_equity`
- `w6_range_intro` — `495`, `range`
- `w6_suited_offsuit_weight_compare` — `528`
- `w6_turn_shift_bucket` — `141`, `393`
- `w6_value_wet_board` — `141`

### W6 SELF-SUPPLIED

- `w6_value_dry_board` — `440`

### W7 FP-guard

- `paired_board_texture_lite_intro` — `93`, `paired_board`

### W8 FP-guard

- `w7_6max_wider` — `full_ring_6max`
- `w7_ajs_btn_25bb_transfer` — `297`, `effective_stack`
- `w7_depth_shift_intro` — `300`, `short_stack`
- `w7_effective_stack_100bb` — `297`, `deep_stack`, `effective_stack`
- `w7_effective_stack_30bb` — `297`, `deep_stack`, `effective_stack`
- `w7_effective_stack_intro` — `297`, `deep_stack`, `effective_stack`
- `w7_effective_stack_recap` — `297`, `effective_stack`
- `w7_format_intro` — `full_ring_6max`
- `w7_format_recap` — `full_ring_6max`
- `w7_high_spr_room` — `312`
- `w7_low_spr_commit` — `297`, `effective_stack`
- `w7_spr_intro` — `297`, `309`, `effective_stack`, `spr`
- `w7_spr_recap` — `push_fold`
- `w7_stack_checkpoint` — `297`, `effective_stack`
- `w7_table_effective_notice` — `297`, `effective_stack`
- `w7_top_pair_spr2_transfer` — `push_fold`
- `w8_effective_stack_seat` — `14`
- `w8_hero_stack_cap_seat` — `139`, `14`
- `w8_pot_bet_committed_seat` — `14`

### W8 SELF-SUPPLIED

- `w7_6max_wider` — `152`
- `w7_depth_shift_intro` — `commitment`, `deep_stack`
- `w7_format_intro` — `137`, `138`
- `w7_format_recap` — `137`, `138`
- `w7_fullring_tighter` — `137`, `138`
- `w7_low_spr_commit` — `569`
- `w7_spr_recap` — `commitment`
- `w7_stack_checkpoint` — `mtt`
- `w7_top_pair_spr8_transfer` — `commitment`

### W8 REAL-EARLY

- `w7_high_spr_room` — `commitment`
- `w7_low_spr_commit` — `commitment`
- `w7_spr4_middle` — `commitment`
- `w7_top_pair_spr2_transfer` — `commitment`

### W9 FP-guard

- `w9_bubble_intro` — `388`, `848`, `889`, `bubble`, `icm`
- `w9_bubble_recap` — `889`, `bubble`
- `w9_bubble_short_stack` — `139`
- `w9_cash_vs_tournament` — `141`
- `w9_checkpoint_survival_line` — `359`, `fold_equity`
- `w9_checkpoint_table_notice` — `139`
- `w9_checkpoint_zone_line` — `842`
- `w9_ev_two_results` — `385`, `845`
- `w9_m_ratio_ante_cost` — `842`
- `w9_m_ratio_green_zone` — `139`, `842`
- `w9_m_ratio_intro` — `842`, `ante`
- `w9_m_ratio_lap_count` — `14`, `842`
- `w9_m_ratio_recap` — `147`, `ip_oop`
- `w9_m_ratio_red_zone_shove` — `141`, `842`
- `w9_m_ratio_table_window_transfer` — `842`
- `w9_m_ratio_yellow_zone` — `139`, `141`, `842`, `starting_chart`
- `w9_medium_stack_tighten` — `141`
- `w9_short_stack_survival` — `14`
- `w9_survival_intro` — `385`, `845`
- `w9_survival_recap` — `gto`

### W9 SELF-SUPPLIED

- `w9_big_stack_leverage` — `156`
- `w9_bubble_recap` — `296`
- `w9_cash_vs_tournament` — `winrate`
- `w9_m_ratio_recap` — `commitment`, `mtt`
- `w9_m_ratio_red_zone_shove` — `push_fold`
- `w9_m_ratio_yellow_zone` — `152`
- `w9_prize_model_inputs` — `winrate`
- `w9_survival_intro` — `842`, `ante`
- `w9_survival_recap` — `889`, `bubble`
- `w9_survival_stack_tradeoff` — `mtt`

### W9 REAL-EARLY

- `w9_checkpoint_table_notice` — `steal`
- `w9_survival_recap` — `steal`

### W10 FP-guard

- `w10_checkpoint_guardrail_line` — `139`
- `w10_checkpoint_tag_line` — `139`
- `w10_find_limper` — `139`
- `w10_guardrail_sample_size` — `139`
- `w10_guardrails_intro` — `bluff_catcher`
- `w10_loose_passive_tag` — `139`, `192`, `isolation`
- `w10_nit_tag` — `139`, `starting_chart`
- `w10_player_type_intro` — `687`, `691`, `692`, `player_types`
- `w10_player_type_recap` — `692`
- `w10_top_pair_turn_raise` — `687`

### W10 SELF-SUPPLIED

- `w10_checkpoint_tag_line` — `440`
- `w10_one_lever_recap` — `569`
- `w10_overaggressive_tag` — `84`
- `w10_river_price_check` — `one_in_n`

### W11 FP-guard

- `w11_bankroll_move_down` — `gto`
- `w11_bb_defend_price` — `842`
- `w11_checkpoint_plan_line` — `148`, `ip_oop`
- `w11_checkpoint_trigger_line` — `push_fold`
- `w11_first_in_seat` — `139`
- `w11_multiway_dirty_outs` — `131`
- `w11_multiway_first_seat` — `action_order`
- `w11_sb_3bet_value` — `148`, `ip_oop`
- `w11_sb_isolate_limp` — `multiway`
- `w11_session_plan_intro` — `842`
- `w11_trigger_intro` — `multiway`
- `w11_trigger_overcall_flop` — `multiway`
- `w11_trigger_recap` — `multiway`
- `w11_trigger_small_price_continue` — `multiway`

### W11 SELF-SUPPLIED

- `w11_review_define_fix` — `winrate`
- `w11_session_plan_intro` — `26`, `rake`
- `w11_trigger_bad_price_fold` — `one_in_n`
- `w11_trigger_overcall_flop` — `569`

### W12 FP-guard

- `w12_after_mistake_reset` — `starting_chart`
- `w12_assertive_not_ego` — `starting_chart`
- `w12_bad_call_good_result` — `131`
- `w12_confidence_intro` — `bluff_catcher`
- `w12_decision_quality_intro` — `131`
- `w12_river_price_call` — `131`, `bluff_catcher`
- `w12_tilt_reset_intro` — `334`

### W12 SELF-SUPPLIED

- `asm05_new_known_holes_turn_call_10` — `26`, `rake`
- `asm05_new_known_holes_turn_call_40` — `26`, `rake`
- `w12_bad_call_good_result` — `26`, `push_fold`, `rake`
- `w12_clean_outs_vs_set` — `26`, `rake`
- `w12_confidence_recap` — `table_talk`
- `w12_decision_quality_intro` — `winrate`

