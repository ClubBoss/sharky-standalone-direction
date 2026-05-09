What it is
Straddles and bomb antes add dead money, rewire preflop position (UTG straddle), create limp-chains, and lower SPR. This module converts those quirks into frequency shifts using fixed ladders and 33/50/75 size families. Physics first: size_down_dry on static boards; size_up_wet on dynamic boards. Procedures change frequency, not sizes.

Why it matters
Dead money, positional rewiring, and more limps change incentives. Lower SPR clarifies commitment and makes thin flats worse OOP. Wins come from picking the correct family by texture, then shifting frequencies toward merged value, protection, river discipline, and evidence-gated preflop pressure - without inventing new lines.

Rules of thumb

* Dead money: selectively widen steals and 3-bets with blockers via 3bet_ip_9bb / 3bet_oop_12bb; tag overfold_exploit only after repeated folds. Why: better price but evidence needed.
* UTG straddle shift: EP tighter; upgrade premiums to 4bet_ip_21bb / 4bet_oop_24bb vs early opens. Why: value prints when 5-bets are rare.
* Limp-chains: prefer merged lines; half_pot_50 for value, thin value via size_down_dry; fewer pure bluffs; add protect_check_range. Why: low realization multiway.
* Lower SPR: on static flops choose small_cbet_33; on dynamic turns default half_pot_50; upgrade to big_bet_75 only with blockers + fold-to-75 evidence. Why: justify leverage.
* chk-chk frequency: when SRP checks through, use probe_turns on favorable turns. Why: surrender after passivity.
* Raise-prone turns: choose delay_turn at mid SPR; protect earlier. Why: avoid getting blown off equity.

 



Mini example
Single straddle on. SB opens light; BB with A5s notes repeated blind folds -> 3bet_oop_12bb (evidence-gated, overfold_exploit). Flop A83r heads-up: size_down_dry -> small_cbet_33. Turn 6c, room raises turns aggressively -> delay_turn. River faces big_bet_75 on a polar line without blockers -> fold.
Bomb ante with limp-chain: you isolate, flop T92r multiway -> half_pot_50 for merged value; turn checks through often in this pool -> probe_turns on the 6x.

Common mistakes
Off-tree size improvisation; over-bluffing into limp-chains; forgetting UTG straddle positional tightening; confusing probe_turns (after chk-chk) with turn probe_turns (after calling a c-bet); hero-calling polar big rivers without blockers; skipping protect_check_range in raise-happy rooms.

Mini-glossary
Straddle: live blind posted before cards, adds dead money and shifts position.
Bomb ante: large ante from all players each hand; increases dead money and lowers SPR.
Limp-chain: multiple limpers preflop, probe_turns to multiway pots.
Reverse SPR: lower SPR created via larger preflop ladders (e.g., 4bet_*), clarifying commitment.
Capped node: range lacking top value; prime for probe_turns.
Merged vs polar: medium-strength value vs nuts/air; map to half_pot_50 vs big_bet_75 respectively.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times
Contrast
Live_tells_and_dynamics focuses on reads; live_etiquette_and_procedures on process. Here we center on format economics and positional rewiring from straddles/bomb antes. Sizes remain 33/50/75; only frequencies move.

See also
- cash_short_handed (score 31) -> ../../cash_short_handed/v1/theory.md
- hand_review_and_annotation_standards (score 31) -> ../../hand_review_and_annotation_standards/v1/theory.md
- icm_final_table_hu (score 31) -> ../../icm_final_table_hu/v1/theory.md
- icm_mid_ladder_decisions (score 31) -> ../../icm_mid_ladder_decisions/v1/theory.md
- live_chip_handling_and_bet_declares (score 31) -> ../../live_chip_handling_and_bet_declares/v1/theory.md