What it is
SB/BB defense playbook versus BTN/CO steals. You act OOP most of the time. Use fixed ladders (3bet_oop_12bb primary; 3bet_ip_9bb, 4bet_ip_21bb, 4bet_oop_24bb when applicable) and the 33/50/75 families. Only [[term:FREQUENCY]] shifts. Every decision maps to one token.

Why it matters
BTN/CO apply price and position. OOP your realization drops and raise risk rises. [[term:EV]] comes from correct family by texture, protected checks that [[term:DENY_EQUITY]] auto-stabs, [[term:BLOCKERS]]-gated turn pressure, and strict river discipline versus polar sizing. Fixed 33/50/75 lines make plans repeatable.

Rules of thumb
- Preflop: default 3bet_oop_12bb vs steals; widen only with [[term:BLOCKERS]] and persistence ([[term:OVERFOLD]]_[[term:EXPLOIT]]).
- Family by texture: static -> size_down_dry then small_cbet_33 at controlled [[term:FREQUENCY]]; dynamic -> size_up_wet and half_pot_50 default.
- Protect early at mid [[term:SPR]]: use protect_check_range on stabby textures and prefer delay_turn versus raise-prone IP with medium strength.
- Turn upgrade: escalate to big_bet_75 only with top [[term:BLOCKERS]] and documented Fv75 up; otherwise keep half_pot_50 or delay_turn.
- River discipline: facing polar big_bet_75 without [[term:BLOCKERS]] -> fold; with scare plus top [[term:BLOCKERS]] and a plan -> triple_barrel_scare as PFA or call.

Mini example
Line 1: UTG folds, MP folds, CO opens 2.5bb, BTN folds, SB 3bet_oop_12bb, BB folds. Flop K72r (static) -> size_down_dry + small_cbet_33; turn vs raise-prone IP -> delay_turn; river facing polar 75 without blockers -> fold.
Line 2: UTG folds, MP folds, CO min-raises, BTN calls, BB defends. Flop Q84r checks through. Sequence: chk-chk -> probe_turns on good turn; if turn stays dynamic and you hold key blockers with Fv75 up -> big_bet_75 as double_barrel_good.
Line 3: BTN steals, SB 3bet_oop_12bb, BTN calls, BB out. Flop JT9ss -> size_up_wet with half_pot_50; upgrade only when blockers plus Fv75 justify it; river vs polar 75 without blockers -> fold.

Common mistakes
- Auto 33 on wet boards. Gives cheap cards and invites raises.
- Upgrading to 75 without blockers or Fv75 evidence. Overbluffs into sticky ranges.
- Probing without chk-chk. Stabs into uncapped IP and gets raised.

Mini-glossary
protect_check_range: checks that can continue; reduces auto-stabs and keeps range uncapped.
Blocker gates: require top blockers before big_bet_75 or thin river calls.
Fv50/Fv75: fold vs 50%/75%; log before upgrades or calls.
Commitment gate: if a 75% turn leaves a trivial river, require equity/blockers or stay at 50% or delay_turn.
[[term:EV]]: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
IP 3-bet playbook presses more; here OOP we protect earlier, delay more, and upgrade only through blocker and evidence gates with the same tokens.


See also
- donk_bets_and_leads (score 29) -> ../../donk_bets_and_leads/v1/theory.md
- live_chip_handling_and_bet_declares (score 29) -> ../../live_chip_handling_and_bet_declares/v1/theory.md
- cash_3bet_oop_playbook (score 27) -> ../../cash_3bet_oop_playbook/v1/theory.md
- cash_limp_pots_systems (score 27) -> ../../cash_limp_pots_systems/v1/theory.md
- cash_population_exploits (score 27) -> ../../cash_population_exploits/v1/theory.md
