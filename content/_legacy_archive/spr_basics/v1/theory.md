What it is
SPR (stack-to-pot ratio) is the stack remaining behind relative to the pot at the start of a street. It shapes value thresholds, bluff viability, and pressure plans, while sizes remain fixed. Preflop ladders control SPR: 3bet_ip_9bb and 3bet_oop_12bb lower SPR; 4bet_ip_21bb and 4bet_oop_24bb create cleaner, lower SPRs. Texture still picks the size family: size_down_dry on static boards and size_up_wet on dynamic boards. SPR then nudges frequencies inside those families, not the sizes themselves.

Why it matters
Low SPR favors commit-capable value and simpler lines; trim thin calls and use small_cbet_33 or half_pot_50 to realize equity. High SPR allows more maneuvering: thinner value on static with size_down_dry and more delayed lines when raises are likely. You keep trees and sizes constant and adjust only how often you use each token.

Rules of thumb

* 3bet_oop_12bb / 3bet_ip_9bb reduce SPR and lift the value of top pairs and initiative, making continuation betting more profitable and simplifying commitment decisions.
* 4bet_ip_21bb / 4bet_oop_24bb set clean low SPR; trim OOP flats near low SPR to avoid difficult postflop spots where equity realization is poor.
* Low SPR + static flop -> size_down_dry with small_cbet_33 for cheap denial, easier turn decisions, and better bluff-to-value ratios.
* Higher SPR + dynamic flop -> size_up_wet; start half_pot_50, upgrade to big_bet_75 with blockers and fold equity to leverage draws while controlling variance.
* Commit thresholds: if a turn big_bet_75 leaves trivial stack behind on river, plan double_barrel_good only with equity and blockers to ensure clean realization.
* Low SPR does not auto-call: fold versus big_bet_75 without blockers in under-bluffed pools because population effect dominates pot price.
* Mid-SPR OOP vs raise-prone IP -> delay_turn with medium strength and protect_check_range to avoid getting blown off equity by aggressive turn raises.
* High SPR after chk-chk -> probe_turns more frequently because opponents surrender turns at high SPR after missing flop continuation bet opportunities.
* Keep preflop ladders and postflop sizes fixed; SPR shifts frequencies only within established families, never changing the size trees themselves.


Mini example
HU 100bb 3-bet pot (low SPR): BB 3bet_oop_12bb vs SB 2.0bb. Flop JT9ss (dynamic) -> half_pot_50; turn Qs with blockers -> double_barrel_good, consider big_bet_75 (size_up_wet) if folds spike.
HU SRP (high SPR) on A83r: IP small_cbet_33 for thin value (size_down_dry); facing raise-happy IP when OOP, choose delay_turn on K72r-3x.
River discipline: mid/low SPR scare river facing big_bet_75 without blockers -> fold.

Common mistakes

* Equating low SPR with auto-stacking regardless of pool under-bluffs.
* Forcing off-tree sizes to engineer shoves; only 33/50/75 are allowed.
* Over-bluffing high SPR rivers on static runouts.
* Calling too many medium-equity hands OOP at mid SPR.
* Skipping protect_check_range vs stabby IP and getting probed off equity.

Mini-glossary
SPR: stack-to-pot ratio at street start.
Clean SPR: low, simple SPR created by 4-bets for clear decisions.
Commitment threshold: point where remaining stack makes future shoves trivial.
Realization: how well your hand converts equity to EV given position/SPR.
Leverage: pressure created by bet size relative to remaining stack.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times
