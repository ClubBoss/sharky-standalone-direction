# Session w6.s09

## Objective
Range Transition by Street: Track range transitions from flop to river and keep action families consistent with updated density.

## Scenario
Street progression changes range composition and action frequencies.

## Decision
Recompute range per street before committing to line.

## Explanation
Street-by-street transitions prevent stale range assumptions.
