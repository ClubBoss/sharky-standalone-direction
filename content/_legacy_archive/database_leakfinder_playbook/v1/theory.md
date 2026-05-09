What it is
A practical leakfinding workflow that turns database/HUD aggregates into tokenized actions using fixed ladders and size families. You read population and opponent stats (e.g., Fold vs 3Bet, 4Bet, cbet-by-size, Fold vs Turn 75%, Fold vs Probe, x/r, AFq, WTSD, WSD, WWSF), validate with a single variable lock sweep when needed, and then shift frequencies with one action token. Sizes never change: preflop ladders are 3bet_ip_9bb / 3bet_oop_12bb / 4bet_ip_21bb / 4bet_oop_24bb.

Why it matters
Population level leaks move EV/hour more than micro mix tweaks. Overfolds to 3 bets, under 4 bets, turn Fv75 spikes on dynamic cards, surrender after check check, and under bluffed polar rivers are repeatable edges. Converting those patterns into the token set keeps execution simple and fast at scale.

Rules of thumb

* Sample tiers: weak (<=500 spots), medium (~500-1k), strong (>=1k+).
* Fold vs 3Bet up + 4Bet down: widen 3bet_oop_12bb / 3bet_ip_9bb with blockers; upgrade premiums to 4bet_ip_21bb. Why: pressure prints when 5 bets are rare.
* Under 4 bet fields OOP/IP: add thin value 3 bets; choose 4bet_ip_21bb or 4bet_oop_24bb with premiums. Why: reverse SPR cleanly.
* Turn Fv75 high on dynamic boards: double_barrel_good; use big_bet_75 with blockers, default half_pot_50 otherwise. Why: exploit fold vs size split.
* Fold vs Probe up after chk chk: probe_turns. Why: opponents surrender at high SPR after missing flop stab.
* Flop x/r low on static: size_down_dry and small_cbet_33 at higher frequency. Why: range bet is safe when raise risk is low.
* River polar under bluffed: fold vs big_bet_75 without blockers; with top blockers as PFA consider triple_barrel_scare. Why: respect population under bluff.
* Stations (WTSD up, WSD down): prefer merged value with half_pot_50; on static rivers pick size_down_dry thin value. Why: they call too much, size accordingly.
* Raise prone turns at mid SPR: delay_turn and keep protect_check_range. Why: avoid getting blown off equity.
* RFI wide + BB defend tight: expand 3bet_oop_12bb. Why: preflop price pressure prints immediate folds.
* Physics first: texture picks family (size_down_dry static; size_up_wet dynamic); stats only shift frequency inside the family. Why: keep the tree stable.
* Lock sweeps: change one knob (e.g., Fv75) to confirm persistence; adopt only if EV gain holds, then tag overfold_exploit. Why: prevent overfitting.

Mini example
Profile: Fold vs 3Bet 60, 4Bet 2-3, Turn Fv75 on wet 58, Fold vs Probe 57, x/r 5, River AFq 15.

Common mistakes
Overfitting tiny samples. Chasing off tree sizes. Ignoring texture when choosing family. Reading heatmaps without EV validation. Tagging overfold_exploit after one orbit. Skipping blocker checks on rivers.

Mini-glossary
VPIP/PFR/RFI: preflop participation and open ranges.
Fold vs 3Bet: higher means widen 3 bets.
4Bet: low frequencies justify value heavy 3 bets and 4bet_ip_21bb / 4bet_oop_24bb.
cbet by size: how often opponents continue vs 33/50/75; informs small_cbet_33 or bigger turns.
Fold vs Probe: high after chk chk -> probe_turns.
x/r: low on static -> small_cbet_33.
AFq/WTSD/WSD/WWSF: aggression and showdown mix.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times.
