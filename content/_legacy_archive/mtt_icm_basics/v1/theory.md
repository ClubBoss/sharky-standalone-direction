What it is
[[term:ICM]] (Independent Chip Model) means chips do not equal cash. Busting costs payout [[term:EQUITY]], so calling off needs more [[term:EQUITY]] than chips-[[term:EV]]. [[term:RISK_PREMIUM]] is highest for medium stacks near pay jumps, lower for big stacks who cover, and moderate for shorts forced to take spots.


Why it matters
Money jumps mean chips lost hurt more than chips won help. Good chips-[[term:EV]] calls become folds, especially when covered. Clear preflop shove/reshove trees reduce tough postflop spots. Postflop, prefer pot control OOP and apply pressure only when [[term:BLOCKERS]] and coverage favor you.

Rules of thumb
- Stack roles: big stacks apply pressure; medium stacks avoid thin calls/flats OOP; short stacks pick clean shove/call-off trees.
- Preflop: use 3bet_ip_9bb and 3bet_oop_12bb proxies; keep 4bet_ip_21bb and 4bet_oop_24bb value-lean. Bluff 4-bets are rare.
- Coverage: tighten call-offs when covered; widen slightly when you cover. Big stacks widen late-position steals; calling ranges tighten.
- Postflop: small_cbet_33 on dry when uncapped; half_pot_50 only for clean commit lines with value+[[term:EQUITY]]. Avoid big_bet_75 without clear [[term:EQUITY]] and narrative.
- Line selection: protect_check_range OOP to avoid stack-off. delay_turn and [[term:PROBE]]_turns only when turn meaningfully shifts [[term:RANGE_ADVANTAGE]] and risk is acceptable.
- [[term:EXPLOIT]]s: mediums [[term:OVERFOLD]] turns when covered—tag [[term:OVERFOLD]]_[[term:EXPLOIT]] and press. Avoid hero-calls without [[term:BLOCKERS]]; fold is fine under [[term:ICM]].
- Geometry: plan flop+turn to avoid all-in confrontations when covered. Prefer fold over [[term:THIN_VALUE]] peels that create dominated rivers.

Mini example
Bubble, 9-max. CO 35bb opens 2.2bb, covered by BTN 60bb and blinds. BTN 3bet_ip_9bb (reshove-proxy). CO folds KJo (chips-[[term:EV]] defend) because covered and [[term:RISK_PREMIUM]] is high. With AQo, CO 4bet_ip_21bb only if BTN is loose and a shorter stack exists; otherwise fold. Postflop is mostly avoided by clean preflop trees.

Common mistakes
- Calling off barely chips-EV while covered. Fold and keep ladder equity.
- Flatting OOP with medium stack to "see a flop." Prefer 3bet_oop_12bb shove-proxy or fold.
- Vanity turn barrels when covered. Use half_pot_50 only with value+equity; otherwise protect_check_range.
- Bluff 4-betting tight players. Keep 4bet_ip_21bb and 4bet_oop_24bb value-lean.

Mini-glossary
Risk premium: extra equity required to continue because busting costs payout equity.
Covered: opponent has you out-chipped; your bust risk is higher.
3bet_ip_9bb / 3bet_oop_12bb: shove/reshove proxies under ICM.
4bet_ip_21bb / 4bet_oop_24bb: value-lean 4-bet families; bluffing rare.
small_cbet_33 / half_pot_50 / big_bet_75: size families; choose smaller and safer under ICM pressure.
protect_check_range / delay_turn / probe_turns: lines to control risk or time aggression.
overfold_exploit: node where population folds too much under pressure.
EV: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
Versus chips-EV deep-stack play, ICM shifts value from thin calls and bluffs toward folds and jam-first trees. You win by avoiding dominated commitments when covered and by applying disciplined, blocker-backed pressure when you cover.

_This module uses the fixed families and sizes: size_down_dry, size_up_wet; small_cbet_33, half_pot_50, big_bet_75._

See also
- cash_short_handed (score 31) -> ../../cash_short_handed/v1/theory.md
- icm_final_table_hu (score 31) -> ../../icm_final_table_hu/v1/theory.md
- live_session_log_and_review (score 31) -> ../../live_session_log_and_review/v1/theory.md
- online_economics_rakeback_promos (score 31) -> ../../online_economics_rakeback_promos/v1/theory.md
- online_hudless_strategy_and_note_coding (score 31) -> ../../online_hudless_strategy_and_note_coding/v1/theory.md
