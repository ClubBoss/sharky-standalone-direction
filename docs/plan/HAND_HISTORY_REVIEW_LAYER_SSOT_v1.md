# Hand History Review Layer SSOT v1

Status: ACTIVE
Last updated: 2026-05-06

## Purpose

Own the long-horizon review layer where played hands become structured learning
material instead of disappearing as isolated outcomes.

## System Job

This layer should convert played or completed hands into a stable learning loop:

1. capture the hand or drill outcome
2. classify the concept family involved
3. explain the mistake or success in compact language
4. route into replay, repair, or study
5. leave a reusable trace for later growth

## Core Difference From Review Queue

The normal Review queue is short-horizon and task-level.

The Hand History Review layer is longer-horizon and pattern-level.

Review queue answers:

- what should I fix next?

Hand History Review answers:

- what kinds of spots keep costing me?
- what hand patterns should I study more deeply?

## Input Types

1. in-app drill hands
2. repaired mistakes
3. real-play session notes
4. imported or manually logged hand histories in later versions

## Canonical Output Types

1. `Replay this spot`
2. `Same family, easier rep`
3. `Same family, mixed rep`
4. `Study note`
5. `Pattern detected`

## Pattern Families

This system should eventually group mistakes by:

1. position mistakes
2. preflop discipline mistakes
3. board-reading mistakes
4. price / pot-odds mistakes
5. value-vs-bluff mistakes
6. exploit / population-read mistakes
7. mindset / session-process mistakes

## World Interaction Rule

This system may reference any earlier concept family already introduced.

It must not:

- introduce a brand-new advanced concept via history review alone
- replace the curated world ladder
- overfit to one dramatic outcome

## Product Relationship

This system connects:

1. session result
2. review
3. profile
4. study workflow
5. long-term leak correction

## Coverage Relationship

This system is the canonical owner for:

- hand-history review layer
- pattern-level replay
- long-horizon mistake clustering
- study-from-hands workflow

## Future Expansion

Later versions may add:

1. tagged hand notebook
2. concept labels on each reviewed hand
3. direct drill generation from hand families
4. import/export or parser-assisted hand review

The invariant stays the same:

hands should compound into skill, not just outcomes
