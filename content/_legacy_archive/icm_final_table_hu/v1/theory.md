What it is
A heads-up final table (HU FT) playbook that standardizes preflop ladders and turn/river decisions with the exact fixed actions used everywhere else. Preflop: 3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb. Postflop families: size_down_dry (static) and size_up_wet (dynamic) with sizes small_cbet_33, half_pot_50, big_bet_75. Every node resolves to one token only: protect_check_range, delay_turn, probe_turns, double_barrel_good, triple_barrel_scare, call, fold, or overfold_exploit. No new sizes or trees are introduced-ICM only shifts frequencies.

Why it matters
With only two payouts left, chips convert to finish equity nonlinearly. Errors in big, polar nodes are amplified; thin hero calls and ungated 75% barrels leak more than usual. SB (dealer) has position and opens frequently; BB realizes worse and faces raise risk. Keeping physics-first family selection (dry->33%, wet->50% default) and enforcing blocker/evidence gates makes your HU FT execution stable and repeatable under pressure.

Rules of thumb

- Commitment gate. If a turn 75% creates a trivial river shove, require equity+blockers beforehand; otherwise stay half_pot_50 or delay_turn.
- Preflop ladder stays fixed. Use 3bet_oop_12bb vs frequent steals; widen only with blockers after persistence. Use 4bet_ip_21bb / 4bet_oop_24bb for clear value.
- Stack bands guide frequencies. 10-20bb: bias to delay_turn and river discipline. 20-40bb: default patterns; upgrade 50->75 only with blockers+Fv75. 40bb+: protect check-backs and plan turn->river earlier.
- IP plan on dynamic turns. With top blockers and Fv75, double_barrel_good using big_bet_75; without evidence, remain half_pot_50.
- OOP vs polar rivers. Facing big_bet_75 without blockers -> fold. With premium blockers, consider call; as PFA with scare+blockers, triple_barrel_scare.
- Protect your check backs IP. On static boards, include protect_check_range to prevent OOP auto stabs.
- Delay vs raise prone BB lines. When BB raises turns often, prefer delay_turn with medium strength and capture value later.
- Overfold exploit gate. Only widen preflop pressure after medium+ repetition of fast folds.
- Plan turn->river. If turn 75% would leave <1 SPR on many rivers, ensure blockers/equity justify commitment; otherwise stay at 50% or delay.

Mini example
- BB OOP, dry: SB opens; BB 3bet_oop_12bb. Flop A83r -> size_down_dry + small_cbet_33; turn 2 vs raise prone IP -> delay_turn; river facing polar big_bet_75 without blockers -> fold.
- SB IP, wet: BB calls pre. Flop T98ss -> size_up_wet + half_pot_50; turn Q with A blocker and logged Fv75 -> big_bet_75 as double_barrel_good; river K scare per plan -> triple_barrel_scare.

Common mistakes
- Ungated big_bet_75. Upgrading without blockers or Fv75 evidence overbluffs into sticky ranges; ICM magnifies losses.
- Probing without chk chk. Probes into uncapped ranges get raised; initiative must be earned.
- Calling polar 75% rivers without blockers. Under bluffed nodes punish curiosity; fold by default.
- "Exploit" tags on one orbit. Overfold_exploit requires repetition; otherwise keep baseline frequencies.

Mini-glossary
Fv50/Fv75: Fold rates vs 50%/75% used to justify upgrades and thin calls. 
protect_check_range: Checks that can continue; deny auto stabs and keep range uncapped. 
delay_turn: Intentional pass at mid SPR vs raise prone lines to preserve equity. 
Commitment gate: If 75% on turn forces many river jams, demand equity/blockers or remain at 50%/delay.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times
