What it is
Advanced ICM endgame covers bubble, pre-FT jumps, and FT down to 3-handed. Chips do not equal cash; busting is costly. Coverage asymmetry: big stacks apply pressure, medium stacks have highest risk premium, short stacks choose clean shove/call-off trees.


Why it matters
Pay jumps turn good chips-EV plays into bad cash-EV plays. Calling off when covered needs more equity; thin peels OOP are punished. Jam-first trees simplify decisions, avoid dominated multiway spots, and let you leverage coverage with credible pressure.

Rules of thumb
- Roles: big stacks pressure wide opens, 3-bet/jam more; medium stacks tighten call-offs and avoid flats OOP; short stacks time shove spots and avoid fancy postflop.
- Preflop: favor jam/reshove proxies 3bet_ip_9bb and 3bet_oop_12bb over flats when covered. Keep 4bet_ip_21bb and 4bet_oop_24bb value-lean; bluff 4-bets rare unless you cover and hold top blockers.
- Coverage: when covered, fold more to jams and large sizings; when you cover, widen steals and reshoves, especially BTN/SB vs blinds.
- Squeeze: squeeze as the cover versus open+caller; cold-calling OOP when covered creates bad SPR and dominated ranges.
- Postflop: small_cbet_33 on safe, static boards when uncapped; protect_check_range more OOP. Use half_pot_50 only with value+equity to set clean commit lines; big_bet_75 requires size_up_wet equity or nut advantage.
- Timing: delay_turn and probe_turns selectively; reduce bluff rate when covered. As the cover, plan double_barrel_good on range turns and only triple_barrel_scare on credible rivers with blockers.
- Exploit: mediums overfold turns to covering stacks-tag overfold_exploit on those nodes.

Mini example
Bubble, 9-max. CO 36bb (covered by BTN 62bb) opens 2.2bb. BTN 3bet_ip_9bb (jam-proxy) with A5s: blockers + coverage. CO folds KJo (chips-EV defend). At FT, SB 24bb (covered by BB 55bb) opens 2.1bb; BB reshoves 3bet_oop_12bb with AJo, SB folds dominated. Postflop, CO defends vs CL 3-bet; on K72r CL uses small_cbet_33, then half_pot_50 on a range-shifting turn. On river A with blockers, CL may triple_barrel_scare; without, protect_check_range earlier and abort.

Common mistakes
Mini-glossary
Risk premium: extra equity required to continue because busting loses payout equity.
Covered/Cover: opponent has you covered / you cover them; shifts who should risk chips.
3bet_ip_9bb / 3bet_oop_12bb: jam/reshove proxies to simplify endgame trees.
4bet_ip_21bb / 4bet_oop_24bb: value-lean 4-bet families under ICM.
small_cbet_33 / half_pot_50 / big_bet_75: turn/river size families.
protect_check_range / delay_turn / probe_turns: low-risk lines to control exposure.
overfold_exploit: pool tendency to overfold turns when pressure and coverage align.
EV: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
Compared to chips-EV deep-stack play, advanced ICM endgame favors jam-first preflop, tighter call-offs when covered, fewer bluffs, and pressure timed by coverage and blockers rather than pure equity.

_This module uses the fixed families and sizes: size_down_dry, size_up_wet; small_cbet_33, half_pot_50, big_bet_75._

See also
- exploit_advanced (score 31) -> ../../exploit_advanced/v1/theory.md
- icm_final_table_hu (score 31) -> ../../icm_final_table_hu/v1/theory.md
- live_etiquette_and_procedures (score 31) -> ../../live_etiquette_and_procedures/v1/theory.md
- live_full_ring_adjustments (score 31) -> ../../live_full_ring_adjustments/v1/theory.md
- live_session_log_and_review (score 31) -> ../../live_session_log_and_review/v1/theory.md
