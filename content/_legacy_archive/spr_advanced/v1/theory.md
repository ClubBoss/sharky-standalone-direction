What it is
This module upgrades SPR (stack-to-pot ratio) from a definition to a planning tool. You will map preflop ladders to target SPR bands, let texture pick the size family, then choose lines inside that family using commitment thresholds and blockers. You keep exactly the same tokens and sizes used everywhere else: 3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb, small_cbet_33, half_pot_50, big_bet_75, plus the concepts size_down_dry / size_up_wet, protect_check_range, delay_turn, probe_turns, double_barrel_good, triple_barrel_scare, call, fold, overfold_exploit.

Why it matters
The same ladders (9/12/21/24) set predictable SPR bands that simplify decisions before cards arrive. Reverse SPR via 4-bets creates clean commitment points; mid-SPR highlights where to avoid raise wars; high SPR after chk-chk creates profitable probe windows. Using SPR to pre-plan lines lowers error rate more than tiny mix tweaks. The physics rule remains: texture selects the size family.

Rules of thumb

* Mid SPR OOP vs raise prone IP: increase delay_turn and keep protect_check_range.
* High SPR after check check: increase probe_turns on favorable turns. Why: many opponents surrender after missing the flop stab.
* Low SPR != auto call: fold vs polar big_bet_75 without blockers in under bluffed pools. Why: population effect beats price.
* Ladder -> plan mapping: 3bet_oop_12bb and 3bet_ip_9bb lower SPR so that top pairs and initiative gain. On static boards prefer size_down_dry with small_cbet_33; on dynamic boards start half_pot_50 and double_barrel_good only with equity/blockers. Why: initiative plus lower SPR improves conversion.
* BvB transfer: blind defend trees shift SPR fast; flop probe_turns/turn probe_turns intersections exist, but sizes remain 33/50/75. Why: initiative may flip while families stay identical.
* Exploit gates: tag overfold_exploit only with persistent evidence; SPR never justifies off tree plays. Why: discipline controls variance and bias.

Mini example
HU 100bb. SB opens 2.0bb, BB 3bet_oop_12bb (lower SPR). Flop A83r (static): choose size_down_dry with small_cbet_33.

Second line: BTN faces CO 3 bet.

River discipline: facing polar big_bet_75 on a scare card without blockers -> fold.

Common mistakes

* Treating low SPR as auto stack with any pair. Fix: fold rivers vs polar big_bet_75 without blockers in under bluffed pools.
* Engineering off tree sizes to force shoves. Fix: plan within 33/50/75; commit via big_bet_75 only when it leaves trivial behind and blockers support it.
* Over bluffing static high SPR rivers. Fix: prefer size_down_dry thin value earlier, and call/fold discipline on river.
* Calling too wide OOP at mid SPR. Fix: prefer delay_turn and protect_check_range over marginal continues.
* Ignoring probe equity at high SPR after check check. Fix: add probe_turns on favorable cards.
* Confusing texture with SPR. Fix: physics first (family by texture), then SPR adjusts frequency/line choice.

Mini-glossary
SPR: stack to pot ratio at street start guiding leverage and commitment.
Reverse SPR: setting a low, clean SPR via 4 bets for simpler decisions.
Commitment threshold: point where turn sizing makes river shove trivial.
Leverage: pressure relative to stacks created by your bet size.
Realization: how efficiently equity converts to EV given position and SPR.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times.
