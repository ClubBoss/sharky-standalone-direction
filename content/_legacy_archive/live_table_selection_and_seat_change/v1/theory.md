What it is
Live table selection and position moves translated into frequency shifts using a fixed action set. We never change ladders or sizes: preflop 3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb; postflop small_cbet_33, half_pot_50, big_bet_75; concepts size_up_wet, size_down_dry, protect_check_range, delay_turn, probe_turns, double_barrel_good, triple_barrel_scare, call, fold, overfold_exploit. Physics first: size_down_dry on static (A83r/K72r); size_up_wet on dynamic (JT9ss/986ss). Selection and positioning only change how often we choose each token.

Why it matters
Table position and table quality drive EV/hour more than micro mix tweaks. Getting IP on whales, avoiding tough positions on your left, and leaving reg wars lets you use the same trees with better frequencies: more blocker 3-bets, more merged value, more protect_check_range, and disciplined rivers.

Rules of thumb


- Whale on your left (you OOP more): add protect_check_range.
- Soft table (high VPIP/avg pot, table_speed slow): favor half_pot_50 merged value.
- Tough table (tight VPIP, small avg pot): fold more vs big_bet_75 without blockers.
- Limp-heavy (multi_limpers): choose size_down_dry for thin value and half_pot_50 for merged spots.
- Fast folds to 12bb persist: tag overfold_exploit and widen 3bet_oop_12bb with blockers.
- EP tight and low 4-bet room: upgrade premiums to 4bet_ip_21bb.
- Reg on your left (raise-prone turns): use delay_turn with medium strength.
- SRP checks through often: plan probe_turns on good turns.
- Static flops in soft pools: small_cbet_33 (size_down_dry).
- Dynamic turns with blockers vs caller cap: double_barrel_good; upgrade to big_bet_75 only with evidence.
- Load/fatigue rising while waiting for a position move: simplify with small_cbet_33 and half_pot_50.

Position heuristics

* Prefer whales on your right (you IP): more 3bet_ip_9bb and half_pot_50 merged value.
* Prefer sticky regs on your right (you IP) rather than left; if stuck OOP to a reg, shift toward protect_check_range and delay_turn.
* If two tough regs on your left, request a position change or table change; until then, fold rivers more vs big_bet_75 without blockers.


Mini example
a) You move to a better position relative to the whale (you IP). BTN vs whale in BB: preflop widen 3bet_ip_9bb with A5s; flop K72r -> size_down_dry + small_cbet_33; turn 2x vs calls -> half_pot_50 merged value; river faces big_bet_75 from passive whale without blockers -> fold.
b) You leave a tough table (strong players on your left) and play soft BvB. SB opens 2.0bb, BB widens 3bet_oop_12bb with blockers. Flop A83r -> small_cbet_33; later chk-chk -> probe_turns.

Common mistakes
Taking a worse position to chase a straddle; inventing off-tree sizes; ignoring texture when the table is soft; hero-calling polar rivers without blockers; refusing position changes when capped OOP; failing to protect_check_range versus stabby regs; tagging overfold_exploit on one orbit.

Mini-glossary
Whale: very loose caller; target with 3bet_ip_9bb and half_pot_50 value.
Table speed: hands/hour; lower speed favors simpler tokens.
Position change: request to move; aim for IP on whales.
On the right/left: position relative to a target; right = you IP more.
Limp frequency: how often players limp; pushes toward merged value and protection.
Avg pot / VPIP: softness indicators guiding frequency shifts.
Overfold exploit: evidence-gated widening of pressure using the same ladders.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times


