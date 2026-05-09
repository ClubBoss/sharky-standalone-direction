# Concept To World Coverage Matrix v1

Status: ACTIVE SSOT-LITE FOR CURRICULUM COVERAGE
Last updated: 2026-05-06

## Purpose

This document is the active anti-gap coverage matrix for the full learning
route.

Use it to answer:

1. does an important concept family from `Concepts.md` have a canonical home?
2. which world owns it first?
3. where is it reinforced later?
4. which important concept families still need sharper documentation ownership?

This document does not replace:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`

It complements them by making concept coverage explicit in one place.

## Numbering Rule

Use current `MASTER_PLAN_v3.0` numbering:

- `W1 = Poker from Zero`
- `W2 = Hand Discipline`
- `W3 = Position Thinking`
- `W4 = Preflop Framework`
- `W5 = Bet Purpose + Price`
- `W6 = Board Awareness`
- later worlds continue from there

`Concepts.md` uses a zero-start beginner framing in places. For current product
routing, this matrix follows the master-plan numbering only.

## Status Meanings

- `solid`: the concept family has a clear world home in current docs
- `partial`: the concept family is present, but its ownership is still split,
  under-specified, or missing a dedicated cross-world system owner
- `gap`: important enough to keep, but still lacking one clean canonical home
- `deferred`: intentionally later in the route; world home exists, active
  production is not required now

## Full Coverage Matrix

| Block | Concept family | Key topics from `Concepts.md` | Primary world home | Reinforcement / later home | Status | Canonical owner now | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Core game structure | what poker is, goal, hand, pot, bet/call/raise/fold/check, showdown | W1 | Review layer | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | Early beginner foundation is explicit. |
| 2 | Table roles and blind mechanics | dealer button, SB, BB, why blinds move, first/last to act | W1 | W3, W11 | solid | `MASTER_PLAN_v3.0` | Strong table-first owner seam. |
| 3 | Street order and action flow | preflop, flop, turn, river, showdown, action order pre/postflop | W1 | W6, W11 | solid | `MASTER_PLAN_v3.0` | One of the strongest documented foundations. |
| 4 | Hand rankings and showdown rules | pair through royal flush, comparisons, board plays, split pots, ace high/low, kicker basics | W1-W2 | W6 | solid | `MASTER_PLAN_v3.0` | Kicker and board-plays are explicitly preserved. |
| 5 | Early table procedure and pot outcomes | all-in, side pot, split pot, chopped pot, muck, several all-ins | W1 for basic all-in/showdown, W18/W30 for deeper procedure | W30 | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | Ownership is intentionally split by difficulty: beginner-visible procedure early, side-pot and live-procedure depth later. |
| 6 | Format orientation | cash vs tournament, tournament vs SNG, online vs live | W1 light orientation | W9, W26, W30, W36 | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | Correctly spread across route maturity. |
| 7 | Table-first visual literacy | seats on felt, visual button/blinds, visible who acts | W1 | whole shell | solid | `MASTER_PLAN_v3.0` | Explicit product-strength area. |
| 8 | Hand vocabulary | hole cards, community cards, made hand, draw, overcards, underpair, overpair, top pair, bluff catcher, air, trash hand | W1-W2 | W6, W13 | solid | `MASTER_PLAN_v3.0` | Clear early-to-mid home. |
| 9 | Relative vs absolute hand strength | top pair not always strong, showdown value, marginal/vulnerable hands | W6 | W13-W16 | solid | `MASTER_PLAN_v3.0` | One of the most important `Concepts.md` upgrades already patched into plan. |
| 10 | Board texture taxonomy | rainbow, two-tone, monotone, paired, connected, dry/wet, static/dynamic, scary turn, blank river | W6 | W13-W16 | solid | `MASTER_PLAN_v3.0` | W6 owns first explicit board-first shift. |
| 11 | Draw and out taxonomy | gutshot, OESD, double gutter, flush draw, backdoors, combo draw, dirty/clean/hidden/blocked/live/dead outs | W6 | W13 | solid | `MASTER_PLAN_v3.0` | Strongly anchored after recent concept-patch passes. |
| 12 | Position names and labels | UTG, LJ, HJ, CO, BTN, SB, BB, EP/MP/LP, IP/OOP | W3 | W20, W23 | solid | `MASTER_PLAN_v3.0` | Clean world home. |
| 13 | Why position creates EV | more information, pot control, realize equity, thin value, deny equity, pressure capped ranges | W3 | W13-W20 | solid | `MASTER_PLAN_v3.0` | Strong cognitive shift ownership. |
| 14 | Relative position and multiway positional truth | relative position vs aggressor, acting behind, closing action, players left to act | W3 | W18, W20 | solid | `MASTER_PLAN_v3.0` | Important `Concepts.md` nuance is explicitly retained. |
| 15 | Preflop hand classes | pocket pairs, broadways, suited connectors, wheel aces, dominated broadways, playability, suitedness, connectedness | W4 | W17, W23 | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | Correctly lives in structured preflop world. |
| 16 | Open-raise and fold discipline | RFI, open-fold discipline, loose/tight opens, open sizing by position/depth/rake | W2-W4 | W23 | solid | `MASTER_PLAN_v3.0` | Strong route from discipline to framework. |
| 17 | Limp / overlimp / isolation logic | limp, overlimp, isolation raise, when limping is weak, when strategic | W4 | W20, W30 | solid | `MASTER_PLAN_v3.0` | Clear home, later exploit/live reinforcement exists. |
| 18 | Calling and blind defense | flat call, cold call, overcall, BB defend, SB defend, call in/out of position, realization and rake adjustments | W4 | W17, W23, W28 | solid | `MASTER_PLAN_v3.0` | Strong long-term home, though active product is earlier. |
| 19 | 3-bet / 4-bet / squeeze family | value/bluff 3-bets, polar/linear, blockers, 4-bets, squeeze, blind-vs-button | W17 | W23-W25 | solid | `MASTER_PLAN_v3.0` | Late but clearly owned. |
| 20 | Effective stack and stack depth | stack size, effective stack, 100bb/50bb/20bb/10bb logic | W8 | W17, W26, W32 | solid | `MASTER_PLAN_v3.0` | Clear dedicated world. |
| 21 | SPR and commitment | SPR, low/high SPR, commitment threshold, stack-off ranges, geometric setup | W8 | W14, W16 | solid | `MASTER_PLAN_v3.0` | Strongly documented and reinforced. |
| 22 | Price and pot-odds intuition | pot odds, price to call, required equity, break-even call, basic bluff break-even framing | W5 | W8, W13 | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | Good home, though active route still needs dense production. |
| 23 | Equity intuition | raw vs realized equity, fold equity, implied odds, reverse implied odds, equity denial | W5-W8 bridge | W13-W19 | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | The bridge is now explicit: price intuition starts first, board/draw quality makes equity tangible, stack/risk context deepens it, later postflop worlds formalize realization and denial. |
| 24 | Betting reasons | value bet, bluff, protection, thin value, equity denial, future-street setup | W5 | W15-W16 | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | Strongly aligned with `Bet Purpose + Price`. |
| 25 | Bet sizing fundamentals | small/medium/large/pot/overbet/underbet, value sizing, bluff sizing, sizing by texture/SPR/position | W5 | W14-W16 | solid | `MASTER_PLAN_v3.0` | Good progression from intuitive to advanced. |
| 26 | Basic c-bet and flop logic | c-bet, frequency, selective vs range c-bet, board-texture interaction | W13-W15 | W17+ | solid | `MASTER_PLAN_v3.0` | Clear world home, but later than `Concepts.md` early-release framing suggests. |
| 27 | Turn and river basics | barrel/give-up, turn scare card, river value/bluff/bluff-catch, block bet, river sizing | W16 | W24 | solid | `MASTER_PLAN_v3.0` | Clear and strong long-term home. |
| 28 | Range thinking | range vs exact hand, capped/uncapped, continuing/folding ranges, range advantage, nut advantage | W7 | W13, W19, W22-W25 | solid | `MASTER_PLAN_v3.0` | Explicitly scaffolded and later deepened. |
| 29 | Combo and blocker logic | combos, card removal, blockers/unblockers, bluff-to-value ratio | W7 | W24-W25 | solid | `MASTER_PLAN_v3.0` | Good late-technical progression. |
| 30 | Exploit and population adjustment | player types, overfold/underbluff populations, exploit deviation, river underbluff population exploit | W10 | W19-W20 | solid | `MASTER_PLAN_v3.0` | Important practical edge is explicitly retained. |
| 31 | Multiway discipline | range compression, top pair fragility, side pots, position in multiway, bluff reduction | W18 | W30 | solid | `MASTER_PLAN_v3.0` | Clear home, though `Concepts.md` argues for an earlier seed. |
| 32 | Tournament pressure and ICM | bubble pressure, risk premium, push/fold, M-ratio, stack pressure | W9 | W26 | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | Strong dedicated route. |
| 33 | Live poker procedure and live-only formats | etiquette, string bets, acting out of turn, muck rules, ante games, straddle, bomb pots, run it twice | W30 | W36 | solid | `MASTER_PLAN_v3.0` | Clear late live-specialization home. |
| 34 | Bankroll and risk management | bankroll rules, risk of ruin, shot-taking, life-roll separation, stop-loss, stop-win | W21 seed | W28, W34-W35 | solid | `MASTER_PLAN_v3.0` | Correctly split between mental seed and pro layer. |
| 35 | Variance, tilt, mindset | variance, outcomes vs decisions, tilt types, winner's tilt, session emotional control | W11 seed, W12 full install | W21, W34 | solid | `MASTER_PLAN_v3.0` | Strongly covered. |
| 36 | Study workflow and review habit | session journaling, hand tagging, review loop, mistake correction, study process | W11 seed | W21, W29, review layer | solid | `MASTER_PLAN_v3.0` | Clear route from beginner seed to pro workflow. |
| 37 | Mistake recovery loop | wrong -> why -> replay similar spot -> track weakness | cross-world from W1 | review/progression systems | solid | `MASTER_PLAN_v3.0` | One of the clearest product strengths. |
| 38 | Session result and decision reflection | result framing, session takeaways, variance-aware interpretation | W11-W12 | review / profile systems | solid | `MASTER_PLAN_v3.0` | Present as concept family; product shell already leans this way. |
| 39 | Personalized leak map | weakness map, strongest leaks, personal next focus | cross-world system | W21, W29, W36 | solid | `LEAK_MAP_AND_RECOMMENDATION_SYSTEM_SSOT_v1.md` | Now has one clean system owner for weakness-to-next-action translation. |
| 40 | Adaptive spaced repetition | resurfacing mistakes, interleaving across worlds, revisit weak concepts later | cross-world system | Play / Review / Daily systems | solid | `ADAPTIVE_SPACED_REPETITION_SSOT_v1.md` | Now has one clean canonical owner for due-concept resurfacing and interleaving. |
| 41 | Progress map by skill, not only world | skill graph, progress by competence family, not just ladder position | cross-world system | profile / advanced study layer | solid | `SKILL_GRAPH_PROGRESS_MAP_SSOT_v1.md` | Now has one clean system owner for family-level progress state. |
| 42 | Hand-history review layer | structured review of completed or imported hands | W21 seed | W29, W36 | solid | `HAND_HISTORY_REVIEW_LAYER_SSOT_v1.md` | Now has one clean system owner for pattern-level replay and study-from-hands. |
| 43 | Difficulty scaling | no spikes, smooth route, family-first progression, anti-jump pacing | cross-world route rule | all worlds | solid | `MASTER_PLAN_v3.0`, `PROGRESSION_PREREQUISITE_MATRIX_v1` historical support | Strongly present as route principle. |
| 44 | EV-based recommendation logic | best next action, repair-first routing, what to do next and why | Home / Play / Review system | W29-W36 deeper study layer | solid | `LEAK_MAP_AND_RECOMMENDATION_SYSTEM_SSOT_v1.md` | Recommendation logic now has a canonical system owner, even though later product depth can still expand. |
| 45 | Solver and heuristic extraction | GTO, mixed strategies, solver reading, node locking, heuristic extraction | W22-W25 | W29 | solid | `MASTER_PLAN_v3.0` | Strong late-advanced ownership. |
| 46 | Format-specific specialization | cash path, MTT path, SNG, live, heads-up, full-ring vs 6-max | W8-W9 seeds | W26, W30, W33, W36 | solid | `MASTER_PLAN_v3.0`, `CONTENT_PLAN_PER_WORLD_v2.1` | Clearly represented in long-term route. |
| 47 | Complete pro workflow | analytics, reporting, volume, table selection, long-term training plan, career EV | W28-W36 | final specialization layers | solid | `MASTER_PLAN_v3.0` | Strong long-horizon ownership exists. |

## Coverage Verdict

The route now has a canonical home or canonical system owner for effectively
every important concept family in `Concepts.md`.

The remaining documentation risk is no longer "missing poker topics" or
"ownerless system families" in the main ladder.

The main remaining risk is later depth and production density, not missing
ownership:

1. later-world production detail still has to catch up to the route
2. some advanced practical topics still arrive later than `Concepts.md` would
   prefer
3. cross-world systems now have owners, but their eventual product execution
   can deepen over time

The active no-loss protocol for keeping this true during future waves now lives
in:

- `docs/plan/COVERAGE_LOCK_PROTOCOL_v1.md`

## Important Tension To Keep Explicit

`Concepts.md` wants some practical postflop concepts earlier in the route than
the current ladder does, especially:

- basic c-bet framing
- basic turn/river decisions
- multiway caution

Current master-plan policy is still coherent, but this tension should remain
explicit:

- if we keep the current ladder, those topics stay later on purpose
- if we want a more aggressive practical early route, this should be changed
  intentionally in `MASTER_PLAN_v3.0`, not drift in ad hoc

The active decision layer for those disputes now lives in:

- `CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`

## System Packet Status

The cross-world system packet now exists and is canonical for coverage:

1. `LEAK_MAP_AND_RECOMMENDATION_SYSTEM_SSOT_v1.md`
2. `ADAPTIVE_SPACED_REPETITION_SSOT_v1.md`
3. `HAND_HISTORY_REVIEW_LAYER_SSOT_v1.md`
4. `SKILL_GRAPH_PROGRESS_MAP_SSOT_v1.md`

This closes the main ownership ambiguity.
Future work should change these docs only when the owner systems themselves
change, not because coverage truth is unclear.
