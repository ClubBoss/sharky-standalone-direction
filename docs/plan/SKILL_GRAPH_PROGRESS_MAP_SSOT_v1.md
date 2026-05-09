# Skill Graph Progress Map SSOT v1

Status: ACTIVE
Last updated: 2026-05-06

## Purpose

Own progress representation by skill family, not only by world completion.

## Problem

World progress alone is not enough.

A learner can be:

- far in the ladder but weak in one key concept family
- early in the ladder but unusually strong in one family

So the product needs a skill graph view underneath the world map.

## System Job

Represent progress across concept families such as:

1. table literacy
2. position thinking
3. hand reading
4. board reading
5. preflop discipline
6. bet purpose
7. price intuition
8. range thinking
9. exploit adjustment
10. mindset / session process

## Canonical State Model

Each skill family should eventually support a simple state:

1. `Introduced`
2. `Recognizes`
3. `Decides`
4. `Needs repair`
5. `Stable`
6. `Transfer-ready`

This is intentionally not a precise rating system.
It is a product-facing learning map.

## Relationship To Worlds

Worlds remain the curated route.

Skill graph answers:

- what am I really getting better at?
- what still breaks under pressure?
- what concept is lagging behind my ladder position?

## Relationship To Other Systems

1. leak map uses skill graph weakness signals
2. spaced repetition uses skill graph stability signals
3. profile summarizes skill graph state
4. hand-history review attaches reviewed hands to skill families

## Surface Rules

### Home

- may use skill graph only to improve next-action quality

### Profile

- may summarize strongest areas, next reps, and unstable concepts
- must stay simple and not become an analytics wall

### Review

- may use skill graph family labels for repair clustering

### Learn

- worlds stay primary
- skill graph should not replace the main course route

## Coverage Relationship

This system is the canonical owner for:

- skill-first progress map
- family-level progress state
- progress by competence, not only by ladder location

## Future Expansion

Later versions may add:

1. family confidence bars
2. family transfer-readiness gates
3. skill-family trend direction
4. family-based study playlists

The invariant stays:

worlds teach the route, skill graph explains the growth
