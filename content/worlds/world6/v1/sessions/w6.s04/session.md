# Session w6.s04

## Objective
Turn Range Compression: Re-evaluate range density on turn and avoid stale flop-only action plans.

## Scenario
Turn card compresses value and bluff ranges and requires action reset.

## Decision
Update range estimate on turn before selecting action.

## Explanation
Turn compression changes which actions remain profitable for the full range.
