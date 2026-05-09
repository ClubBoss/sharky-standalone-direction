# Session w9.s06

## Objective
Build the first World 9 checkpoint by filtering exploits through board context instead of applying the same adjustment everywhere.

## Scenario
Each rep shows a player tendency and then changes the board texture around it.
The learner decides whether the exploit still applies cleanly or whether the board should reduce confidence in the adjustment.

## Decision
Choose whether the board context strengthens, weakens, or blocks the exploit opportunity.

## Explanation
Board-driven exploit filtering prevents crude overgeneralization.
The goal is to see that a useful player read still has to survive contact with the board before it becomes the right adjustment.
