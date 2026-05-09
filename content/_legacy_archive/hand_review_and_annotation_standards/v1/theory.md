# What it is
This module defines how to review hands and write minimal annotations that translate directly into one action token. You will log texture, price, position, initiative, blockers, raise risk, sequence, pressure gates, and SPR. Then you will map to exactly one of: 3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb, small_cbet_33, half_pot_50, big_bet_75, size_up_wet, size_down_dry, protect_check_range, delay_turn, probe_turns, double_barrel_good, triple_barrel_scare, call, fold, overfold_exploit.

# Why it matters
Consistent notes compress a hand into repeatable cues. Physics first: texture picks size family (size_down_dry on static like A83r/K72r.

# Rules of thumb

- Annotation grammar: one line per street with Price (pot/size), Texture (dry/wet), family (33/50/75), Position (IP/OOP), Initiative (PFA/Caller), Blockers, Raise risk, Sequence (chk-chk/x/r threat), Pressure gate (Fv50/Fv75 trend), SPR band, token.
- Mandatory tags: Texture, family, Initiative, Position, Blockers, Sequence, Pressure gate, SPR band. If unknown, mark "n/a" and be conservative.
- Conversion rule: every street annotation ends in exactly one token.
- Texture discipline: record family as size_down_dry on static, size_up_wet on dynamic. token = small_cbet_33 / half_pot_50 / big_bet_75.
- Triage priorities: price errors first; wrong family second; missed probe_turns after chk-chk; turn double barrels without blockers; river calls without blockers in polar nodes.
- Preflop ladders: record ladder use only (3bet_ip_9bb / 3bet_oop_12bb / 4bet_ip_21bb / 4bet_oop_24bb). Overfold tags require persistence.
- Raise-risk handling: if raise-prone IP at mid SPR, prefer delay_turn or protect_check_range.
- Probe vs probe_turns: Sequence "chk-chk" flags probe_turns.
- Commitment planning: if turn big_bet_75 would leave trivial behind, require equity/blockers or stay at half_pot_50.
- Drill pipeline: each reviewed hand yields one demo and one drill (Q -> single token).

# Mini example
Preflop: HU 100bb, BTN opens 2.5bb, BB 3-bet to 7.5bb, BTN calls.
Flop: 3-bet pot K72r, BB checks, BTN bets 5bb (**small_cbet_33**, size_down_dry), BB calls. Annotation: Texture dry, family 33/50/75, IP, PFA, blockers none, raise risk low, sequence none, pressure gate n/a, SPR mid, token small_cbet_33.
Turn: K72r-5x, BB checks, BTN bets 14bb (**half_pot_50**), BB calls. Annotation: Static turn, family 33/50/75, IP, PFA, blockers Kx, raise risk low, sequence none, pressure gate Fv50 normal, SPR mid, token half_pot_50.
River: K72r-5x-2x, BB checks, BTN bets 38bb (**big_bet_75**), BB folds. Annotation: Static runout, family 33/50/75, IP, PFA, blockers Kx, raise risk none, sequence none, pressure gate Fv75 up, SPR mid, token big_bet_75.

Common mistakes

- Verbose paragraphs with no token. Fix: one line per street, one token.
- Off-tree sizes. Fix: 33/50/75 only; record family then token.
- Ignoring blockers at river. Fix: require blocker note before call or triple_barrel_scare.
- Missing Sequence tag. Fix: mark chk-chk; add probe_turns.
- Mixing EV rants with reads. Fix: store only cues that map to tokens.
- Tagging overfold_exploit on one hand. Fix: require repetition.

# Mini-glossary
Annotation grammar: the one-line structure per street with required tags and a token.
Texture tag: dry/wet label that selects size family.
Family: 33/50/75 sizing group used by the token.
Sequence tag: action flow (chk-chk, x/r risk) that unlocks probe_turns or protection.
Pressure gate: fold-vs-size read (Fv50/Fv75) that guides half_pot_50 vs big_bet_75.
Blockers: cards that block value or unblock bluffs.
SPR band: low/mid/high leverage context at street start.
token set: the fixed actions allowed in review and play.

# EV: Expected Value - the average amount you'd win or lose if you made the same play many times.
