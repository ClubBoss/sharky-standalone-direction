# Review Queue Fixture Contract Repair v1

## Scope

Repair the baseline Review-queue test contract only. No Review product behavior,
copy, routing, telemetry, or visual structure changed.

## Root cause

The fixture correctly created an open repair by replaying the aged
`actions_raise_drill` incorrectly. Its assertion targeted the retired prominent
`act0_shell_mistake_card` key. Current non-clean Review states intentionally
use `act0_shell_review_repair_coach_card` as the primary repair entry.

## Proven contract

When an open repair and an aged recheck coexist:

1. Review renders the active repair-coach card before recovered proof.
2. The unrelated aged recheck remains visible as a secondary fixed/replay card.
3. The replayed source becomes active repair and is not duplicated as recovered
   proof.

## Change

Update the fixture assertion to the stable repair-coach key, preserve the
ordering assertion, and explicitly verify the replayed source is absent from
the recovered queue.

## Checks

- Exact repaired Review-queue test.
- Focused Review shell suite.
- Open-repair relaunch, Home priority, and carry-relaunch tests.
- `flutter analyze`.
- `dart format --set-exit-if-changed`.
- `git diff --check`.

## Limits

This is a test-contract repair. It does not change Review behavior or broaden
the repair system.

## Next

Package this small baseline repair independently before starting another product
wave.
