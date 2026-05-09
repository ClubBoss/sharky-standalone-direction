What it is
Satellite strategy for 9-max with flat tickets prioritizes survival over chip accumulation. Decisions weight bubble factor, coverage (who covers whom), and payout math (players left vs tickets). Preflop trees lean jam-first; postflop lines avoid variance. Use size families and tokens to control risk.


Why it matters
One chip won is not equal to one chip lost when tickets are flat. Busting is far worse than folding a small edge. Coverage flips incentives: when covered, you need more equity; when you cover, widen steals/reshoves. Avoid side pots.

Rules of thumb
- Payout math: if players left <= tickets, fold everything except hands that cannot lose chips. Near tickets, mediums have highest risk premium.
- Coverage: when covered, tighten call-offs and flats; prefer folds or shove trees (3bet_oop_12bb / 3bet_ip_9bb). When you cover a short, widen reshoves; avoid thin calls that can bust you.
- Stack bands: 8-15bb jam-first; 16-25bb shove/reshove or fold tight (flat IP only when not covered); 26-40bb open small, 3-bet narrow; 4bet_ip_21bb / 4bet_oop_24bb value-lean.
- Multiway: avoid dominated flats OOP; prefer 3bet_oop_12bb over calls to prevent side pots.
- Postflop: small_cbet_33 on static boards when uncapped and risk low; protect_check_range OOP on middling boards; delay_turn and probe_turns only when the turn clearly favors you.
- Sizing: half_pot_50 only when committing with value+equity and SPR is clean; big_bet_75 only with size_up_wet and real equity (rare).
- Exploit: near the bubble, tag overfold_exploit and pressure only when not risking coverage disasters.

Mini example
Bubble: 10 left, 9 tickets. CO 22bb covered by BTN 40bb. HJ opens 2.2bb; AJs. Flatting invites BTN squeeze and side pots. 3bet_ip_9bb only if it functions as a shove/reshove; otherwise fold. Next hand, BTN opens your SB with short BB behind: defend BB tighter. Postflop on K72r as raiser and not covered, small_cbet_33; on turn bricks, prefer delay_turn or check.

Common mistakes
- Calling off while covered with medium strength because "priced in." In satellites, price is dominated by risk premium.
- Flatting OOP versus opens to "see a flop," then facing multiway side pots that risk busting.
- Using big_bet_75 without equity on volatile turns; it bloats the pot and induces punted call-offs.
- Bluff 4-betting without coverage or blockers at 20-30bb; value only.

Mini-glossary
Bubble factor: extra equity needed to risk elimination relative to chip-EV.
Coverage: who can bust whom; being covered increases your risk premium.
Payout math: players remaining vs tickets; determines how tight you should be.
Side pot: chips wagered by non-all-in players; increases bust exposure.
Call-off: committing your stack versus an all-in; ultra-tight when covered.
EV: Expected Value - the average amount you'd win or lose if you made the same play many times

Contrast
Unlike chips-EV MTT or PKO, satellites weight survival over chip gain. Jam-first preflop and risk-controlled postflop dominate; thin edges, splashy multiway flats, and big polar bets are mostly removed unless they clearly lock a ticket.

_This module uses the fixed families and sizes: size_down_dry, size_up_wet; small_cbet_33, half_pot_50, big_bet_75._

See also
- database_leakfinder_playbook (score 25) -> ../../database_leakfinder_playbook/v1/theory.md
- donk_bets_and_leads (score 25) -> ../../donk_bets_and_leads/v1/theory.md
- hand_review_and_annotation_standards (score 25) -> ../../hand_review_and_annotation_standards/v1/theory.md
- icm_final_table_hu (score 25) -> ../../icm_final_table_hu/v1/theory.md
- live_chip_handling_and_bet_declares (score 25) -> ../../live_chip_handling_and_bet_declares/v1/theory.md
