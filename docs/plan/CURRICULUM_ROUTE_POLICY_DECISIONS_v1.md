# Curriculum Route Policy Decisions v1

Status: ACTIVE
Last updated: 2026-05-06

## Purpose

Freeze the highest-EV concept-route decisions so future content waves can move
fast without reopening the same curriculum arguments every time.

This document does not replace:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`
- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`

It defines the decision layer between "coverage exists" and "author new
content."

## Why This Exists

After the coverage matrix became fully owned, the main unresolved frontier was
no longer missing concepts.

The real frontier became route policy:

1. which practical concepts should arrive earlier
2. which concepts should be seeded early but mastered later
3. which advanced concepts should stay late on purpose
4. what production order gives the highest learner-value per wave

Without one decision layer, future waves risk:

- reopening the same debates
- ad hoc concept drift
- content production against unstable routing

## Decision Status Meanings

- `keep_late`: keep the current later home intentionally
- `move_earlier`: shift the first real home earlier in the route
- `split_seed_mastery`: seed early, deepen later, master much later
- `hold_late_preview_only`: keep later and do not make it earlier now

## Current Policy Decisions

| Priority | Concept family | Current route truth | Decision | Policy reason | Action implication |
| --- | --- | --- | --- | --- | --- |
| 1 | Basic c-bet framing | First formal home is W13-W15 | `split_seed_mastery` | New users benefit from seeing "preflop raiser often continues" earlier, but full texture-driven c-bet policy is too heavy for the visible spine. | Seed one simple continuation-bet intuition after W6 foundations are stable; keep real c-bet strategy in later postflop worlds. |
| 2 | Basic turn and river decisions | First formal home is W16 | `split_seed_mastery` | The learner should not feel poker ends on the flop, but early worlds must avoid multi-street overload. | Add early street-continuation awareness and simple "board changed the story" bridges; keep real barreling, bluff-catching, and river sizing late. |
| 3 | Multiway caution | First formal home is W18 | `move_earlier` | Waiting too long hides one of the most common beginner losses: top pair and draw value collapse fast in multiway pots. | Seed simple "more players = stronger hands needed and fewer bluffs" earlier in W4-W6 examples, then preserve W18 for full multiway discipline. |
| 4 | Equity intuition | W5-W8 bridge, later formalization | `split_seed_mastery` | This family is too important to feel abstract, but too broad to fully install early. | Keep current bridge: price -> draws/outs -> stack/risk -> realization/denial later. Do not compress it into one world. |
| 5 | Implied odds and reverse implied odds | Early mention in W5/W6, deeper later | `split_seed_mastery` | Early learners need danger and upside intuition, not formula-heavy treatment. | Keep lightweight early treatment and reserve exact threshold reasoning for later postflop and stack-depth worlds. |
| 6 | Relative position in multiway pots | W3 first mention, W18 later depth | `split_seed_mastery` | This nuance materially improves decisions but should not overcomplicate first position literacy. | Preserve the existing W3 seed and make sure W18 cashes it out with real multiway examples. |
| 7 | Blind-vs-blind widening and limper punishment | W4 | `move_earlier` | These are high-frequency, high-payoff beginner edges and fit the first practical preflop world. | Keep them explicitly inside release-visible W4, not as optional advanced seasoning. |
| 8 | Backdoor equity and semi-bluff intuition | W6 first home, later depth | `move_earlier` | Board-and-draw worlds feel much stronger when draws are not taught as only obvious 8- or 9-out cases. | Keep W6 as the first real home and make sure the early visible route does not reduce draws to only obvious flush/straight cases. |
| 9 | Hand-history review and study-from-hands | W21 seed, W29+ deeper | `split_seed_mastery` | The full system is late, but the learner should feel earlier that played hands can become future study. | Keep the owner system late-capable, but seed "replay this spot" and "same family again" language much earlier via Review. |
| 10 | Skill-first progress and leak-first routing | Cross-world system | `move_earlier` | Product value rises sharply when the route feels personal before the advanced worlds exist. | Keep the system simple, but surface stable strengths, weak spots, and next reps before late study worlds. |
| 11 | Solver language and exact frequencies | W22-W25 | `hold_late_preview_only` | This adds intimidation and low beginner EV if it leaks early. | Keep solver-first language out of the visible route; only hint that deeper strategy exists later. |
| 12 | ICM and strong tournament deviation | W9 and later | `keep_late` | The concept is important, but only after the learner can already play cash-like fundamentals. | Keep current route; do not drag ICM logic into early worlds. |

## Policy Summary

The route should become more practical earlier, but not more technical earlier.

That means:

1. move a few high-frequency practical cautions earlier
2. seed multi-street awareness earlier
3. keep heavy solver, river, and tournament abstraction late
4. prefer `seed -> reinforce -> mastery` over one-time big dumps

## Default Production Order After This Policy Pass

Use this order unless a user-visible blocker changes the EV:

1. strengthen W4-W6 with the approved early seeds
2. make W7-W9 honest and dense against the approved route
3. only then deepen late postflop worlds where the mastery treatment belongs
4. preserve late solver / advanced tournament / professional worlds as later
   expertise layers

## Admitted Near-Term Route Moves

These are the approved next curriculum-production moves:

1. W4: preserve blind-vs-blind widening and anti-limper logic as first-class
   practical preflop content
2. W5-W6: make equity, draw quality, semi-bluff, and street-change bridges feel
   more real and less skeletal
3. W4-W6: introduce light multiway caution as examples and transfer rules, not
   as a full advanced world
4. Review/Profile/Home systems: surface replay, weak-spot, and next-rep logic
   earlier without turning the product into a dashboard

## Not Admitted Yet

Do not do these by default just because the concept family exists:

1. move full c-bet strategy into the visible beginner spine
2. move full turn/river tree construction into W4-W6
3. move solver, MDF, indifference, or frequency language early
4. open W18-W30 content just because early seeds mention those families

## Decision Rule For Future Waves

When a concept dispute appears:

1. check whether it is already covered in this file
2. if yes, follow the decision here
3. if not, add one new row here before broad authoring starts
4. then update `MASTER_PLAN_v3.0.md` and `CONTENT_PLAN_PER_WORLD_v2.1.md`
   only if the route or authoring home truly changes

The goal is simple:

fewer repeated debates, faster content execution, stronger route coherence
