# Mode Family Strategy v1
Status: SSOT-lite
Purpose: Record the agreed curated mode-family strategy before broader exercise/drill rollout continues.
Last updated: 2026-03-09

## Use

This document is the in-repo reference for product and architecture decisions about exercise/drill families.
It is not a runtime registry and it does not replace `docs/plan/MASTER_PLAN_v2.2.md`.
It defines the intended family set, the cognitive job of each family, and the rollout discipline that future work should follow.

Core rule:

- Use a small curated set of strong mode families.
- Do not grow a zoo of one-off formats with overlapping jobs.
- New worlds and nodes should be composed from curated families, not ad hoc interaction ideas.

## Why Curated Mode Families

The product should not evolve by stitching random drill types into individual hosts.
That creates:

- duplicated cognitive jobs
- inconsistent UX standards
- hard-to-guard runtime drift
- one-off wiring that does not scale

The preferred model is:

- each family has a distinct cognitive job
- each family has reusable runtime/system patterns
- each family can be piloted, guarded, and scaled intentionally

## Tier 1: Current Core / Must-Have Families

These are the core families the product should rely on first.

### Identify / Locate

Cognitive job:
- find the right object, seat, street, card, or anchor quickly and accurately

Typical use:
- seat anchors
- button / blinds
- table orientation
- visual recognition baselines

### Order / Sequence

Cognitive job:
- understand and apply the correct order of events or actors

Typical use:
- action order
- blind order
- street order
- ordered table flow

### Action Choice

Cognitive job:
- choose the best action from a compact legal set and understand the local reason

Typical use:
- fold / call / check / bet / raise decisions
- recommended action with compact correction

### Bet Sizing Choice

Cognitive job:
- choose between meaningful sizes and connect size to purpose

Typical use:
- keep weaker hands in
- balanced value
- pressure
- minimal reopen

### Review / Recap

Cognitive job:
- consolidate what was just learned and revisit mistakes with low friction

Typical use:
- review queues
- short end-of-cluster recaps
- compact reinforcement after a bounded drill run

## Tier 2: Near-Future High-EV Families

These are the next strong families once the current core is stable.

### Hand Strength / Showdown Comparison

Cognitive job:
- compare holdings and learn what actually wins

### Outs / Improvement Counting

Cognitive job:
- estimate how many cards improve the hand in simple, repeatable ways

### Equity / Pot-Odds Intuition

Cognitive job:
- build practical feel for whether continuing is worth the price

### Classifier

Cognitive job:
- classify a spot, board, hand, or situation into the right decision bucket

### Multi-step Chain

Cognitive job:
- hold a short reasoning chain across multiple linked steps instead of isolated taps

## Tier 3: Later But Valuable Families

These are valuable later families, but they should come after the earlier tiers are stable.

### Error Spotting / Leak Detection

Cognitive job:
- recognize a mistake pattern and identify what is wrong

### Explain the Why

Cognitive job:
- produce or select the key reason for a decision after basic choice skill exists

### Initiative / Aggression Tracking

Cognitive job:
- track who drove the action and how initiative changes decisions

### Street Transition Logic

Cognitive job:
- connect preflop, flop, turn, and river changes into one coherent process

### Range Construction Lite

Cognitive job:
- reason about broad likely holdings without needing a heavy solver model

### Speed Round / Blitz

Cognitive job:
- build fast recognition and confidence once understanding is already present

### Mixed Challenge

Cognitive job:
- combine multiple stable families in one bounded mixed session

### Transfer / Real Table Application

Cognitive job:
- connect controlled practice back to live-table recognition and decision use

## Curated-Mix Principle

Future worlds and nodes should use curated mixes of a few mode families rather than random proliferation.

Practical rule:

- one world or node should usually rely on a small number of families
- each family used in that slice should have a clear job
- if two candidate formats teach the same thing, keep one

This keeps rollout readable, guardable, and scalable.

## Rollout Discipline

Future mode-family rollout should happen through:

1. mode contracts
2. world/node mode matrix
3. guards
4. bounded pilots
5. reusable system patterns instead of one-off wiring

Meaning:

- a family should have a contract before broad expansion
- a world/node should explicitly declare which families it uses
- guards should catch drift between family intent and reachable runtime behavior
- new families should begin as bounded pilots
- once a family is proven, later rollout should reuse the same pattern instead of custom host logic each time

## Preservation Rule For Future Math / Comparison Families

The long-term learning system should explicitly preserve these families:

- hand strength / showdown comparison
- outs / improvement counting
- equity / pot-odds intuition
- math micro-drills

They are part of the intended future system and should not disappear simply because the current visible product is concentrated on earlier seat/order/action work.

## Practical Decision Rule

When considering a new exercise/drill idea, ask:

1. Which existing mode family does this belong to?
2. What distinct cognitive job does it serve?
3. Is that job already served by an existing family?
4. Can it launch as a bounded pilot with contracts and guards?
5. Does it fit a world/node matrix intentionally, or is it just a one-off idea?

If those answers are unclear, do not broaden rollout yet.

## Near-Term Implication

Near-term work should favor:

- strengthening the current core Tier 1 families
- bringing new hosts onto proven family seams
- piloting Tier 2 families deliberately
- avoiding format sprawl before the matrix/registry layer is broader
