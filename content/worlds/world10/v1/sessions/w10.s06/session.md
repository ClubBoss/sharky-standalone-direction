# Session w10.s06

## Objective
Run a consistency checkpoint across seat, board, hole-card, and action reads.

## Scenario
Use the table state, board texture, and hole cards to verify that the same track logic still holds under repeated pressure.

## Decision
Anchor the position and seat, confirm the board and hole cards, then choose the action that proves the track read remains consistent.

## Explanation
The board taps and hole-card taps test whether the learner is still reading the same pattern cleanly before taking action.
