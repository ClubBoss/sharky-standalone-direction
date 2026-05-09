What it is
How rake models (time vs drop), tipping, and game cadence translate into frequency shifts with the fixed tokens. Postflop sizes stay 33/50/75. Physics first: size_down_dry on static boards; size_up_wet on dynamic boards. Economics change frequencies, not sizes.

Why it matters
Drop/time and tips change the EV of small pots and thin edges. Drop punishes many small pots; time charge rewards volume. Tips tax each win. Keep sizes by texture; adjust bluff, defend, and press frequencies.

Rules of thumb





- Straddle/bomb_ante with drop: dead money improves steals but drop taxes small pots; selectively 3bet_ip_9bb / 3bet_oop_12bb with blockers; half_pot_50 for merged value.
- Multi-limpers in drop rooms: bluff EV falls; add protect_check_range; half_pot_50 for merged value; thin value via size_down_dry.
- Mid-SPR raise-prone turns: choose delay_turn with medium strength; protect_check_range prior.
- chk-chk SRPs: add probe_turns to capture forfeit equity.
- Under-bluffed polar rivers: default fold vs big_bet_75 without blockers; as PFA, reserve triple_barrel_scare on scare cards with strong blockers.
- Table selection: prefer soft/fast time games; avoid slow/nitty drop games. Tokens unchanged.
- Exploit gates: tag overfold_exploit only after repetition.

Live overlay integration
- rake_type(time): bias to small_cbet_33, half_pot_50, delay_turn; prioritize probe_turns to capture surrenders; reduce thin river calls. 
- rake_type(drop): fewer thin OOP calls; more 3bet_oop_12bb for value; default small_cbet_33 on static to keep control. 
- has_straddle / bomb_ante: widen selective 3bet_ip_9bb / 3bet_oop_12bb with blockers; merged postflop (half_pot_50). 
- avg_stack_bb low: lower SPR-prefer half_pot_50 over big_bet_75 unless blockers + fold-to-75 evidence. 
- table_speed high: standardize decisions-small_cbet_33, half_pot_50, protect_check_range; fewer triple_barrel_scare.



Mini example
- Drop room, heavy tips. CO opens, BB defends. Flop K72r (static): size_down_dry -> small_cbet_33. Turn 2x, villain sticky: half_pot_50 merged value with top pair; river big_bet_75 from tight reg and you lack blockers -> fold.
- Time game with single straddle. SB 2.0bb opens; BB sees repeated fast folds -> selectively 3bet_oop_12bb with A5s. Later SRP checks through on Q72r; next orbit add probe_turns on safe turns.

Common mistakes
Chasing promos with off-tree sizes; over-calling thin rivers despite tipping tax; confusing probe_turns (after chk-chk) with probe_turns; refusing to fold to big_bet_75 without blockers; tagging overfold_exploit after one hand; ignoring multiway drop effects and firing thin bluffs.

Mini-glossary
Drop: per-pot rake taken from the pot, usually stepped/capped. 
Time charge: fixed-per-time rake independent of pot size. 
Cap/step: structure of maximum rake and increments in drop. 
Promo drop: extra taken for jackpots/high hands. 
Tipping tax: expected tip per win, reducing value thresholds. 
Reverse SPR: lower SPR created by larger preflop aggression (via 3/4-bets). 
Under-bluffed river: live tendency to lack bluffs on large river bets. 
Merged vs polar: medium-strength value vs nutted/air distributions. 
Table speed: hands/hour affecting EV/hour and line selection. 
Dead money: extra chips from straddles/antes improving steal EV.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times
Contrast
online_economics_rakeback_promos targets site incentives; rake_and_ante_economics covers general economics. This module is live-room rake/time/tips specific. Sizes stay 33/50/75 and ladders 9/12/21/24; only frequencies move.

See also
- exploit_advanced (score 29) -> ../../exploit_advanced/v1/theory.md
- hand_review_and_annotation_standards (score 29) -> ../../hand_review_and_annotation_standards/v1/theory.md
- icm_final_table_hu (score 29) -> ../../icm_final_table_hu/v1/theory.md
- live_etiquette_and_procedures (score 29) -> ../../live_etiquette_and_procedures/v1/theory.md
- live_full_ring_adjustments (score 29) -> ../../live_full_ring_adjustments/v1/theory.md