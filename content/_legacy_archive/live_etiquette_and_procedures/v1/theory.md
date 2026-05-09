What it is
This module turns live-room etiquette and procedures into stable [[term:FREQUENCY]] shifts using the fixed token set. You keep the same preflop ladders (3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb) and postflop families (small_cbet_33, half_pot_50, big_bet_75). Texture still rules the family - size_down_dry on static boards like A83r/K72r, size_up_wet on dynamic boards like JT9ss/986ss. Etiquette and procedures only adjust how often you bet, protect_check_range, delay_turn, [[term:PROBE]]_turns, double_barrel_good, triple_barrel_scare, call, fold, or tag [[term:OVERFOLD]]_[[term:EXPLOIT]].

Why it matters
Live pitfalls - string_bet, unclear declarations, out-of-turn action, line_rule confusion, show-order disputes, and sloppy chip handling - cause mis-sized or illegal bets and [[term:TILT]]. Clear procedures reduce angle-risk and mental load so you execute the same tokens reliably. No off-tree bets; error control beats thin [[term:EV]].

Rules of thumb

* Loose enforcement: expect stabby raises. Increase protect_check_range; reduce thin bluffs; default half_pot_50. Why: control [[term:VARIANCE]] when lines get noisy.
* Multi-limpers: realization falls. Prefer half_pot_50 for merged value; thin value with size_down_dry; fewer pure bluffs. Why: multiway EV is lower.
* Straddles/bomb_ante: price improves; widen 3bet_ip_9bb / 3bet_oop_12bb slightly only after repetition (overfold_exploit). Why: evidence-gated.
* Simplicity under load: bias to small_cbet_33, half_pot_50, delay_turn; avoid fancy triple_barrel_scare. Why: accuracy.
* Rivers: tank->big from tight players is under-bluffed. Without [[term:BLOCKERS]], fold to big_bet_75. Why: population.
* Show-order: use bettor_shows_first / first_active_left_of_btn_shows to bank info and plan [[term:PROBE]]_turns. Why: info drives tokens.
* Ambiguity: announce sizes first (verbal_binding), clarify line_rule, and stay in-family. Why: avoid floor calls.



Mini example
SB vs BB, has_straddle. Strict single_motion_raise_legal. SB opens 2.0bb, BB calls. Flop K72r (static): size_down_dry -> small_cbet_33. Turn 6x vs raise-prone IP: choose delay_turn. River tank->big from a tight reg without blockers: fold to big_bet_75. Later, a flop checks through; next orbit probe_turns on a favorable turn.

Common mistakes
Off-tree chip splashes and illegal sizes; mislabeling probe_turns vs turn probes; hero-calling tank->big rivers without blockers; arguing instead of using verbal_binding/calling the floor; skipping protect_check_range in stabby rooms; treating bomb_ante as license to over-bluff.

Mini-glossary
string bet: multiple chip motions that can invalidate a raise; avoid with one motion.
single-motion raise: one clean push that makes raises legal and clear.
line rule: chips past a line are binding; clarify before acting.
verbal binding: declared action stands; use it to lock 33/50/75 sizes.
out-of-turn: premature action; action backs up; reset calmly.
bettor shows first: the aggressor reveals first at showdown.
first_active_left_of_btn_shows: when river checks through, first live player left of button shows first.
forward motion: decisive chip push often read as strength; treat as medium-reliability cue.

Angle shooting: Unethical behavior to [[term:EXPLOIT]] unclear situations or rules.

[[term:EV]]: Expected Value - the average amount you'd win or lose if you made the same play many times
Contrast
live_tells_and_dynamics focuses on reads; this module focuses on procedures and etiquette that stabilize execution. Same ladders and size families; only frequency shifts through the tokens.

See also
- live_full_ring_adjustments (score 33) -> ../../live_full_ring_adjustments/v1/theory.md
- live_speech_timing_basics (score 33) -> ../../live_speech_timing_basics/v1/theory.md
- online_hud_and_db_review (score 33) -> ../../online_hud_and_db_review/v1/theory.md
- online_table_selection_and_multitabling (score 33) -> ../../online_table_selection_and_multitabling/v1/theory.md
- cash_short_handed (score 31) -> ../../cash_short_handed/v1/theory.md
