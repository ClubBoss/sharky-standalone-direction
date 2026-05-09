# Session w4.s06

## Objective
Verify denial-intent sizing across a mixed checkpoint set.

## Scenario
This checkpoint mixes small price-keeping, stronger denial charges, and controlled reopens.
You should still recognize when denial means lightly taxing realization and when it means making the continue expensive now, rather than simply bluffing or maximizing value.

## Decision
Choose the preset that best matches denial intent in each checkpoint rep.

## Explanation
The checkpoint confirms you can keep denial intent stable even when the pressure ladder changes from rep to rep:
lighter denial keeps realization from being too easy,
while the strongest denial line makes continuing expensive immediately.
