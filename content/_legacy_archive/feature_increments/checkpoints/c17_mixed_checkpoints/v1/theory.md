### C17 Mixed Checkpoints: Multi-Street Control

Mixed checkpoints blend preflop plan, flop texture, and turn/river adjustments into a single, repeatable flow. You cycle through key questions at each street: who holds range and nut advantage, how stack-to-pot changes leverage, and which population errors appear. This flow prevents autopilot and keeps your line consistent whether you face a single-raised pot (SRP) or a 3-bet pot, in or out of position.

[[IMAGE: c17_flow | checkpoint flow]]

Start preflop: confirm position (UTG, MP, CO, BTN, SB, BB), stack depth, and pot type. In SRP as IP, you often hold range advantage on dry, high boards; as OOP in 3BP you favor pot control unless you have clear nut edge. Set an initial checkpoint: planned flop size (cbet_small vs cbet_big) or check_back, plus turn branches based on card classes (overcards, pairs, straight/flush completions).

Board texture drives your next checkpoint. High-card dry boards reward small, frequent cbets; dynamic boards with straight and flush draws need bigger sizes or higher check frequency. Paired boards reduce bluff success, so you bias toward value and delayed cbet. When the board shifts on the turn (second high card, front-door flush, straight completer), reassess leverage: decide whether to slow down, double barrel, or convert a check into probe_bet if villain declines to fight.

[[IMAGE: c17_map  | checkpoint map]]

Turn and river deviations separate strong plans from rote scripts. If your flop line was cbet_small and the turn bricks, you can repeat small sizing to fold out ace-highs. If the turn brings a scare card favoring your range in IP, a cbet_big or raise versus a small lead captures equity denial. Rivers demand clarity: value bet thin versus overcalls, or check when ranges are bluff-catch heavy. Avoid betting into capped ranges with no blockers; instead, raise small leads or fold marginal bluff-catches when aggression looks real.

Population errors shape exploit checkpoints. Recreational pools overcall paired boards and overfold scary turns. They also under-bluff rivers after missed draws, so you can fold more thin bluff-catches. Some regs overbluff when checked to in 3BP; respond with check-call plans and trap raises on bricks. Undersized cbets in ICM spots signal fear; raise or float with backdoors, then pressure turns that do not help villain. Keep your exploit triggers explicit to avoid drift.

Multi-street checkpoint logic keeps lines coherent. Before acting, note: range edge, nut edge, blocker support, and future card classes. On the flop, pick a size that fits that edge. On the turn, ask whether the card helps you or villain and whether stack-to-pot allows a credible bluff. On the river, decide value or shutdown based on how many worse hands call and how often bluffs succeed. Each checkpoint is a small pause to correct course.

Contrast with GTO: a balanced strategy spreads actions; the checkpoint flow intentionally weights lines toward population leaks and recent evidence while retaining enough balance to avoid obvious exploits.

Implementation checklist: identify pot type and position; tag board class; choose flop size; set turn reaction plans for bricks vs scare cards; define river thresholds for value and bluffs. When you see repeated errors (overfold on double barrels, overcall on paired boards, overbluff on scare cards), lock in an exploit: increase barrel frequency, bet thinner for value, or call more with bluff-catchers that beat their bluffs. Run the same loop each hand to keep decisions disciplined across SRP, 3BP, IP, and OOP contexts.
