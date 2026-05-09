What it is
A defensive playbook for spotting live integrity risks (soft-play clusters, chip-dump patterns, marked/defective decks, device/communication cues, angle pressure, repeated procedural errors) and translating them into frequency shifts using the fixed token set. Sizes/trees never change: postflop families stay 33/50/75; physics first selects size_down_dry on static boards and size_up_wet on dynamic boards. Integrity context only nudges frequencies.

Why it matters
Compromised games erase edges and raise cognitive load. Sticking to 33/50/75 and 9/12/21/24 while choosing safer tokens (protection, delay, river discipline, evidence-gated exploits) preserves EV and reduces tilt.

Rules of thumb
- Soft-play suspected: tighten aggression; add protect_check_range and trim double_barrel_good bluffs; vs polar rivers without blockers, fold to big_bet_75. Why: reduce exposure.
- Chip-dump vibe / strange all-in asymmetry: prefer merged value (half_pot_50), fewer thin calls; default fold vs big_bet_75 without blockers. Why: protect against engineered volatility.
- Marked/defective deck suspicion: simplify lines - small_cbet_33 on static, half_pot_50 on dynamic; avoid fancy bluffs. Why: execution certainty.
- Angle pressure (string-bet traps, out-of-turn induces): earlier protect_check_range; at mid SPR choose delay_turn. Why: avoid getting blown off equity.
- Repeated heads-up against a "protected" position (others overfold): with persistent evidence, tag overfold_exploit preflop (widen 3bet_ip_9bb / 3bet_oop_12bb); keep postflop discipline. Why: price edge without changing sizes.
- River fear nodes amplified: default fold to big_bet_75 without blockers; with blockers as PFA, triple_barrel_scare only if planned. Why: under-bluffed.
- Chaotic multi-limp/deal issues: favor merged (half_pot_50), thin value via size_down_dry; fewer pure bluffs. Why: realization drops multiway.
- Enforcement strict: raise frequency falls - use delay_turn and protect_check_range more. Why: fewer random raises.
- Enforcement loose: protect earlier (protect_check_range), default half_pot_50, keep families tight. Why: control variance.


 

Mini example
1) SB vs BB soft-play suspicion: SRP on K72r (static) checks through. Log softplay_suspected. Turn: choose probe_turns (sequence); river facing big_bet_75 without blockers -> fold.
2) BTN vs BB, angle pressure in a strict room: 3-bet pot turn on a dynamic card; raise-prone opponent, enforcement_strict. Pick delay_turn instead of thin barrel; note persistent fast folds to your 12bb - next orbit widen with 3bet_oop_12bb (evidence-gated).

Common mistakes
- Paranoia -> off-tree bets. Fix: keep 33/50/75; shift frequency only.
- Calling polar rivers without blockers. Fix: default fold vs big_bet_75.
- Tagging overfold_exploit after one hand. Fix: require repetition.
- Mixing probes/probe_turns. Fix: probe_turns only after chk-chk.
- Ignoring protection in loose enforcement rooms. Fix: add protect_check_range / delay_turn.
- Trying to "test" integrity with spewy lines. Fix: document and escalate; keep tokens conservative.

Mini-glossary
Soft-play: coordinated avoidance of confrontation.
Chip dumping: intentionally shifting chips via unnatural lines.
Angle: procedural pressure to induce mistakes.
Enforcement strict/loose: how tightly rules (e.g., string_bet) are applied.
Documentation mindset: timestamp, positions, sequence, token taken.
Evidence gate: repetition threshold before exploits.

Angle shooting: Unethical behavior to exploit unclear situations or rules.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times
Contrast
Unlike live_etiquette_and_procedures (broader conduct) and live_floor_calls_and_dispute_resolution (rulings), this module turns integrity risk into conservative frequency shifts with the same tokens, keeping physics-first family selection intact.

See also
- bankroll_and_variance_management (score 27) -> ../../bankroll_and_variance_management/v1/theory.md
- cash_short_handed (score 27) -> ../../cash_short_handed/v1/theory.md
- exploit_advanced (score 27) -> ../../exploit_advanced/v1/theory.md
- icm_final_table_hu (score 27) -> ../../icm_final_table_hu/v1/theory.md
- live_etiquette_and_procedures (score 27) -> ../../live_etiquette_and_procedures/v1/theory.md