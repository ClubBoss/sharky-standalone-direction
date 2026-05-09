# Crucible c1_3bet_4bet_discipline

## Objective
Apply deterministic 3bet and 4bet discipline by position and facing-open context.

## Scenario
Each rep anchors seat and pressure state before selecting call, fold, or raise.
This crucible sharpens preflop aggression control without solver language.

## Decision
Use position and toCall context first, then select the expected branch.
Do not blend passive and aggressive responses in the same node.

## Explanation
C1 tests stable aggression rules under preflop pressure.
Expected actions enforce consistent 3bet and 4bet discipline.
