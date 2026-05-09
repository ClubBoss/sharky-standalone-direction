
What it is
Apply validators such as **string_bet, single_motion_raise_legal, bettor_shows_first, first_active_left_of_btn_shows** to avoid process traps. 
Keep ladders and families fixed; texture selects **size_down_dry** (static) or **size_up_wet** (dynamic). Every decision resolves to **one token**.

Why it matters
Live pools run slower, with more limps/straddles and uneven enforcement. Ranges skew face-up in limped pots and **river polar bets are under bluffed**. A lightweight, repeatable read system stabilizes execution. You keep **33/50/75** families and **9/12/21/24** ladders and only shift **frequencies** via tokens.

Rules of thumb
- **Reliability tiers:** physical cues > speech/timing > cliches. Use repetition lanes **weak (1-2)**, **medium (3-5)**, **strong (6+)** before exploits.
- **Preflop tight folds to 3-bets + low 4-bets:** widen **3bet_oop_12bb / 3bet_ip_9bb** with blockers; upgrade premiums to **4bet_ip_21bb / 4bet_oop_24bb**.
- **Straddle or bomb_ante on:** more dead money; attempt more steals and selective 3-bets; **sizes unchanged**.
- **Multi limpers:** favor merged value with **half_pot_50** and thin value via **size_down_dry**; fewer pure bluffs; add **protect_check_range**.
- **Snap small on static from IP:** treat as merged; defend now, plan **probe_turns** after check check.
- **Tank -> small:** merged more than bluff; **call** more, raise bluffs less.
- **Tank -> big:** often under bluffed; **fold** more vs **big_bet_75** without blockers.
- **Dynamic turns + good blockers:** green light **double_barrel_good**; default **half_pot_50**, upgrade to **big_bet_75** only with evidence (**size_up_wet**).
- **Showdown reveals:** after a missed bluff class, tighten river calls unless you hold **key blockers**.
- **Procedural pressure:** when **single_motion_raise_legal** is strict, random raises drop; when loose, increase **protect_check_range** and **delay_turn**.
- **River discipline:** populations under bluff **big_bet_75**; **fold** more without blockers; use **triple_barrel_scare** only with scare + blockers.

Mini example
Live HU, **has_straddle**. SB opens 2.0bb, BB calls. **Flop K72r** (static); IP **snap 33%** is merged -> defend now and note sequence. Turn checks through; on favorable turns later, fire **probe_turns**. 
Another spot: dynamic turn on **JT9ss** improves your blockers -> **double_barrel_good** with **half_pot_50**, upgrading to **big_bet_75** only if fold vs 75 evidence appears. **River tank -> big** from a tight reg and you lack blockers -> **fold** to **big_bet_75**.

Common mistakes
- Over trusting single tells.
- Inventing off tree sizes.
- Mislabeling **probes** vs **probe_turns** after check check.
- Ignoring validators (**string_bet / single_motion_raise_legal / bettor_shows_first / first_active_left_of_btn_shows**).
- Hero calling polar rivers without blockers.
- Skipping **protect_check_range** in stabby rooms.

Mini-glossary
- **string bet:** multiple chip motions that may nullify a raise; know enforcement.
- **single motion raise:** one clean motion; validator for legal raises.
- **forward motion:** confident, continuous chip push; higher reliability than speech.
- **reverse tell:** performative act; mark low reliability.
- **blockers:** cards that reduce value combos or unblock bluffs; gate big bets.
- **polar / merged:** polar = nuts/air; merged = medium/value heavy range pieces.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times