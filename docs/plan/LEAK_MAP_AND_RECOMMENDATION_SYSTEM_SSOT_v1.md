# Leak Map And Recommendation System SSOT v1

Status: ACTIVE
Last updated: 2026-05-06

## Purpose

Own the personalized leak-map and best-next-action layer.

This system turns curriculum coverage into personal route guidance:

- what the learner is weakest at
- what should be repaired next
- what should be practiced next
- why that recommendation exists

## System Job

The system should answer five questions:

1. what skill family is weak?
2. how severe is the weakness?
3. is this a one-off miss or a repeated leak?
4. what exact next action has highest learning EV?
5. how should that recommendation surface on Home, Play, Review, and Profile?

## Inputs

1. world / lesson / task completion
2. wrong-answer history
3. repair success vs repeated failure
4. recent gains
5. current world and current concept family
6. streak / habit context only as secondary prioritization

## Outputs

1. `Best next action`
2. `Repair first`
3. `Daily set`
4. `Recommended focus`
5. personal weak-spot labels
6. deep-leak vs quick-fix classification

## Canonical Severity Bands

1. `Quick fix`
   One miss, one replay likely enough.
2. `Weak spot`
   Repeated miss in same concept family.
3. `Deep leak`
   Repeated miss across time or across related spots; must route into a real repair lane.

## World Interaction Rule

The leak map does not own world order.

It may:

- pick the next best task inside the allowed route
- surface repair before forward progression when needed
- resurface earlier concepts

It must not:

- invent a new world order
- skip prerequisites silently
- route learners into late-world concepts before the ladder allows them

## Surface Contracts

### Home

- one dominant next action
- weak-spot or deep-leak recommendations outrank generic daily reps

### Play

- category practice should reflect active leak families
- must stay simple, not become an analytics dashboard

### Review

- owns the repair queue
- owns mistake severity and replay path

### Profile

- shows stable strengths, next reps, and recent gains
- should summarize, not own the whole repair workflow

## Anti-Bloat Rule

The leak map is not:

- a raw stat board
- a spreadsheet of every mistake
- a full poker HUD

It should compress the learner’s state into one actionable route.

## Coverage Relationship

This system is the canonical owner for these concept families:

- personalized leak map
- repeated mistake correction
- recommendation logic
- weakness-to-next-action translation

## Future Expansion

Later versions may add:

1. family-level leak clustering
2. weak-concept streaks
3. confidence / stability bands
4. world-family readiness gates

But the core invariant must stay:

one learner -> one clearest next action
