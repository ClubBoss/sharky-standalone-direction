What it is
This module is a repeatable study pipeline that turns played hands into stable, tokenized adjustments. Steps: collect hands -> tag quick signals -> pick review spots -> run a compact solver baseline (preflop ladders and 33/50/75 only) -> optional single variable node lock -> convert outputs to tokens -> build drills -> track KPIs -> close the loop next session.

Why it matters
Systemized review improves EV/hour far more than ad hoc browsing. A single compact tree produces consistent decisions under pressure: physics first (board texture picks the size family), reads second (frequency shifts).

Rules of thumb

* Token mapping: wet turn + higher Fold vs 75% -> double_barrel_good with big_bet_75.
* Drill building: each reviewed hand produces one demo and one drill with the exact token and a one line rationale. retention and spaced repetition.
* KPI loop: weekly counts for missed probe_turns after check check, thin value misses (size_down_dry), overuse of big_bet_75 on dry boards, river calls without blockers, and skipped 4bet_ip_21bb with premiums. track what moves EV.
* Session guardrails: under fatigue or when scaling tables, bias toward small_cbet_33, half_pot_50, delay_turn, protect_check_range; reserve big_bet_75 for clear blocker supported folds. reduces error rate while preserving EV.

Mini example
Flagged hand 1: HU 100bb, SRP K72r IP as BTN vs BB. Review: K72r dry -> size_down_dry family. Flop: small_cbet_33; turn brick -> half_pot_50; river facing raise without blockers -> fold. Created drill with this token sequence.
Flagged hand 2: HU 60bb, 3bet pot JT9ss OOP after 3bet_oop_12bb from BB. Solver baseline: dynamic -> size_up_wet; flop half_pot_50, turn completes straight draws -> delay_turn to control; river check to trap. Tagged KPI: missed delay_turn. Conversion: built drill for delay_turn recognition on dynamic turns OOP.

Common mistakes
* Overbuilt trees with too many sizes. Fix: ladders + 33/50/75 only.
* Multi lock spaghetti. Fix: lock one variable, sweep a band, adopt only persistent EV gains.
* Reading frequency without EV context. Fix: select the highest EV token and allow small mixes when deltas are tiny.
* Inventing off tree sizes. Fix: stay with small_cbet_33, half_pot_50, big_bet_75.
* Skipping blockers on rivers. Fix: fold more to polar big bets without blockers; triple_barrel_scare only with strong blockers on credible scare cards.
* Ignoring realization. Fix: call thresholds rise OOP; prefer initiative or fold marginal spots instead of "close" calls.

Mini-glossary
Baseline: the unlocked equilibrium for your compact tree.
Node lock: fixing one opponent behavior (e.
Lock sweep: testing several realistic lock values to see if EV gains persist.
KPI: weekly count of key decisions (missed probes, thin value, river calls w/o blockers).
Drill: one line question with a single token answer built from a reviewed spot.
Token set: the fixed actions used in training and execution (preflop ladders, 33/50/75, and concepts).

EV: Expected Value - the average amount you'd win or lose if you made the same play many times.
