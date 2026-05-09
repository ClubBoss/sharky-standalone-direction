What it is
This module explains how rake and antes shift incentives and how to convert those shifts into **frequency** changes using the same ladders and size families. We never change sizes. We only adjust how often we use: 3bet_ip_9bb, 3bet_oop_12bb, 4bet_ip_21bb, 4bet_oop_24bb, small_cbet_33, half_pot_50, big_bet_75, size_up_wet, size_down_dry, protect_check_range, delay_turn, probe_turns, double_barrel_good, triple_barrel_scare, call, fold, overfold_exploit.

Why it matters
Rake taxes small pots and weak realization, especially OOP. That favors tighter flats OOP and more value heavy 3 bets. Antes add dead money, rewarding steals and pressure. These economics change EV/hour more than micro in hand tweaks. You keep the same ladders and 33/50/75 sizes, but you shift frequencies-especially preflop and on turn/river pressure nodes.

Rules of thumb

* **Rake light/rake free:** widen opens and defends; add **overfold_exploit** if folds rise; ladders unchanged.
* **Ante present:** dead money -> widen **3bet_ip_9bb** and **3bet_oop_12bb** with blockers; postflop favor **half_pot_50** to tax wide ranges.
* **Rake bands:** if effective rake 6-8 bb/100, avoid thin OOP flats and light river bluff catches; if low, defend wider IP.
* **SPR mapping unchanged:** **3bet_ip_9bb / 3bet_oop_12bb / 4bet_ip_21bb / 4bet_oop_24bb** stay fixed; shift frequency only.
* **Rivers in rakey pools:** rake already paid, but populations under bluff big. Fold more vs **big_bet_75** without blockers.
* **Antes vs stations:** merged calling increases. Choose **half_pot_50** more for value; keep **size_down_dry** for thin value on static.
* **Probing after check check:** ante fields surrender more turns. Use **probe_turns** when sequence favors it.
* **Delay under rake:** when turn raises spike OOP in rakey cash, use **delay_turn** with medium strength.

Mini example
HU BTN vs BB, 100bb. Flop A83r.

* **Rake heavy cash:** BTN opens 2.0bb; BB defends tighter OOP. BTN uses **small_cbet_33**. Versus turn brick, prefer **half_pot_50** with strong value and **delay_turn** with medium. Preflop, value 3-bets and **4bet_ip_21bb** perform well. River facing **big_bet_75** without blockers -> fold.
* **Ante MTT:** BTN open gets defended wider. BTN still **small_cbet_33** on A83r, but many turns prefer **half_pot_50**. Preflop, widen **3bet_ip_9bb** and **3bet_oop_12bb** with blockers; tag **overfold_exploit** if blinds fold too much.

Common mistakes

* Copying rake free ranges to rakey cash. Fix: tighten OOP flats; add **3bet_oop_12bb** value.
* Inventing off tree sizes to "beat the rake." Fix: keep 33/50/75; move frequencies.
* Over calling OOP because price "looks close." Fix: consider realization tax; fold or **3bet_oop_12bb**.
* Over pressuring dry boards with **big_bet_75** in rakey pools. Fix: **size_down_dry** or **half_pot_50**.
* Ignoring ante leverage. Fix: add **3bet_ip_9bb / 3bet_oop_12bb** with blockers.

Mini-glossary
**Rake:** fee taken from the pot; increases the cost of low realization lines.
**Ante:** forced contribution preflop; adds dead money and widens ranges.
**Realization tax:** equity lost due to position/rake; higher OOP and in rakey games.
**Dead money:** chips in the pot not backed by strong ranges; increases steal EV.
**SPR:** stack to pot ratio; ladders fix SPR; economics shift frequency, not size.

EV: Expected Value - the average amount you'd win or lose if you made the same play many times.
