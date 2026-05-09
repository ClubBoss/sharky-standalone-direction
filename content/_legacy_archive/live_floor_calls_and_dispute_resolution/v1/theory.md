What it is
Procedural playbook for live floor calls and dispute resolution. We convert rulings and enforcement styles into frequency shifts using the fixed token set; postflop sizes remain 33/50/75. Physics first: size_down_dry on static boards; size_up_wet on dynamic boards. Floor outcomes shift frequency, not sizes.

Why it matters
Clear rulings reduce angle-risk, avoid mis-sized bets, and preserve mental bandwidth. Staying inside 33/50/75 and 9/12/21/24 while adjusting frequencies prevents tilt lines and keeps EV centered on texture and population tendencies.

Rules of thumb
- [[term:STRING_BET]] & single_motion_raise_legal enforced strictly -> use protect_check_range earlier and delay_turn at mid [[term:SPR]]. Why: fewer multi-raise trees; realize [[term:EQUITY]] safely. 
- Loose line_rule rooms (ambiguous forward motion) -> protect_check_range more; trim [[term:THIN_VALUE]] turn bluffs. Why: raise-prone environments punish marginal barrels. 
- Out_of_turn action ruled dead / reset -> re-center on texture; keep family (size_down_dry vs size_up_wet); prefer delay_turn over impulsive stabs. Why: avoid reactionary errors. 
- bettor_shows_first / first_active_left_of_btn_shows clarity -> capture showdown info; after flop chk-chk, plan [[term:PROBE]]_turns. Why: reliable surrender reads convert to probes. 
- Incomplete raise / minimum raise ruling -> do not "fix" with new sizes; maintain family and sequence; default to half_pot_50 on turns when [[term:MERGE]]d. Why: legality != strategy change. 
- River dispute nodes[] -> live pools under-bluff [[term:POLARIZATION]]; versus big_bet_75 without [[term:BLOCKERS]] prefer fold. Why: protect against thin hero calls. 
- Multi_limpers or lax enforcement -> more protect_check_range; [[term:THIN_VALUE]] via size_down_dry; fewer pure bluffs. Why: multiway + disputes reduce bluff [[term:EV]]. 
- has_straddle / bomb_ante clarified -> selectively widen 3bet_ip_9bb / 3bet_oop_12bb with [[term:BLOCKERS]]; sizes unchanged. Why: dead money, same families. 



Mini example
- Strict single_motion_raise_legal; BTN vs BB SRP on K72r (static). family: size_down_dry. Choose small_cbet_33, then delay_turn when raise frequencies spike; river big_bet_75 from tight reg without blockers -> fold. 
- Out_of_turn reset in a straddled pot; SB vs BB checks through on flop. family stays size_up_wet; because sequence was chk-chk, take probe_turns; if enforcement is loose next orbit, add protect_check_range earlier.

Common mistakes
Overreacting to rulings with off-tree sizes; confusing [[term:PROBE]]_turns (chk-chk) with turn [[term:PROBE]]_turns; hero-calling big_bet_75 without [[term:BLOCKERS]] in disputed rivers; ignoring announce_required and creating illegal sizes; failing to protect_check_range in loose-enforcement rooms; tagging [[term:OVERFOLD]]_[[term:EXPLOIT]] on a single incident.

Mini-glossary
String bet: multiple forward motions that invalidate a raise in strict rooms. 
Single-motion raise: one continuous push for a legal raise. 
Line rule: chips past a line are committed; enforcement varies. 
Verbal binding: clear declarations stand over chips. 
Out-of-turn: acting before your turn; actions may be binding or reset. 
Incomplete raise: raise amount less than minimum allowed; corrected to legal minimum. 
Announce required: room asks for verbal amounts before motion. 
Show order: bettor_shows_first or first_active_left_of_btn_shows determines reveal sequence.

Angle shooting: Unethical behavior to exploit unclear situations or rules.

[[term:EV]]: Expected Value - the average amount you'd win or lose if you made the same play many times
Contrast
live_etiquette_and_procedures covers broader conduct; live_chip_handling_and_bet_declares covers mechanics. This module focuses on floor rulings and disputes and how they modulate frequencies inside the same tokens and 33/50/75 families.

See also
- cash_short_handed (score 29) -> ../../cash_short_handed/v1/theory.md
- hand_review_and_annotation_standards (score 29) -> ../../hand_review_and_annotation_standards/v1/theory.md
- icm_final_table_hu (score 29) -> ../../icm_final_table_hu/v1/theory.md
- live_session_log_and_review (score 29) -> ../../live_session_log_and_review/v1/theory.md
- mtt_icm_basics (score 29) -> ../../mtt_icm_basics/v1/theory.md
