What it is
Isolation raises target one or more limpers so you play heads up with the betting probe_turns. You decide between iso, overlimp, or fold based on position, number of limpers, and limp-raise risk. Size ladders scale with limpers and position so you avoid multiway and land on clean [[term:SPR]]s for value capture and simple turn trees (typical online).


Why it matters
Limpers hide weak ranges and realize [[term:EQUITY]] cheaply if you allow multiway. Right iso sizes reclaim fold [[term:EQUITY]], isolate the weakest opponent, and build pots where top pair and small c-bets perform well. Wrong sizes invite multiway, bloat OOP pots, and increase reverse [[term:IMPLIED_ODDS]] risk.

Rules of thumb
- IP sizing: vs 1 limper use iso_raise_ip_6bb (about 5-6bb). Add +1bb per extra limper. Size up in sticky pools/deep; size down slightly at 40-60bb to keep turn jam trees clean.
- OOP sizing: from blinds vs 1 limper use iso_raise_oop_8bb (about 7-9bb). Add +1-2bb per extra limper. Keep ranges more value heavy and linear.
- Range shapes: linear in soft fields (broadways, pairs, suited Ax/Kx). Add [[term:BLOCKERS]] bluffs more IP than OOP; trim dominated offsuit broadways.
- Overlimp policy: overlimp_ok IP with suited connectors/gappers and small pairs when limp-raise risk is low and there are 2+ limpers. Rarely overlimp OOP.
- Vs limp-raise: treat it as strong; fold_vs_limp_raise most mediums. Continue with clear value; occasional [[term:BLOCKERS]] 4-bet IP when deep.

Postflop after iso
IP: small_cbet_33 on Axx/Kxx dry; half_pot_50 on middling J-9 high; size_up_wet only with strong [[term:EQUITY]]/backdoors. Use delay_cbet_ip when the board hits the limper. OOP protect_check_range, defend tighter vs raises, and pick clear value or give_up_low_[[term:EQUITY]]. Turns: deny_equity_turn on scare cards. Rivers: [[term:POLARIZATION]]_river when ranges cap and draws miss; value_thin_ip after checks when kicker advantage is clear.

Mini example
CO limps. BTN isolates to 6bb (iso_raise_ip_6bb). Blinds fold; CO calls. Pot ~13.5bb; [[term:SPR]] ~7. Flop K72r: BTN small_cbet_33 ~4.5bb; CO calls. Turn 5x: BTN half_pot_50 ~11bb to deny_equity_turn versus A5/86; CO folds. On QJ9ss instead, BTN often protects with checks and delays c-bet on improving turns.

Common mistakes
- Using open sizes instead of iso sizes (invites multiway, loses fold equity).
- Overlimping OOP with offsuit broadways (poor realization, kicker traps).
- Calling limp-raises too wide (value-heavy ranges crush mediums).

Mini-glossary
iso_raise_ip_6bb: IP isolation raise vs 1 limper; add +1bb per extra limper.
iso_raise_oop_8bb: OOP iso vs 1 limper; add +1-2bb per extra limper.
overlimp_ok: Select overlimp when realization is high and limp-raise risk is low.
fold_vs_limp_raise: Tight response to limp-raise pressure; continue mainly with value.
[[term:EV]]: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
Unlike blind-vs-blind, iso pots target one capped limp-call range and aim to avoid multiway, so sizes push more folds and set heads-up [[term:SPR]]s that reward top pair and initiative.

_This module uses the fixed families and sizes: size_down_dry, size_up_wet; small_cbet_33, half_pot_50, big_bet_75._

See also
- cash_population_exploits (score 21) -> ../../cash_population_exploits/v1/theory.md
- cash_short_handed (score 21) -> ../../cash_short_handed/v1/theory.md
- hand_review_and_annotation_standards (score 21) -> ../../hand_review_and_annotation_standards/v1/theory.md
- icm_mid_ladder_decisions (score 21) -> ../../icm_mid_ladder_decisions/v1/theory.md
- mtt_pko_strategy (score 21) -> ../../mtt_pko_strategy/v1/theory.md
