# Adaptive Spaced Repetition SSOT v1

Status: ACTIVE
Last updated: 2026-05-06

## Purpose

Own the cross-world resurfacing system that keeps important concepts alive over
time instead of letting the learner pass once and forget.

## System Job

This system should decide:

1. what concept family is due for resurfacing
2. whether resurfacing should be recall, repair, or mixed reinforcement
3. when to interleave older worlds into current practice
4. how to keep repetition useful without boredom

## Core Rule

Resurfacing should be concept-driven, not world-driven only.

The learner should revisit:

- weak concepts earlier
- unstable concepts more often
- strong concepts less often

## Input Signals

1. last-seen timestamp
2. last-correct vs last-wrong pattern
3. number of repeated misses
4. whether a concept was repaired successfully
5. concept family importance
6. current world and current momentum state

## Output Modes

1. `Recall rep`
   Same concept, low pressure, quick retrieval.
2. `Repair rep`
   Same concept after an actual failure.
3. `Mixed reinforcement`
   Reintroduce an older concept alongside a newer one.
4. `Gate refresh`
   Bring back a prerequisite concept before a harder world intensifies.

## Boredom Guard

Spaced repetition must not feel like copy-paste repetition.

Variation should come from:

1. new board / seat / stack context
2. different but same-family hands
3. same concept under a different street or position
4. shorter prompts and fewer hints over time

Do not rely on:

- random noise
- cosmetic label changes
- unstructured mixed content

## World Interaction Rule

The system may interleave worlds.

It may not:

- destroy progression logic
- resurface advanced concepts before prerequisites are stable
- turn Today into an unpredictable soup

## Surface Homes

1. Home: reflected as daily or best-next-action support
2. Play: reflected as practice groups and spaced decks
3. Review: reflected as repair resurfacing
4. Profile: reflected only as summary signal, not detailed scheduler logic

## Coverage Relationship

This system is the canonical owner for:

- adaptive spaced repetition
- interleaved reinforcement
- due concept resurfacing
- post-repair recheck logic

## Success Standard

The learner should feel:

- "I keep seeing the right things again before I forget them"
- not "the app keeps repeating itself"
