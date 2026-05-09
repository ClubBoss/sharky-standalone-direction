# What it is
This module is a deep-dive on [[term:EV]] math for Heads-Up that also works in 6-max. You will compute [[term:EV]](call) from [[term:EQUITY]] versus price X/(P+X), [[term:EV]](bluff) = folds*P + calls*([[term:EQUITY]]*win_value + (1-[[term:EQUITY]])*lose_value), and the quick bluff breakeven B/(P+B). You will compare half_pot_50 versus big_bet_75, evaluate [[term:THIN_VALUE]] with size_down_dry, and choose preflop between 3bet_oop_12bb, call, or fold using pool fold% and [[term:EQUITY_REALIZATION]]. You will also see when 4bet_ip_21bb and 4bet_oop_24bb change [[term:EV]], plus how [[term:IMPLIED_ODDS]] and reverse [[term:IMPLIED_ODDS]] and [[term:BLOCKERS]] move fold% or call ranges.

# Why it matters
Clear math converts uncertainty into thresholds that travel across spots. When you know required [[term:EQUITY]] to call and the fold% needed for a bluff, you stop guessing sizes and start selecting actions that print. [[term:EV]] framing keeps you solver-aligned by default and [[term:EXPLOIT]]-aware when the pool [[term:OVERFOLD]]s or under-bluffs, so your decisions remain stable under pressure.

# Rules of thumb
- [[term:POT_ODDS]]: calling X into pot P needs [[term:EQUITY]] >= X/(P+X). Example: call 5bb into 10bb needs ~33%..
- Bluff breakeven: folds needed = B/(P+B). half_pot_50 needs ~33% folds; big_bet_75 needs ~43%..
- Texture to size: size_down_dry with small_cbet_33 on static boards; size_up_wet with big_bet_75 on dynamic boards..
- Preflop baselines: versus SB 2.0bb at 80-100bb, BB prefers 3bet_oop_12bb with [[term:BLOCKERS]]; shift to [[term:OVERFOLD]]_[[term:EXPLOIT]] when folds exceed breakeven..
- Realization and position: IP realizes more of raw [[term:EQUITY]]; OOP needs stronger [[term:EQUITY]] to call near thresholds..

# Mini example
UTG, MP, CO not seated. BTN is SB. BB posts 1bb. 100bb effective.
Flop T84r, pot ~10bb. BB bets 5bb. SB holds Js9s with 8 clean outs. Flop-to-river [[term:EQUITY]] ~32% by the rule-of-2-and-4. Call needs ~33% by X/(P+X). IP can call given [[term:IMPLIED_ODDS]]; OOP folds more often.
Turn 986ss-3c, pot ~10bb. As aggressor with a strong draw and [[term:BLOCKERS]], big_bet_75 = 7.5bb needs ~43% folds while half_pot_50 = 5bb needs ~33%. On dynamic cards use size_up_wet; on blanks prefer half_pot_50 or delay_turn if leverage drops.
Preflop: SB opens 2.0bb. With A5s in BB, compare flat versus 3bet_oop_12bb. If pool folds 45%+, choose [[term:OVERFOLD]]_[[term:EXPLOIT]]. Ace [[term:BLOCKERS]] also reduce 4bet_ip_21bb [[term:FREQUENCY]], improving immediate [[term:EV]].

# Common mistakes
- Calling because equity is close while OOP. Mistake: poor realization makes a breakeven call losing; why it happens: players treat raw equity as sufficient and ignore position and initiative.
- Overusing big_bet_75 on dry boards. Mistake: you rarely reach ~43% folds; why it happens: copying wet-board plans and chasing immediate folds with the wrong texture.
- Thin value too large. Mistake: bigger sizes force better hands to continue and fold worse; why it happens: anchoring on pot size instead of who is calling what. Prefer size_down_dry.

# Mini-glossary
EV(call): expected value of calling given equity and price X/(P+X).
EV(bluff): folds*P + calls*(equity*win_value + (1-equity)*lose_value).
Equity realization: fraction of raw equity captured after position and playability.
Implied odds: extra chips won when improving; reverse implied odds: extra lost when second best.

# EV: Expected Value - the average amount you'd win or lose if you made the same play many times
