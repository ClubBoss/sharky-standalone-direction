# Crucible c3_river_value_bluff_separation

## Objective
Separate river value and bluff intent with deterministic final-street action choices.

## Scenario
Each rep anchors river context and pressure, then selects one intent-consistent action.
This crucible enforces final-street discipline without solver language.

## Decision
Classify node as value, bluff, or showdown-control before acting.
Choose only the expected branch for that label.

## Explanation
C3 keeps final-street intent explicit and deterministic.
Expected actions prevent value-bluff overlap.
