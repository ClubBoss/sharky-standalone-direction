What it is
Practical primer on using a solver with HU focus, transferable to 6-max. Build compact trees, pick size families, read frequencies and EVs, and convert outputs into fixed actions: 3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb, small_cbet_33, half_pot_50, big_bet_75, size_up_wet, size_down_dry, protect_check_range, delay_turn, probe_turns, double_barrel_good, triple_barrel_scare, call, fold, overfold_exploit.

Why it matters
Solvers are consistent only if your tree mirrors real choices. Compact, realistic trees produce clear frequencies and small EV deltas you can execute. Mapping outputs to canonical tokens removes guesswork, speeds review, and stabilizes decisions.

Rules of thumb
- Keep trees compact: preflop sizes are 3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb; postflop sizes are small_cbet_33, half_pot_50, big_bet_75. Stable ladders reduce noise.
- Use size_down_dry on static boards (A83r, K72r) and size_up_wet on dynamic boards (JT9ss, 986ss). Equity volatility dictates pressure.
- Treat tiny EV gaps as mixable: track the highest EV action and one backup. Execution tolerance matters more than 1-2bb per 100 when deltas are small.
- Protect checks with protect_check_range and prefer delay_turn with medium strength. Avoiding capped nodes increases defense.
- On turns, double_barrel_good when your range, nut, or equity advantage grows; otherwise pick half_pot_50 or delay_turn. Add leverage where it exists.

Mini example
UTG, MP, CO fold. BTN is SB. BB posts 1bb. 100bb effective.
Flop K72r in SRP after SB opens and BB calls. Solver prefers small_cbet_33 (size_down_dry) high frequency IP, mixing checks with some Kx to protect_check_range.
Turn 3h: solver delay_turn with marginal Kx and double_barrel_good with sets, strong Kx, and good backdoors.
River Qc: solver folds weak Kx to big_bet_75 but calls when holding better blockers to value and unblocking missed draws.

Common mistakes
- Overbuilt trees. Too many sizes hide clear patterns and fragment EV; players try to capture every edge. Fix: stick to 33, 50, 75 and preflop ladders.
- Reading raw frequency without EV. Chasing colorful 70% actions that are lower EV than 30% lines; frequency maps are visually loud. Fix: sort by EV first.
- Copying mixes blindly. Forcing thin multiway mixes you cannot execute; fear of deviating from solver output. Fix: bias to top EV action and one backup mapped to tokens.

Mini-glossary
Compact tree: reduced action set that still captures optimal structure.
Frequency map: solver output showing how often each token fires.
EV delta: EV gap between candidate actions; small deltas enable practical mixing.
Exploit tag: intentional deviation like overfold_exploit when population tendencies increase EV.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times


Mini example
UTG, MP, CO fold. BTN is SB. BB posts 1bb. 100bb effective.
Flop K72r in SRP after SB opens and BB calls. Solver prefers small_cbet_33 (size_down_dry) high frequency IP, mixing checks with some Kx to protect_check_range.
Turn 3h: solver uses delay_turn with marginal Kx for pot control and double_barrel_good with sets, strong Kx, and backdoor equity when the turn card adds leverage to PFA range.
River Qc: solver folds weak Kx without blockers facing big_bet_75 but calls when holding better blockers to value combos and unblocking villain's missed draws.
