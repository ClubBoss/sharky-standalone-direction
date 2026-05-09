# Crucible c2_check_raise_intent_control

## Objective
Control check-raise intent by separating value and bluff branches on flop and turn.

## Scenario
Each rep anchors street and pressure context, then selects check, call, or raise.
This crucible trains explicit intent control in check-raise nodes.

## Decision
Identify whether node intent is value, bluff, or control before action.
Choose only the expected branch for that intent.

## Explanation
C2 enforces deterministic check-raise intent selection.
Expected actions prevent intent mixing under pressure.
