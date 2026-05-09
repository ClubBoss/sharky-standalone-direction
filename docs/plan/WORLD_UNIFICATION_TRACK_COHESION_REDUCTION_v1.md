# World Unification Track Cohesion Reduction v1

## Purpose

Record one bounded reduction wave inside the `World / Runner Unification
Frontier`.

This wave does not change canonical readiness or the active ops queue. It
reduces the final measured world10 track-session cohesion residue visible in the
runner-unification audit.

## Reduced Residue

- measured residue before this wave:
  world10 `track_session` rows were reported as `mixed`
- exact count before:
  `30`
- measured residue after this wave:
  world10 `track_session` rows report as `canonical`
- exact count after:
  `0`

## Why This Reduction Is Honest

- the affected track sessions were already canonical in repo truth:
  - host family already `sessionDrillPlayer`
  - launch path already `adapted`
  - launch health already `ok`
- the mixed classification came from whole-world cohesion bucketing, not from
  contradictory runtime truth
- this wave narrows track cohesion to the track-session family itself rather
  than inventing any new scoring model

## Exact Bounded Change

- treat `track_session` rows as their own cohesion bucket inside the
  spine-progression cohesion audit
- leave canonical readiness and paused ops truth unchanged

## Acceptance Condition

This wave is valid only if:

1. `dart run tools/runner_unification_readiness_audit_v1.dart` still runs
2. world10 track-session rows now classify `canonical`
3. no new mixed residue is introduced elsewhere
