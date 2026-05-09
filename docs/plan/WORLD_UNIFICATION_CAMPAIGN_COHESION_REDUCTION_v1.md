# World Unification Campaign Cohesion Reduction v1

## Purpose

Record one bounded reduction wave inside the `World / Runner Unification
Frontier`.

This wave does not change canonical readiness or the active ops queue. It
reduces the measured campaign-spine cohesion residue now visible in the
runner-unification audit.

## Reduced Residue

- measured residue before this wave:
  session-backed campaign-pack rows were reported as `mixed`
- exact count before:
  `36`
- measured residue after this wave:
  session-backed campaign-pack rows report as `canonical`
- exact count after:
  `0`

## Why This Reduction Is Honest

- the affected campaign packs were already canonical in repo truth:
  - host family already `sessionDrillPlayer`
  - launch health already `ok`
  - launch path already `adapted`
- the mixed classification came from whole-world cohesion bucketing, not from
  contradictory runtime truth
- this wave narrows campaign cohesion to the campaign-pack family itself rather
  than inventing any new scoring model

## Exact Bounded Change

- treat `campaign_pack` rows as their own cohesion bucket inside the
  spine-progression cohesion audit
- leave world10 track-session residue unchanged

## Acceptance Condition

This wave is valid only if:

1. `dart run tools/runner_unification_readiness_audit_v1.dart` still runs
2. session-backed campaign-pack rows now classify `canonical`
3. world10 track-session mixed residue remains unchanged unless separately
   reduced in a future wave
