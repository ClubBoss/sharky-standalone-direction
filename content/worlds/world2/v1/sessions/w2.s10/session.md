# Session w2.s10

## Objective
Carry one board-context scene through texture, outs, and a simple follow-up action.

## Scenario
The same flop stays in view while the learner classifies pressure, counts improvement, and then makes one simple action choice.
This is a compact mini-loop, not a full branching hand.

## Decision
Use the same authored context step by step.
First read the board, then count the clean improvement path, then choose the simplest supported follow-up action.

## Explanation
The chain ties three linked judgments together without adding solver-heavy complexity:
board pressure, improvement potential, then one simple action response.
