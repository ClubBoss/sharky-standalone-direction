What it is
Pot odds and [[term:EQUITY]] for Heads-Up and 6-max. Compute call price X/(P+X), bluff breakeven B/(P+B), quick [[term:EQUITY]] from outs using rule-of-2-and-4 with [[term:BLOCKERS]], and [[term:EQUITY_REALIZATION]] by position. Connect numbers to actions: 3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb, small_cbet_33, half_pot_50, big_bet_75, size_up_wet, size_down_dry, protect_check_range, delay_turn, probe_turns, double_barrel_good, triple_barrel_scare, call, fold, overfold_exploit.

Why it matters
Math converts noisy spots into clear thresholds. Know your equity and price, choose call or fold without guesswork. Know required fold percentages, select half_pot_50 or big_bet_75 and adjust with overfold_exploit where pools overfold.

Rules of thumb
- Call price: calling X into pot P needs equity >= X/(P+X). Calling 5bb into 10bb needs ~33%; 7.5bb into 10bb needs ~43%. Use this threshold to decide call vs fold.
- Bluff breakeven: B into P needs folds = B/(P+B). half_pot_50 needs ~33% folds; big_bet_75 needs ~43%. Smaller sizes need fewer folds but win less when called.
- Outs to equity: rule-of-2-and-4. Turn-to-river ~2% per out; flop-to-river ~4% per out. Discount dirty outs that pair the board poorly or improve villain.
- Position and realization: IP realizes more equity than OOP. Tighten near-threshold OOP calls; widen IP calls when implied odds exist, but account for reverse implied odds on dominated draws.
- Size families: size_down_dry with small_cbet_33 on static boards (A83r, K72r); size_up_wet with big_bet_75 on dynamic boards (JT9ss, 986ss). Preflop: 3bet_oop_12bb vs SB 2.0bb opens, 3bet_ip_9bb IP; 4-bets are 4bet_ip_21bb and 4bet_oop_24bb. Blockers increase folds and reduce 4-bets.

Mini example
Pot ~10bb on flop T84r. BB bets 5bb. SB holds Js9s with 8 outs. Turn-only ~16%, flop-to-river ~32%. Price needs ~33%. IP calls with implied odds; OOP folds more without position.
As a bluff on 986ss turn with strong draw and blockers, big_bet_75 into 10bb needs ~43% folds, while half_pot_50 needs ~33%. Choose size_up_wet on dynamic turns and size_down_dry on static ones.
Preflop 100bb: SB opens 2.0bb. BB compares flat vs 3bet_oop_12bb with A5s. If the pool overfolds to 12bb, use overfold_exploit by increasing 3-bet frequency with blockers. If SB 4-bets rarely, value 3-bet more with premiums.

Common mistakes
- Calling close numbers while OOP. Poor realization turns break-even into negative EV; players ignore position.
- Oversizing bluffs on dry boards. big_bet_75 needs ~43% folds dry boards rarely deliver; copying wet-board plans.
- Ignoring dirty outs and blockers. Counting outs that make second best or bluffing without blockers; focusing on hand strength instead of combos.

Mini-glossary
Pot odds: the price to continue, X/(P+X), compared to equity.
Bluff breakeven: required folds, B/(P+B).
Equity realization: how much raw equity becomes EV after position and playability.
Dirty outs: outs that also improve villain or create reverse implied odds.

[[term:EV]]: Expected Value - the average amount you'd win or lose if you made the same play many times
