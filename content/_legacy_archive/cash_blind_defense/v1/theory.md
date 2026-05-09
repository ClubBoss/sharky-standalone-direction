What it is
Blind defense is your plan from SB and BB versus opens from EP, MP, CO, and BTN, with BvB exceptions. You choose between call, 3-bet, or fold based on price, rake, and [[term:EQUITY_REALIZATION]]. BB gets best pot odds but worst position; SB pays more rake and realizes less, so prefers 3-bet-or-fold versus early seats.


Why it matters
Blinds face constant pressure. Calling badly out of position creates awkward [[term:SPR]]s and expensive turn/river guesses. Sound blind defense prints in micro, low, and mid pools because opens are frequent and folds compound. Correct sizes and tight postflop discipline prevent small [[term:LEAK]]s from snowballing.

Rules of thumb
- BB defense: call more versus CO/BTN due to price; 3-bet linear versus steals with high cards and [[term:BLOCKERS]]; 3-bet more polar versus EP/MP. Default size 3bet_oop_11bb; in BvB use 3bet_oop_10bb versus SB 2.5-3.0.
- SB defense: prefer 3-bet-or-fold versus EP/MP; allow selective flats versus CO/BTN when playability is high and rake does not punish. Keep 3bet_oop_11bb as baseline; standard 4-bet is 4bet_small_22bb.
- Squeeze: use squeeze_iso_3bet value-biased over open plus caller(s); avoid_bloated_pot_oop with weak offsuit broadways and dominated gappers.
- Postflop as caller OOP: protect_check_range often. Versus small_cbet_33 on dry Axx/Kxx, defend_vs_small_cbet with pairs, gutters plus overcards, and backdoor flush draws; mix check_raise_dry at some [[term:FREQUENCY]] where you have coverage. On T98/QJT, check_raise_wet only with strong [[term:EQUITY]]; otherwise call or give_up_low_[[term:EQUITY]].
- Turn/river: know MDF but prioritize [[term:EQUITY_REALIZATION]] and geometry. [[term:DENY_EQUITY]]_turn with check-raise or bet only when you add real [[term:EQUITY]]. [[term:OVERFOLD]] versus half_pot_50 and big_bet_75 when ranges are tight and you are capped. [[term:PROBE]]_turns selectively after flop checks through on scare cards. [[term:POLARIZATION]]_river sparingly; call_down_top_pair mainly when ranges are capped and sizings are small.

Mini example
UTG opens 2.3bb, MP folds, CO folds, BTN folds. SB 3-bets to 11bb, BB folds, UTG calls. Flop A72r: SB small_cbet_33; UTG calls. Turn 5x: SB half_pot_50 to deny_equity_turn versus wheel gutters and overcards; UTG folds. Contrast: CO opens 2.3bb, BTN folds, SB folds, BB calls; flop T98ss, CO big_bet_75, BB continues only with pair plus draw or strong OESD and avoid_bloated_pot_oop raises.

Common mistakes
squeeze_iso_3bet: Value-biased 3-bet over open plus caller(s) using blockers and playability. 
deny_equity_turn / polarize_river: Bet or raise to fold live equity on turns; use large river sizes with value and bluffs when ranges cap.
Mini-glossary
defend_vs_small_cbet: Continue versus ~33 percent bets with pairs, gutters plus overs, or BDFDs.
protect_check_range: Structured checks that keep medium hands and avoid face-up lines.
[[term:EV]]: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
Blind defense is not BTN defense: OOP realization and rake make flats worse and 3-bet selection tighter. It also differs from BvB, where 3bet_oop_10bb is common and both ranges are wider.

_This module uses the fixed families and sizes: size_down_dry, size_up_wet; small_cbet_33, half_pot_50, big_bet_75._

See also
- cash_blind_defense_vs_btn_co (score 17) -> ../../cash_blind_defense_vs_btn_co/v1/theory.md
- cash_multiway_3bet_pots (score 17) -> ../../cash_multiway_3bet_pots/v1/theory.md
- cash_multiway_pots (score 17) -> ../../cash_multiway_pots/v1/theory.md
- cash_population_exploits (score 17) -> ../../cash_population_exploits/v1/theory.md
- donk_bets_and_leads (score 17) -> ../../donk_bets_and_leads/v1/theory.md
