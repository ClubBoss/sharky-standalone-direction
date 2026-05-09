What it is
Overbets are large [[term:POLARIZATION]] bets on turns or rivers used when your range holds nut advantage or strong [[term:BLOCKERS]]. [[term:BLOCKERS]] bets are [[term:THIN_VALUE]] or set-price bets on static nodes where both ranges are condensed. In practice we map these ideas to size families: big_bet_75 as the [[term:POLARIZATION]] lever, size_down_dry as the [[term:BLOCKERS]]/[[term:THIN_VALUE]] lever, and half_pot_50 as the default when neither extreme fits. small_cbet_33 remains a flop baseline on dry boards.


Why it matters
Sizing drives fold [[term:EQUITY]], value capture, and future geometry. [[term:POLARIZATION]] pressure punishes capped ranges; small [[term:BLOCKERS]] bets harvest [[term:THIN_VALUE]] and control exposure. Pools often [[term:OVERFOLD]] to big [[term:POLARIZATION]] bets OOP and under-raise rivers versus small bets.

Rules of thumb

- Prefer size_down_dry on static rivers with condensed ranges when you hold thin value. You set a price, target bluff-catchers, and deter large raises.
- half_pot_50 is the default turn/river size when range interaction is balanced or unclear. It keeps rivers playable and avoids committing with marginals.
- After small_cbet_33 on dry flops, double_barrel_good on range-shifting turns; on credible scare rivers with supporting [[term:BLOCKERS]], triple_barrel_scare.
- OOP on middling textures without nut share, protect_check_range. Do not force thin bets that expose you to raises.
- Versus polar sizing: call when you block value and unblock bluffs; fold more with poor [[term:BLOCKERS]] and capped ranges. Raise rarely unless you hold clear nuts.

Mini example
MP opens 2.3bb, BTN calls, BB calls. Flop Q72r: MP small_cbet_33; BTN calls. Turn 4x checks through. River 7 pairs; draws miss. With A7s (trips, blocks boats), BTN chooses big_bet_75 to polarize. With QJ and no boat [[term:BLOCKERS]], prefer size_down_dry to target worse queens and pocket pairs while capping exposure.

Common mistakes
- Treating big_bet_75 as bluff-only (need value plus [[term:BLOCKERS]] bluffs).
- Using size_down_dry on volatile textures or short-[[term:SPR]] turns.
- Auto half pot on every river (ignore nut advantage/[[term:BLOCKERS]]).
- Calling polar bets with weak [[term:BLOCKERS]] (population under-bluffs these).

Mini-glossary
big_bet_75: Large polar bet for value and bluffs when you hold advantage.
size_down_dry: Small blocker/thin-value sizing on static nodes.
half_pot_50: Default pressure when neither polar nor blocker fits well.
small_cbet_33: Cheap flop bet on dry boards to deny and keep worse hands in.
double_barrel_good: Second barrel on turns that improve your range.
triple_barrel_scare: Final barrel on credible scare rivers.
protect_check_range: Checking to keep medium hands and avoid exploitation.
[[term:EV]]: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
- Unlike baseline small_cbet_33 trees that realize [[term:EQUITY]] cheaply, this module shifts to polarized big_bet_75 and size_down_dry on later streets to maximize fold [[term:EQUITY]] or [[term:THIN_VALUE]] while keeping defense sound against opponents' [[term:POLARIZATION]] sizing.

_This module uses the fixed families and sizes: size_down_dry, size_up_wet; small_cbet_33, half_pot_50, big_bet_75._

See also
- cash_3bet_oop_playbook (score 19) -> ../../cash_3bet_oop_playbook/v1/theory.md
- cash_blind_defense_vs_btn_co (score 19) -> ../../cash_blind_defense_vs_btn_co/v1/theory.md
- cash_turn_river_barreling (score 19) -> ../../cash_turn_river_barreling/v1/theory.md
- donk_bets_and_leads (score 19) -> ../../donk_bets_and_leads/v1/theory.md
- hu_postflop_play (score 19) -> ../../hu_postflop_play/v1/theory.md
