What it is
This module explains cash-game rake models and how they affect stake selection and winrate math. You will learn percentage-with-cap rake, no flop no drop policies, time charge, and how rakeback changes your net results. The goal is to choose games and lines that win after fees with steady [[term:EV]].


Why it matters
At small stakes, rake can be your biggest opponent. Rake structure changes which hands are profitable, which tables are worth playing, and which stake to target. Understanding rake lets you pick games where your edge converts to real profit.

Rules of thumb
- Know the model. Percentage-with-cap takes a % until a cap; no flop no drop means folded preflop pots pay zero; time charge is a fixed fee per time block.
- Avoid many small pots in high rake. Tighten early and prefer hands that make strong top pairs or better.
- Build capped pots with edge. Once the cap is hit, extra chips are rake-free; value bet more confidently and press positional edges.
- Raise more when no flop no drop applies. Steals that work end the hand with zero rake; isolate limpers and pressure blinds.
- Choose stakes by net winrate. A better cap-to-blind ratio with similar opponents can beat a nominally smaller game.

Quick math
Net winrate (bb/100) = gross_winrate - rake_paid_per_100 + rakeback_per_100.
Cap effect: after the cap, each extra chip is 0% rake; value sizings gain.

Mini example
UTG opens 2.2bb, CO calls, BB calls. Flop K72r: UTG bets small; CO folds, BB calls. Turn 5x: UTG bets again; BB folds. In a % with cap game the pot never hit the cap, so rake stayed a noticeable %. UTG kept value-lean lines; on loose tables that reach the cap often, value can be thicker after the cap.

Common mistakes
- Ignoring rake when picking stakes (a bad cap can erase thin edges).
- Limping along in high rake rooms (many small flops pay heavy fees).
- Misusing time charge (tight games with few hands/hour bloat cost per hand).

Mini-glossary
Rake cap: Maximum fee taken from a pot in percentage-with-cap systems; chips above the cap are rake-free.
No flop no drop: If no flop is dealt the house takes no rake, so preflop folds pay zero.
Time charge: Fixed fee per time block, common live; cost per hand falls as volume rises.
Net winrate: Your winrate after subtracting rake and adding any rakeback or rewards.
[[term:EV]]: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
Unlike core_bankroll_management, which sets bankroll cushions and stop-loss rules, this module helps you select stakes and tables where rake structure allows your edge to become real profit.

_This module uses the fixed families and sizes: size_down_dry, size_up_wet; small_cbet_33, half_pot_50, big_bet_75._

See also
- cash_blind_defense (score 5) -> ../../cash_blind_defense/v1/theory.md
- cash_blind_defense_vs_btn_co (score 5) -> ../../cash_blind_defense_vs_btn_co/v1/theory.md
- cash_blind_vs_blind (score 5) -> ../../cash_blind_vs_blind/v1/theory.md
- cash_isolation_raises (score 5) -> ../../cash_isolation_raises/v1/theory.md
- cash_limp_pots_systems (score 5) -> ../../cash_limp_pots_systems/v1/theory.md
